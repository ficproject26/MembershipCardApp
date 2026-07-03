import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { FcmService } from '../integrations/fcm/fcm.service';

@Injectable()
export class LeadService {
  private readonly logger = new Logger(LeadService.name);

  constructor(
    private prisma: PrismaService,
    private fcmService: FcmService,
  ) {}

  async create(createLeadDto: any) {
    return this.prisma.lead.create({
      data: createLeadDto,
      include: { agent: true },
    });
  }

  async findAll(status?: string, serviceType?: string) {
    const where: any = {};
    if (status) where.status = status;
    if (serviceType) where.serviceType = serviceType;
    return this.prisma.lead.findMany({
      where,
      include: { agent: true },
      orderBy: { dateCreated: 'desc' },
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
    const lead = await this.prisma.lead.update({
      where: { id },
      data: updateLeadDto,
      include: { agent: true },
    });

    // Send push notification to agent when lead status changes
    if (updateLeadDto.status && lead.agent?.fcmToken) {
      this.fcmService.sendToDevice(
        lead.agent.fcmToken,
        'Lead Status Updated',
        `Your lead "${lead.customerName || 'Unknown'}" is now: ${updateLeadDto.status}`,
        { leadId: id, status: updateLeadDto.status },
      ).catch(err => this.logger.error(`Notification failed: ${err.message}`));
    }

    return lead;
  }

  async remove(id: string) {
    return this.prisma.lead.delete({
      where: { id },
    });
  }
}
