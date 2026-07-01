import { Controller, Get, Post, Delete, Param, Body, UseInterceptors, UploadedFile } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import { extname } from 'path';
import { StatusService } from './status.service';

@Controller('status')
export class StatusController {
  constructor(private readonly statusService: StatusService) {}

  @Get()
  async getActiveStatuses() {
    return this.statusService.getActiveStatuses();
  }

  @Post()
  async createStatus(
    @Body() body: { userId: string; userName: string; content: string },
  ) {
    return this.statusService.createStatus(body.userId, body.userName, body.content, 'TEXT');
  }

  @Post('media')
  @UseInterceptors(FileInterceptor('file', {
    storage: diskStorage({
      destination: './uploads',
      filename: (req, file, cb) => {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
        cb(null, `${uniqueSuffix}${extname(file.originalname)}`);
      },
    }),
  }))
  async createMediaStatus(
    @UploadedFile() file: Express.Multer.File,
    @Body() body: { userId: string; userName: string; content?: string; type: string },
  ) {
    const mediaUrl = `/uploads/${file.filename}`;
    return this.statusService.createStatus(body.userId, body.userName, body.content || '', body.type, mediaUrl);
  }

  @Delete(':id')
  async deleteStatus(@Param('id') id: string) {
    return this.statusService.deleteStatus(id);
  }
}
