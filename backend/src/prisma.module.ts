import { Global, Module } from '@nestjs/common';
import { PrismaService } from './prisma.service';
import { SystemGateway } from './system.gateway';

@Global()
@Module({
  providers: [PrismaService, SystemGateway],
  exports: [PrismaService, SystemGateway],
})
export class PrismaModule {}
