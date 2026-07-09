import { Controller, Get, Put, Body, Param } from '@nestjs/common';
import { CommissionService } from './commission.service';

@Controller('commission')
export class CommissionController {
  constructor(private readonly commissionService: CommissionService) {}

  @Get()
  findAll() {
    return this.commissionService.findAll();
  }

  @Put(':serviceType')
  update(@Param('serviceType') serviceType: string, @Body() updateDto: any) {
    return this.commissionService.update(serviceType, updateDto);
  }
}
