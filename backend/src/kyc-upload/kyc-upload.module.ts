import { Module } from '@nestjs/common';
import { KycUploadController } from './kyc-upload.controller';
import { KycUploadService } from './kyc-upload.service';
import { PrismaModule } from '../prisma.module';
import { IntegrationsModule } from '../integrations/integrations.module';

@Module({
  imports: [PrismaModule, IntegrationsModule],
  controllers: [KycUploadController],
  providers: [KycUploadService],
})
export class KycUploadModule {}
