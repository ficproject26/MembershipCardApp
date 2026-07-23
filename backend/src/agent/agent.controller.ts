import { Controller, Get, Post, Body, Patch, Param, Delete, Ip, Headers } from '@nestjs/common';
import { AgentService } from './agent.service';
import { CreateAgentDto } from './dto/create-agent.dto';
import { UpdateAgentDto } from './dto/update-agent.dto';

@Controller('agent')
export class AgentController {
  constructor(private readonly agentService: AgentService) {}

  @Post()
  create(@Body() createAgentDto: CreateAgentDto) {
    return this.agentService.create(createAgentDto);
  }

  @Post('login')
  login(
    @Body() body: { email?: string; emailOrPhone?: string; password?: string },
    @Ip() ip: string,
    @Headers('x-forwarded-for') forwardedIp?: string
  ) {
    const clientIp = forwardedIp || ip || 'unknown';
    const identifier = body.emailOrPhone || body.email || '';
    return this.agentService.login(identifier, body.password, clientIp);
  }

  @Get()
  findAll() {
    return this.agentService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.agentService.findOne(id);
  }

  @Get(':id/transactions')
  getTransactions(@Param('id') id: string) {
    return this.agentService.getAgentTransactions(id);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() updateAgentDto: UpdateAgentDto) {
    return this.agentService.update(id, updateAgentDto);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.agentService.remove(id);
  }
}
