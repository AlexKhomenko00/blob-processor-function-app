import { app, InvocationContext, Timer } from '@azure/functions';
import { BlobServiceClient } from '@azure/storage-blob';
import { DefaultAzureCredential } from '@azure/identity';

const STORAGE_ACCOUNT = process.env.STORAGE_ACCOUNT_NAME || 'your-storage-account';
const RETENTION_DAYS = 30;

async function cleanup(myTimer: Timer, context: InvocationContext): Promise<void> {
    context.log('Starting daily cleanup...');
    
    const credential = new DefaultAzureCredential();
    const url = `https://${STORAGE_ACCOUNT}.blob.core.windows.net`;
    const blobServiceClient = new BlobServiceClient(url, credential);
    
    const containers = ['processed', 'archived', 'failed'];
    const cutoffDate = new Date();
    cutoffDate.setDate(cutoffDate.getDate() - RETENTION_DAYS);
    
    for (const containerName of containers) {
        let deletedCount = 0;
        const containerClient = blobServiceClient.getContainerClient(containerName);
        
        try {
            for await (const blob of containerClient.listBlobsFlat()) {
                if (blob.properties.lastModified < cutoffDate) {
                    await containerClient.deleteBlob(blob.name);
                    deletedCount++;
                }
            }
            context.log(`Deleted ${deletedCount} old blobs from ${containerName}`);
        } catch (error) {
            context.error(`Error cleaning ${containerName}:`, error);
        }
    }
    
    context.log('Cleanup completed');
}

// Register timer function - runs daily at 2 AM
app.timer('TimerCleanup', {
    schedule: '0 0 2 * * *',
    handler: cleanup
});