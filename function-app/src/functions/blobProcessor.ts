import { app, InvocationContext } from "@azure/functions";
import { BlobServiceClient } from "@azure/storage-blob";
import { ManagedIdentityCredential } from "@azure/identity";

const STORAGE_ACCOUNT =
  process.env.STORAGE_ACCOUNT_NAME || "your-storage-account";
const CLIENT_ID = process.env.DATA_STORAGE_CONNECTION__clientId;

// Helper to get storage client
function getStorageClient() {
  const credential = new ManagedIdentityCredential({ clientId: CLIENT_ID });
  const url = `https://${STORAGE_ACCOUNT}.blob.core.windows.net`;
  return new BlobServiceClient(url, credential);
}

// Narrow trigger metadata type
interface BlobTriggerMetadata {
  name: string;
  blobTrigger: string;
  uri: string;
}

// Main blob processor
export async function processBlobTrigger(
  blob: Buffer,
  context: InvocationContext
): Promise<void> {
  const metadata = context.triggerMetadata as unknown as BlobTriggerMetadata;

  const blobName = metadata?.name;
  const blobTrigger = metadata?.blobTrigger || "";
  const container = blobTrigger.split("/")[0];

  if (!blobName || !container) {
    context.error("Missing blob name or container in trigger metadata");
    return;
  }

  context.log(`Processing blob: ${blobName} from ${container}`);
  const startTime = Date.now();

  try {
    // Validate file type
    const fileExtension = blobName.split(".").pop()?.toLowerCase();
    if (!fileExtension || !["json", "csv", "txt"].includes(fileExtension)) {
      throw new Error(`Unsupported file type: ${fileExtension}`);
    }

    // Process the file (simple transformation)
    const content = blob.toString("utf-8");
    const processed = {
      originalName: blobName,
      processedAt: new Date().toISOString(),
      fileType: fileExtension,
      size: blob.length,
      content: fileExtension === "json" ? JSON.parse(content) : content,
      metadata: {
        lineCount: content.split("\n").length,
        wordCount: content.split(/\s+/).length,
      },
    };

    // Save to processed container
    const storageClient = getStorageClient();
    const processedContainer = storageClient.getContainerClient("processed");
    await processedContainer.createIfNotExists();

    const processedBlobName = `${Date.now()}_${blobName}`;
    const blockBlobClient =
      processedContainer.getBlockBlobClient(processedBlobName);
    await blockBlobClient.upload(
      JSON.stringify(processed, null, 2),
      Buffer.byteLength(JSON.stringify(processed))
    );

    // Archive original
    const sourceBlobClient = storageClient
      .getContainerClient(container)
      .getBlockBlobClient(blobName);
    const sourceUrl = sourceBlobClient.url;

    const archiveContainer = storageClient.getContainerClient("archived");
    await archiveContainer.createIfNotExists();

    const archiveBlobClient = archiveContainer.getBlockBlobClient(
      `${Date.now()}_${blobName}`
    );
    await archiveBlobClient.beginCopyFromURL(sourceUrl);

    // Delete original
    await sourceBlobClient.delete();

    const duration = Date.now() - startTime;
    context.log(`✅ Processed ${blobName} in ${duration}ms`);
  } catch (error) {
    context.error(`❌ Failed to process ${blobName}:`, error);

    // Move to failed container
    try {
      const storageClient = getStorageClient();
      const failedContainer = storageClient.getContainerClient("failed");
      await failedContainer.createIfNotExists();

      const failedBlobName = `${Date.now()}_${blobName}`;
      const failedBlobClient =
        failedContainer.getBlockBlobClient(failedBlobName);
      await failedBlobClient.upload(blob, blob.length);

      // Delete original
      const originalBlobClient = storageClient
        .getContainerClient(container)
        .getBlockBlobClient(blobName);
      await originalBlobClient.delete();
    } catch (moveError) {
      context.error("Failed to move to failed container:", moveError);
    }

    throw error;
  }
}

// Register the function
app.storageBlob("BlobProcessor", {
  path: "input-raw/{name}",
  connection: "DATA_STORAGE_CONNECTION",
  handler: processBlobTrigger,
});
