import { KycUploadService } from './kyc-upload.service';
export declare class KycUploadController {
    private readonly kycUploadService;
    constructor(kycUploadService: KycUploadService);
    generateLink(leadId: string): Promise<{
        token: any;
        url: string;
    }>;
    getDocuments(leadId: string): Promise<any>;
    getForm(token: string): Promise<string>;
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
    private getKycHtmlTemplate;
}
