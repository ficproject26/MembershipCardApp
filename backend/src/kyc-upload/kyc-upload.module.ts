import { Module } from '@nestjs/common';
import { KycUploadController } from './kyc-upload.controller';
import { KycUploadService } from './kyc-upload.service';
import { PrismaModule } from '../prisma.module';

@Module({
  imports: [PrismaModule],
  controllers: [KycUploadController],
  providers: [KycUploadService],
})
export class KycUploadModule {}
