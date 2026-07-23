import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { FcmService } from '../integrations/fcm/fcm.service';
import { RedisService } from '../redis/redis.service';

@Injectable()
export class LeadService implements OnModuleInit {
  private readonly logger = new Logger(LeadService.name);

  constructor(
    private prisma: PrismaService,
    private fcmService: FcmService,
    private redisService: RedisService,
  ) {}

  async onModuleInit() {
    await this.syncUncreditedCommissions();
  }

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
    await this.syncUncreditedCommissions();
    return this.prisma.lead.findMany({
      where: {
        OR: [
          { agentId: agentId },
          { agent: { agentCode: agentId } },
        ],
      },
      include: { agent: true },
      orderBy: { dateCreated: 'desc' },
    });
  }

  async update(id: string, updateLeadDto: any) {
    const lead = await this.prisma.lead.update({
      where: { id },
      data: updateLeadDto,
      include: { agent: true },
    });

    if (updateLeadDto.status && lead.agentId) {
      await this.checkAndPayCommission(lead);
    }

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

  async checkAndPayCommission(lead: any) {
    if (!lead || !lead.agentId) return;

    let shouldPay = false;
    const sType = (lead.serviceType || '').toLowerCase();
    const status = (lead.status || '').toLowerCase();

    if (sType.includes('loan')) {
      if (['dispatched', 'disbursed'].includes(status)) shouldPay = true;
    } else if (sType.includes('credit')) {
      if (['approved'].includes(status)) shouldPay = true;
    } else if (sType.includes('job')) {
      if (['converted', 'selected', 'approved', 'joined'].includes(status)) shouldPay = true;
    } else if (sType.includes('insur')) {
      if (['approved', 'active'].includes(status)) shouldPay = true;
    } else if (sType.includes('it project') || sType.includes('it')) {
      if (['delivered', 'approved', 'converted'].includes(status)) shouldPay = true;
    } else if (sType.includes('bpo')) {
      if (['approved', 'converted', 'selected'].includes(status)) shouldPay = true;
    } else {
      if (['approved', 'delivered', 'disbursed', 'dispatched'].includes(status)) shouldPay = true;
    }

    if (!shouldPay) return;

    // Check if commission for this lead was already paid
    const existingTx = await this.prisma.transaction.findFirst({
      where: {
        agentId: lead.agentId,
        type: 'DirectCommission',
        description: { contains: lead.id },
      },
    });

    if (existingTx) {
      return;
    }

    let serviceKey = 'Loan';
    if (sType.includes('credit')) serviceKey = 'Credit Card';
    else if (sType.includes('job')) serviceKey = 'Jobs';
    else if (sType.includes('insur')) serviceKey = 'Insurance';
    else if (sType.includes('it project')) serviceKey = 'IT Projects';
    else if (sType.includes('bpo')) serviceKey = 'BPO Services';

    // Get commission rates
    const config = await this.prisma.commissionConfig.findFirst({
      where: { serviceType: { contains: serviceKey, mode: 'insensitive' } },
    });

    const defaults: Record<string, any> = {
      'Loan': { silverRate: 1200, goldRate: 1800, diamondRate: 2200, platinumRate: 2500 },
      'Credit Card': { silverRate: 1000, goldRate: 1500, diamondRate: 1800, platinumRate: 2000 },
      'Jobs': { silverRate: 400, goldRate: 700, diamondRate: 900, platinumRate: 1000 },
      'Insurance': { silverRate: 1500, goldRate: 2200, diamondRate: 2700, platinumRate: 3000 },
      'IT Projects': { silverRate: 3000, goldRate: 4500, diamondRate: 5500, platinumRate: 6000 },
      'BPO Services': { silverRate: 2500, goldRate: 3500, diamondRate: 4500, platinumRate: 5000 },
    };

    const rateConfig = config || defaults[serviceKey] || { silverRate: 500, goldRate: 800, diamondRate: 1000, platinumRate: 1200 };
    const agent = lead.agent || (await this.prisma.agent.findUnique({ where: { id: lead.agentId } }));
    if (!agent) return;

    const tier = (agent.membership || 'Silver').toLowerCase();
    let payout = rateConfig.silverRate ?? 500;
    if (tier === 'platinum') payout = rateConfig.platinumRate ?? payout;
    else if (tier === 'diamond') payout = rateConfig.diamondRate ?? payout;
    else if (tier === 'gold') payout = rateConfig.goldRate ?? payout;

    // Credit Agent Wallet & Total Earnings
    await this.prisma.agent.update({
      where: { id: agent.id },
      data: {
        walletBalance: { increment: payout },
        totalEarnings: { increment: payout },
      },
    });

    // Create Transaction Record
    await this.prisma.transaction.create({
      data: {
        agentId: agent.id,
        amount: payout,
        type: 'DirectCommission',
        status: 'Success',
        description: `Direct Comm. for approved lead #${lead.id} (${lead.customerName || 'Customer'})`,
      },
    });

    this.logger.log(`Credited ₹${payout} commission to Agent ${agent.agentCode} for lead ${lead.id}`);
    try {
      await this.redisService.del('agents:all');
    } catch (_) {}

    // Send push notification to agent for commission credited
    if (agent.fcmToken) {
      this.fcmService.sendToDevice(
        agent.fcmToken,
        '💰 Commission Credited!',
        `Congratulations! You earned a direct commission of ₹${payout} for ${lead.serviceType || 'Loan'} lead "${lead.customerName || 'Customer'}"!`,
        { leadId: lead.id, type: 'COMMISSION_CREDITED', amount: payout.toString() },
      ).catch(err => this.logger.error(`Commission notification failed: ${err.message}`));
    }
  }

  async syncUncreditedCommissions() {
    try {
      const eligibleLeads = await this.prisma.lead.findMany({
        include: { agent: true },
      });

      for (const lead of eligibleLeads) {
        await this.checkAndPayCommission(lead);
      }
    } catch (e: any) {
      this.logger.error(`Error backfilling commissions: ${e.message}`);
    }
  }

  async remove(id: string) {
    return this.prisma.lead.delete({
      where: { id },
    });
  }
}
