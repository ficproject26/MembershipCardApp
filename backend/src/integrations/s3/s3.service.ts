import { Injectable, Logger } from '@nestjs/common';
import {
  S3Client,
  PutObjectCommand,
  GetObjectCommand,
  DeleteObjectCommand,
} from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';

@Injectable()
export class S3Service {
  private readonly s3: S3Client;
  private readonly bucket: string;
  private readonly logger = new Logger(S3Service.name);

  constructor() {
    this.s3 = new S3Client({
      region: process.env.AWS_REGION || 'ap-south-1',
      credentials: {
        accessKeyId: process.env.AWS_ACCESS_KEY_ID!,
        secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY!,
      },
    });
    this.bucket = process.env.AWS_BUCKET_NAME || 'forgeindia-storage';
  }

  /**
   * Upload a file to S3
   * @param key - The S3 object key (path), e.g. 'kyc/lead123/aadhaar_front.jpg'
   * @param body - The file buffer
   * @param contentType - MIME type of the file
   * @returns The S3 key of the uploaded object
   */
  async upload(key: string, body: Buffer, contentType: string): Promise<string> {
    const command = new PutObjectCommand({
      Bucket: this.bucket,
      Key: key,
      Body: body,
      ContentType: contentType,
    });

    await this.s3.send(command);
    this.logger.log(`File uploaded to S3: ${key}`);
    return key;
  }

  /**
   * Generate a signed URL to view/download a private S3 object
   * @param key - The S3 object key
   * @param expiresInSeconds - URL expiry time (default: 1 hour)
   * @returns A pre-signed URL string
   */
  async getSignedUrl(key: string, expiresInSeconds = 3600): Promise<string> {
    const command = new GetObjectCommand({
      Bucket: this.bucket,
      Key: key,
    });

    const url = await getSignedUrl(this.s3, command, {
      expiresIn: expiresInSeconds,
    });
    return url;
  }

  /**
   * Delete a file from S3
   * @param key - The S3 object key to delete
   */
  async delete(key: string): Promise<void> {
    const command = new DeleteObjectCommand({
      Bucket: this.bucket,
      Key: key,
    });

    await this.s3.send(command);
    this.logger.log(`File deleted from S3: ${key}`);
  }
}
