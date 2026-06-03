const { S3Client, ListObjectsV2Command, GetObjectCommand } = require('@aws-sdk/client-s3');
const { getSignedUrl } = require('@aws-sdk/s3-request-presigner');

const s3Client = new S3Client();

exports.handler = async (event) => {
    // API Key validation
    const apiKey = event.headers['x-api-key'];
    if (!apiKey || apiKey !== process.env.API_KEY) {
        return {
            statusCode: 403,
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ error: 'Forbidden: Invalid or missing API Key' })
        };
    }

    // Only allow GET
    if (event.httpMethod !== 'GET') {
        return {
            statusCode: 405,
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ error: 'Method Not Allowed' })
        };
    }

    try {
        const bucketName = process.env.S3_BUCKET_NAME;

        // List objects with prefix employee-images/
        const listCommand = new ListObjectsV2Command({
            Bucket: bucketName,
            Prefix: 'employee-images/'
        });

        const listResponse = await s3Client.send(listCommand);

        if (!listResponse.Contents || listResponse.Contents.length === 0) {
            return {
                statusCode: 200,
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ images: [], message: 'No images found' })
            };
        }

        // Generate presigned URLs for each image (1 hour expiry)
        const images = await Promise.all(
            listResponse.Contents.map(async (obj) => {
                const getCommand = new GetObjectCommand({
                    Bucket: bucketName,
                    Key: obj.Key
                });
                const url = await getSignedUrl(s3Client, getCommand, { expiresIn: 3600 });
                return {
                    key: obj.Key,
                    url: url,
                    lastModified: obj.LastModified
                };
            })
        );

        return {
            statusCode: 200,
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ images: images, count: images.length })
        };
    } catch (error) {
        console.error('Error:', error);
        return {
            statusCode: 500,
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ error: 'Internal Server Error', details: error.message })
        };
    }
};
