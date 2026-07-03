import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { S3Service } from '../integrations/s3/s3.service';
import * as path from 'path';

@Injectable()
export class KycUploadService {
  constructor(
    private prisma: PrismaService,
    private s3Service: S3Service,
  ) {}

  async generateLink(leadId: string) {
    const lead = await this.prisma.lead.findUnique({
      where: { id: leadId },
    });

    if (!lead) {
      throw new NotFoundException('Lead not found');
    }

    const crypto = require('crypto');
    const token = crypto.randomBytes(16).toString('hex');

    await this.prisma.lead.update({
      where: { id: leadId },
      data: { kycLink: token },
    });

    return token;
  }

  async getLeadByToken(token: string) {
    const lead = await this.prisma.lead.findFirst({
      where: { kycLink: token },
    });

    if (!lead) {
      throw new NotFoundException('Invalid or expired KYC link');
    }

    return lead;
  }

  async getDocumentsByLead(leadId: string) {
    const docs = await this.prisma.kycDocument.findMany({
      where: { leadId },
    });

    // Generate signed URLs for S3 objects
    return Promise.all(docs.map(async (doc: any) => {
      // Check if it's an S3 key or a legacy local path (just in case)
      let url = doc.filePath;
      if (!url.startsWith('/uploads/')) {
        url = await this.s3Service.getSignedUrl(doc.filePath);
      }
      return {
        ...doc,
        url, // Add signed URL to response
      };
    }));
  }

  async submitKyc(
    token: string,
    body: { aadhaarNumber: string; panNumber: string },
    files: {
      aadhaar_front?: Express.Multer.File[];
      aadhaar_back?: Express.Multer.File[];
      pan_card?: Express.Multer.File[];
      live_photo?: Express.Multer.File[];
      passport_photo?: Express.Multer.File[];
    },
  ) {
    const lead = await this.prisma.lead.findFirst({
      where: { kycLink: token },
    });

    if (!lead) {
      throw new NotFoundException('Invalid or expired KYC link');
    }

    const docTypes = [
      'aadhaar_front',
      'aadhaar_back',
      'pan_card',
      'live_photo',
      'passport_photo',
    ];

    const createdDocs = [];

    for (const docType of docTypes) {
      const fileArr = files[docType as keyof typeof files];
      if (!fileArr || fileArr.length === 0) {
        throw new BadRequestException(`Missing required document: ${docType}`);
      }

      const file = fileArr[0];
      const ext = path.extname(file.originalname);
      const fileName = `${docType}${ext}`;
      const s3Key = `kyc/${lead.id}/${fileName}`;

      // Upload to S3
      await this.s3Service.upload(s3Key, file.buffer, file.mimetype);

      // Check if document already exists to overwrite, or create a new one
      const existingDoc = await this.prisma.kycDocument.findFirst({
        where: { leadId: lead.id, docType },
      });

      let doc;
      if (existingDoc) {
        doc = await this.prisma.kycDocument.update({
          where: { id: existingDoc.id },
          data: {
            filePath: s3Key,
            aadhaarNumber: docType.startsWith('aadhaar') ? body.aadhaarNumber : null,
            panNumber: docType === 'pan_card' ? body.panNumber : null,
            uploadedAt: new Date(),
          },
        });
      } else {
        doc = await this.prisma.kycDocument.create({
          data: {
            leadId: lead.id,
            docType,
            filePath: s3Key,
            aadhaarNumber: docType.startsWith('aadhaar') ? body.aadhaarNumber : null,
            panNumber: docType === 'pan_card' ? body.panNumber : null,
          },
        });
      }
      createdDocs.push(doc);
    }

    // Update lead status to KYC_Pending
    await this.prisma.lead.update({
      where: { id: lead.id },
      data: {
        status: 'KYC_Pending',
        // We keep the kycLink so they can revisit the page and see success status,
        // but we prevent further uploads on client side if status is KYC_Pending
      },
    });

    return { message: 'KYC documents submitted successfully', count: createdDocs.length };
  }
}
