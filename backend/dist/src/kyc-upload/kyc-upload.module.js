"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.KycUploadModule = void 0;
const common_1 = require("@nestjs/common");
const kyc_upload_controller_1 = require("./kyc-upload.controller");
const kyc_upload_service_1 = require("./kyc-upload.service");
const prisma_module_1 = require("../prisma.module");
let KycUploadModule = class KycUploadModule {
};
exports.KycUploadModule = KycUploadModule;
exports.KycUploadModule = KycUploadModule = __decorate([
    (0, common_1.Module)({
        imports: [prisma_module_1.PrismaModule],
        controllers: [kyc_upload_controller_1.KycUploadController],
        providers: [kyc_upload_service_1.KycUploadService],
    })
], KycUploadModule);
//# sourceMappingURL=kyc-upload.module.js.map