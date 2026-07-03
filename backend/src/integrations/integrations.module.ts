import { Module } from '@nestjs/common';
import { S3Service } from './s3/s3.service';
import { FcmService } from './fcm/fcm.service';
import { EmailService } from './email/email.service';
import { RazorpayService } from './razorpay/razorpay.service';

@Module({
  providers: [S3Service, FcmService, EmailService, RazorpayService],
  exports: [S3Service, FcmService, EmailService, RazorpayService]
})
export class IntegrationsModule {}
