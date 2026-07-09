import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { RedisService } from '../redis/redis.service';

@Injectable()
export class CommissionService {
  private readonly logger = new Logger(CommissionService.name);

  constructor(
    private prisma: PrismaService,
    private redisService: RedisService,
  ) {}

  async findAll() {
    const cached = await this.redisService.get('commission:all');
    if (cached) {
      this.logger.log('Returning commissions from cache');
      return JSON.parse(cached);
    }

    const commissions = await (this.prisma as any).commissionConfig.findMany();
    await this.redisService.set('commission:all', JSON.stringify(commissions), 60);
    return commissions;
  }

  async update(serviceType: string, updateDto: any) {
    const updated = await (this.prisma as any).commissionConfig.update({
      where: { serviceType },
      data: {
        silverRate: updateDto.silverRate !== undefined ? parseFloat(updateDto.silverRate) : undefined,
        goldRate: updateDto.goldRate !== undefined ? parseFloat(updateDto.goldRate) : undefined,
        diamondRate: updateDto.diamondRate !== undefined ? parseFloat(updateDto.diamondRate) : undefined,
        platinumRate: updateDto.platinumRate !== undefined ? parseFloat(updateDto.platinumRate) : undefined,
      },
    });
    await this.redisService.del('commission:all');
    return updated;
  }
}
