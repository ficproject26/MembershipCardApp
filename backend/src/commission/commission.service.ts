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

    let commissions = await (this.prisma as any).commissionConfig.findMany();
    if (!commissions || commissions.length === 0) {
      const defaults = [
        { serviceType: 'Credit Card', silverRate: 1000, goldRate: 1500, diamondRate: 1800, platinumRate: 2000 },
        { serviceType: 'Loan', silverRate: 1200, goldRate: 1800, diamondRate: 2200, platinumRate: 2500 },
        { serviceType: 'Jobs', silverRate: 400, goldRate: 700, diamondRate: 900, platinumRate: 1000 },
        { serviceType: 'Insurance', silverRate: 1500, goldRate: 2200, diamondRate: 2700, platinumRate: 3000 },
        { serviceType: 'IT Projects', silverRate: 3000, goldRate: 4500, diamondRate: 5500, platinumRate: 6000 },
        { serviceType: 'BPO Services', silverRate: 2500, goldRate: 3500, diamondRate: 4500, platinumRate: 5000 },
        { serviceType: 'App Referral', silverRate: 300, goldRate: 500, diamondRate: 600, platinumRate: 700 },
        { serviceType: 'Plan Upgrade', silverRate: 500, goldRate: 800, diamondRate: 1000, platinumRate: 1200 },
      ];
      for (const d of defaults) {
        await (this.prisma as any).commissionConfig.upsert({
          where: { serviceType: d.serviceType },
          update: {},
          create: d,
        });
      }
      commissions = await (this.prisma as any).commissionConfig.findMany();
    }

    await this.redisService.set('commission:all', JSON.stringify(commissions), 60);
    return commissions;
  }

  async update(serviceType: string, updateDto: any) {
    const decodedService = decodeURIComponent(serviceType);
    const updated = await (this.prisma as any).commissionConfig.upsert({
      where: { serviceType: decodedService },
      update: {
        silverRate: updateDto.silverRate !== undefined ? parseFloat(updateDto.silverRate) : undefined,
        goldRate: updateDto.goldRate !== undefined ? parseFloat(updateDto.goldRate) : undefined,
        diamondRate: updateDto.diamondRate !== undefined ? parseFloat(updateDto.diamondRate) : undefined,
        platinumRate: updateDto.platinumRate !== undefined ? parseFloat(updateDto.platinumRate) : undefined,
      },
      create: {
        serviceType: decodedService,
        silverRate: parseFloat(updateDto.silverRate || 500),
        goldRate: parseFloat(updateDto.goldRate || 1000),
        diamondRate: parseFloat(updateDto.diamondRate || 1500),
        platinumRate: parseFloat(updateDto.platinumRate || 2000),
      },
    });
    await this.redisService.del('commission:all');
    return updated;
  }
}
