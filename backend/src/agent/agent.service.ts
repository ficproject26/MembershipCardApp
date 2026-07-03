import { Injectable, NotFoundException, UnauthorizedException, ConflictException, InternalServerErrorException, Logger, HttpException, HttpStatus } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { QueueService } from '../queue/queue.service';
import { RedisService } from '../redis/redis.service';
import * as crypto from 'crypto';

@Injectable()
export class AgentService {
  private readonly logger = new Logger(AgentService.name);

  constructor(
    private prisma: PrismaService,
    private queueService: QueueService,
    private redisService: RedisService,
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

      // Send verification email asynchronously via BullMQ
      this.queueService.sendVerificationEmail(createdAgent.email, verificationToken);

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

  async login(email: string, password?: string, clientIp: string = 'unknown') {
    const rateLimitKey = `login_attempts:${clientIp}`;
    const attemptsStr = await this.redisService.get(rateLimitKey);
    let attempts = attemptsStr ? parseInt(attemptsStr, 10) : 0;

    if (attempts >= 5) {
      throw new HttpException('Too many failed login attempts. Please try again in 15 minutes.', HttpStatus.TOO_MANY_REQUESTS);
    }

    const agent = await this.prisma.agent.findUnique({
      where: { email },
    });
    
    if (!agent) {
      // Record failed attempt
      attempts += 1;
      await this.redisService.set(rateLimitKey, attempts.toString(), 15 * 60); // 15 mins
      throw new NotFoundException('No agent account found with this email');
    }
    
    if (!agent.password || agent.password !== password) {
      // Record failed attempt
      attempts += 1;
      await this.redisService.set(rateLimitKey, attempts.toString(), 15 * 60);
      throw new UnauthorizedException('Invalid password');
    }

    // Success! Clear failed attempts
    await this.redisService.del(rateLimitKey);
    return agent;
  }

  async findAll() {
    const cachedAgents = await this.redisService.get('agents:all');
    if (cachedAgents) {
      this.logger.log('Returning agents from cache');
      return JSON.parse(cachedAgents);
    }

    const agents = await this.prisma.agent.findMany();
    await this.redisService.set('agents:all', JSON.stringify(agents), 60); // Cache for 60s
    return agents;
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
