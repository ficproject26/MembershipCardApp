import { Injectable, NotFoundException, UnauthorizedException } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { EmailService } from '../email/email.service';
import * as crypto from 'crypto';

@Injectable()
export class AgentService {
  constructor(
    private prisma: PrismaService,
    private emailService: EmailService,
  ) {}

  async create(createAgentDto: any) {
    const { referredBy, ...rest } = createAgentDto;
    let referredById = null;
    
    if (referredBy) {
      const referrer = await this.prisma.agent.findUnique({
        where: { agentCode: referredBy }
      });
      if (referrer) {
        referredById = referrer.id;
      }
    }

    const verificationToken = crypto.randomBytes(32).toString('hex');

    const createdAgent = await this.prisma.agent.create({
      data: {
        ...rest,
        ...(referredById ? { referredById } : {}),
        verificationToken,
      },
    });

    // Send verification email asynchronously
    this.emailService.sendVerificationEmail(createdAgent.email, verificationToken);

    return {
      ...createdAgent,
      referredBy: referredBy || null,
    };
  }

  async login(email: string, password?: string) {
    const agent = await this.prisma.agent.findUnique({
      where: { email },
    });
    if (!agent) {
      throw new NotFoundException('No agent account found with this email');
    }
    if (!agent.password || agent.password !== password) {
      throw new UnauthorizedException('Invalid password');
    }
    return agent;
  }

  async findAll() {
    return this.prisma.agent.findMany();
  }

  async findOne(id: string) {
    return this.prisma.agent.findUnique({
      where: { id },
    });
  }

  async findByPhone(phoneNumber: string) {
    return this.prisma.agent.findUnique({
      where: { phoneNumber },
    });
  }

  async update(id: string, updateAgentDto: any) {
    return this.prisma.agent.update({
      where: { id },
      data: updateAgentDto,
    });
  }

  async remove(id: string) {
    return this.prisma.agent.delete({
      where: { id },
    });
  }
}
