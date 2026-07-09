import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { RedisService } from '../redis/redis.service';
import { Logger } from '@nestjs/common';

@Injectable()
export class PricingService {
  private readonly logger = new Logger(PricingService.name);

  constructor(
    private prisma: PrismaService,
    private redisService: RedisService,
  ) {}

  async create(createPricingDto: any) {
    const created = await this.prisma.membershipPricing.create({
      data: createPricingDto,
    });
    await this.redisService.del('pricing:all');
    return created;
  }

  async findAll() {
    const cachedPricing = await this.redisService.get('pricing:all');
    if (cachedPricing) {
      this.logger.log('Returning pricing from cache');
      return JSON.parse(cachedPricing);
    }

    const pricing = await this.prisma.membershipPricing.findMany();
    await this.redisService.set('pricing:all', JSON.stringify(pricing), 60); // Cache for 60s
    return pricing;
  }

  async findOne(id: string) {
    return this.prisma.membershipPricing.findUnique({
      where: { id },
    });
  }

  async update(id: string, updatePricingDto: any) {
    const updated = await this.prisma.membershipPricing.update({
      where: { id },
      data: updatePricingDto,
    });
    // Invalidate cache
    await this.redisService.del('pricing:all');
    return updated;
  }

  async remove(id: string) {
    const removed = await this.prisma.membershipPricing.delete({
      where: { id },
    });
    await this.redisService.del('pricing:all');
    return removed;
  }
}
