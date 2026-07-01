"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.KycUploadService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../prisma.service");
const fs = __importStar(require("fs"));
const path = __importStar(require("path"));
let KycUploadService = class KycUploadService {
    prisma;
    constructor(prisma) {
        this.prisma = prisma;
    }
    async generateLink(leadId) {
        const lead = await this.prisma.lead.findUnique({
            where: { id: leadId },
        });
        if (!lead) {
            throw new common_1.NotFoundException('Lead not found');
        }
        const crypto = require('crypto');
        const token = crypto.randomBytes(16).toString('hex');
        await this.prisma.lead.update({
            where: { id: leadId },
            data: { kycLink: token },
        });
        return token;
    }
    async getLeadByToken(token) {
        const lead = await this.prisma.lead.findFirst({
            where: { kycLink: token },
        });
        if (!lead) {
            throw new common_1.NotFoundException('Invalid or expired KYC link');
        }
        return lead;
    }
    async getDocumentsByLead(leadId) {
        return this.prisma.kycDocument.findMany({
            where: { leadId },
        });
    }
    async submitKyc(token, body, files) {
        const lead = await this.prisma.lead.findFirst({
            where: { kycLink: token },
        });
        if (!lead) {
            throw new common_1.NotFoundException('Invalid or expired KYC link');
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
            const fileArr = files[docType];
            if (!fileArr || fileArr.length === 0) {
                throw new common_1.BadRequestException(`Missing required document: ${docType}`);
            }
            const file = fileArr[0];
            const ext = path.extname(file.originalname);
            const fileName = `${docType}${ext}`;
            const filePath = path.join(uploadDir, fileName);
            fs.writeFileSync(filePath, file.buffer);
            const relativePath = `/uploads/kyc/${lead.id}/${fileName}`;
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
            }
            else {
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
        await this.prisma.lead.update({
            where: { id: lead.id },
            data: {
                status: 'KYC_Pending',
            },
        });
        return { message: 'KYC documents submitted successfully', count: createdDocs.length };
    }
};
exports.KycUploadService = KycUploadService;
exports.KycUploadService = KycUploadService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], KycUploadService);
//# sourceMappingURL=kyc-upload.service.js.map