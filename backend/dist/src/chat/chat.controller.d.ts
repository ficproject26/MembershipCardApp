import { ChatService } from './chat.service';
export declare class ChatController {
    private readonly chatService;
    constructor(chatService: ChatService);
    getMessages(user1Id: string, user2Id: string): Promise<any>;
    uploadMedia(file: Express.Multer.File): Promise<{
        mediaUrl: string;
    }>;
}
