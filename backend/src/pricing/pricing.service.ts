import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma.service';

@Injectable()
export class PricingService {
  constructor(private prisma: PrismaService) {}

  async create(createPricingDto: any) {
    return this.prisma.membershipPricing.create({
      data: createPricingDto,
    });
  }

  async findAll() {
    return this.prisma.membershipPricing.findMany();
  }

  async findOne(id: number) {
    return this.prisma.membershipPricing.findUnique({
      where: { id },
    });
  }

  async update(id: number, updatePricingDto: any) {
    return this.prisma.membershipPricing.update({
      where: { id },
      data: updatePricingDto,
    });
  }

  async remove(id: number) {
    return this.prisma.membershipPricing.delete({
      where: { id },
    });
  }
}
