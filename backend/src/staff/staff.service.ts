import { Injectable, NotFoundException, UnauthorizedException } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { Prisma } from '@prisma/client';

@Injectable()
export class StaffService {
  constructor(private prisma: PrismaService) {}

  async create(data: Prisma.StaffCreateInput) {
    return this.prisma.staff.create({
      data,
    });
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
}
