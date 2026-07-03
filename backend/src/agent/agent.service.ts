import { Injectable, NotFoundException, UnauthorizedException, ConflictException, InternalServerErrorException, Logger } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { EmailService } from '../email/email.service';
import * as crypto from 'crypto';

@Injectable()
export class AgentService {
  private readonly logger = new Logger(AgentService.name);

  constructor(
    private prisma: PrismaService,
    private emailService: EmailService,
  ) {}

  private generateAgentCode(): string {
    return 'FIC' + (Math.floor(Math.random() * 8999) + 1000);
  }

  async create(createAgentDto: any) {
    this.logger.log(`Creating agent with email: ${createAgentDto.email}`);
    const { referredBy, ...rest } = createAgentDto;
    let referredById = null;

    try {
      // Check for duplicate email
      const existingEmail = await this.prisma.agent.findUnique({ where: { email: rest.email } });
      if (existingEmail) {
        throw new ConflictException('An agent with this email already exists');
      }

      // Check for duplicate phone
      if (rest.phoneNumber) {
        const existingPhone = await this.prisma.agent.findUnique({ where: { phoneNumber: rest.phoneNumber } });
        if (existingPhone) {
          throw new ConflictException('An agent with this phone number already exists');
        }
      }

      if (referredBy) {
        const referrer = await this.prisma.agent.findUnique({
          where: { agentCode: referredBy }
        });
        if (referrer) {
          referredById = referrer.id;
        }
      }

      // Generate a unique agentCode (retry on collision)
      let agentCode = rest.agentCode || this.generateAgentCode();
      let codeAttempts = 0;
      while (codeAttempts < 5) {
        const existing = await this.prisma.agent.findUnique({ where: { agentCode } });
        if (!existing) break;
        agentCode = this.generateAgentCode();
        codeAttempts++;
      }

      const verificationToken = crypto.randomBytes(32).toString('hex');

      const dataToCreate: any = { ...rest, agentCode, verificationToken };
      if (referredById) dataToCreate.referredById = referredById;

      const createdAgent = await this.prisma.agent.create({ data: dataToCreate });

      this.logger.log(`Agent created successfully: ${createdAgent.id}`);

      // Send verification email asynchronously (don't block registration)
      this.emailService.sendVerificationEmail(createdAgent.email, verificationToken)
        .catch(err => this.logger.error(`Failed to send verification email: ${err.message}`));

      return {
        ...createdAgent,
        referredBy: referredBy || null,
      };
    } catch (e) {
      if (e instanceof ConflictException) throw e;
      this.logger.error(`Failed to create agent: ${e.message}`, e.stack);
      throw new InternalServerErrorException(`Registration failed: ${e.message}`);
    }
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
