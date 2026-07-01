import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import * as fs from 'fs';
import * as path from 'path';

@Injectable()
export class KycUploadService {
  constructor(private prisma: PrismaService) {}

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
    return this.prisma.kycDocument.findMany({
      where: { leadId },
    });
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

    const uploadDir = path.join(process.cwd(), 'uploads', 'kyc', lead.id);
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
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
      const filePath = path.join(uploadDir, fileName);

      fs.writeFileSync(filePath, file.buffer);

      // Relative path to be served statically
      const relativePath = `/uploads/kyc/${lead.id}/${fileName}`;

      // Check if document already exists to overwrite, or create a new one
      const existingDoc = await this.prisma.kycDocument.findFirst({
        where: { leadId: lead.id, docType },
      });

      let doc;
      if (existingDoc) {
        doc = await this.prisma.kycDocument.update({
          where: { id: existingDoc.id },
          data: {
            filePath: relativePath,
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
            filePath: relativePath,
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
