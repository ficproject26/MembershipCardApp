import { Controller, Get, Query, BadRequestException } from '@nestjs/common';
import { AgoraService } from './agora.service';
import { RtcRole } from 'agora-token';

@Controller('agora')
export class AgoraController {
  constructor(private readonly agoraService: AgoraService) {}

  @Get('rtcToken')
  getRtcToken(
    @Query('channelName') channelName: string,
    @Query('uid') uidStr: string,
  ) {
    if (!channelName) {
      throw new BadRequestException('channelName is required');
    }
    const uid = uidStr ? parseInt(uidStr, 10) : 0;
    const token = this.agoraService.generateRtcToken(channelName, uid, RtcRole.PUBLISHER);
    return { token };
  }
}
