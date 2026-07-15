import { Controller, Get, Post, Param, UseInterceptors, UploadedFile } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import { extname } from 'path';
import { ChatService } from './chat.service';

@Controller('chat')
export class ChatController {
  constructor(private readonly chatService: ChatService) {}

  @Get(':user1Id/:user2Id')
  async getMessages(
    @Param('user1Id') user1Id: string,
    @Param('user2Id') user2Id: string,
  ) {
    return this.chatService.getMessages(user1Id, user2Id);
  }

  @Get('recent/:userId')
  async getRecentChats(@Param('userId') userId: string) {
    return this.chatService.getRecentChats(userId);
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
  async uploadMedia(@UploadedFile() file: Express.Multer.File) {
    const mediaUrl = `/uploads/${file.filename}`;
    return { mediaUrl };
  }
}
