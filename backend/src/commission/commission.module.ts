import { Module } from '@nestjs/common';
import { CommissionController } from './commission.controller';
import { CommissionService } from './commission.service';
import { PrismaModule } from '../prisma.module';
import { RedisService } from '../redis/redis.service';

@Module({
  imports: [PrismaModule],
  controllers: [CommissionController],
  providers: [CommissionService, RedisService],
  exports: [CommissionService],
})
export class CommissionModule {}
