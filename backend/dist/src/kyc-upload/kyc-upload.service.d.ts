import { PrismaService } from '../prisma.service';
export declare class KycUploadService {
    private prisma;
    constructor(prisma: PrismaService);
    generateLink(leadId: string): Promise<any>;
    getLeadByToken(token: string): Promise<any>;
    getDocumentsByLead(leadId: string): Promise<any>;
    submitKyc(token: string, body: {
        aadhaarNumber: string;
        panNumber: string;
    }, files: {
        aadhaar_front?: Express.Multer.File[];
        aadhaar_back?: Express.Multer.File[];
        pan_card?: Express.Multer.File[];
        live_photo?: Express.Multer.File[];
        passport_photo?: Express.Multer.File[];
    }): Promise<{
        message: string;
        count: number;
    }>;
}
