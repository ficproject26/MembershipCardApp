"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.IntegrationsModule = void 0;
const common_1 = require("@nestjs/common");
const s3_service_1 = require("./s3/s3.service");
const fcm_service_1 = require("./fcm/fcm.service");
const email_service_1 = require("./email/email.service");
const razorpay_service_1 = require("./razorpay/razorpay.service");
let IntegrationsModule = class IntegrationsModule {
};
exports.IntegrationsModule = IntegrationsModule;
exports.IntegrationsModule = IntegrationsModule = __decorate([
    (0, common_1.Module)({
        providers: [s3_service_1.S3Service, fcm_service_1.FcmService, email_service_1.EmailService, razorpay_service_1.RazorpayService]
    })
], IntegrationsModule);
//# sourceMappingURL=integrations.module.js.map