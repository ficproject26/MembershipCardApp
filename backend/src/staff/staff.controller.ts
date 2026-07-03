import { Controller, Get, Post, Body, Patch, Param, Delete } from '@nestjs/common';
import { StaffService } from './staff.service';
import { Prisma } from '@prisma/client';

@Controller('staff')
export class StaffController {
  constructor(private readonly staffService: StaffService) {}

  @Post()
  create(@Body() createStaffDto: Prisma.StaffCreateInput) {
    return this.staffService.create(createStaffDto);
  }

  @Post('login')
  login(@Body() body: { email: string; password: string }) {
    return this.staffService.login(body.email, body.password);
  }

  @Get('hr-dashboard/stats')
  getHrDashboardStats() {
    return this.staffService.getHrDashboardStats();
  }

  @Get()
  findAll() {
    return this.staffService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.staffService.findOne(id);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() updateStaffDto: Prisma.StaffUpdateInput) {
    return this.staffService.update(id, updateStaffDto);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.staffService.remove(id);
  }
}
