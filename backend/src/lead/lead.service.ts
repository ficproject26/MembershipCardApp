import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma.service';

@Injectable()
export class LeadService {
  constructor(private prisma: PrismaService) {}

  async create(createLeadDto: any) {
    return this.prisma.lead.create({
      data: createLeadDto,
      include: { agent: true },
    });
  }

  async findAll() {
    return this.prisma.lead.findMany({
      include: { agent: true },
    });
  }

  async findOne(id: string) {
    return this.prisma.lead.findUnique({
      where: { id },
      include: { agent: true },
    });
  }

  async findByAgent(agentId: string) {
    return this.prisma.lead.findMany({
      where: { agentId },
      include: { agent: true },
    });
  }

  async update(id: string, updateLeadDto: any) {
    return this.prisma.lead.update({
      where: { id },
      data: updateLeadDto,
    });
  }

  async remove(id: string) {
    return this.prisma.lead.delete({
      where: { id },
    });
  }
}
