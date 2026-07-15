import { Injectable, NotFoundException, UnauthorizedException, ConflictException } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { Prisma } from '@prisma/client';

@Injectable()
export class StaffService {
  constructor(private prisma: PrismaService) {}

  async create(data: Prisma.StaffCreateInput) {
    try {
      return await this.prisma.staff.create({
        data,
      });
    } catch (error: any) {
      if (error.code === 'P2002') {
        throw new ConflictException('A staff member with this email or phone number already exists.');
      }
      throw error;
    }
  }

  async findAll() {
    return this.prisma.staff.findMany({
      orderBy: { dateJoined: 'desc' },
    });
  }

  async findOne(id: string) {
    const staff = await this.prisma.staff.findUnique({
      where: { id },
    });
    if (!staff) throw new NotFoundException('Staff not found');
    return staff;
  }

  async login(email: string, password: string) {
    const staff = await this.prisma.staff.findUnique({
      where: { email },
    });
    if (!staff) throw new NotFoundException('No staff account found with this email');
    if (!staff.password || staff.password !== password) {
      throw new UnauthorizedException('Invalid password');
    }
    // Return staff without password
    const { password: _, ...staffWithoutPassword } = staff;
    return staffWithoutPassword;
  }

  async update(id: string, data: Prisma.StaffUpdateInput) {
    return this.prisma.staff.update({
      where: { id },
      data,
    });
  }

  async remove(id: string) {
    return this.prisma.staff.delete({
      where: { id },
    });
  }

  async getHrDashboardStats() {
    const totalReferrals = await this.prisma.lead.count();
    const pendingApplications = await this.prisma.lead.count({ where: { status: 'Pending' } });
    const inProcess = await this.prisma.lead.count({ where: { status: 'In Process' } });
    const selectedCandidates = await this.prisma.lead.count({ where: { status: 'Selected' } });
    
    const appliedCount = await this.prisma.lead.count({ where: { status: 'Applied' } });
    const screeningCount = await this.prisma.lead.count({ where: { status: 'Screening' } });
    const interviewCount = await this.prisma.lead.count({ where: { status: 'Interview' } });
    const joinedCount = await this.prisma.lead.count({ where: { status: 'Joined' } });

    const recentApplications = await this.prisma.lead.findMany({
      take: 5,
      orderBy: { dateCreated: 'desc' },
      include: { agent: true }
    });

    const topAgentGroups = await this.prisma.lead.groupBy({
      by: ['agentId'],
      _count: { agentId: true },
      orderBy: { _count: { agentId: 'desc' } },
      take: 5,
    });
    
    const agentIds = topAgentGroups.map((g: any) => g.agentId);
    const agents = await this.prisma.agent.findMany({
      where: { id: { in: agentIds } }
    });
    
    const topPerformingAgents = topAgentGroups.map((g: any) => {
      const agent = agents.find((a: any) => a.id === g.agentId);
      return {
        name: agent ? `${agent.agentCode} (${agent.name.split(' ')[0]})` : 'Unknown',
        referrals: g._count.agentId
      };
    });

    return {
      kpi: {
        totalReferrals,
        pendingApplications,
        inProcess,
        selectedCandidates
      },
      pipeline: {
        applied: appliedCount,
        screening: screeningCount,
        interview: interviewCount,
        selected: selectedCandidates,
        joined: joinedCount
      },
      recentApplications: recentApplications.map((l: any) => ({
        id: l.id,
        name: l.customerName || 'Unknown',
        role: l.serviceType,
        mobile: l.customerPhone || 'N/A',
        date: l.dateCreated.toISOString().split('T')[0],
        agent: l.agent ? `${l.agent.agentCode} (${l.agent.name.split(' ')[0]})` : 'Unknown',
        status: l.status
      })),
      topAgents: topPerformingAgents
    };
  }
}
