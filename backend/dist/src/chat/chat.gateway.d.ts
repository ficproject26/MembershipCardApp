import { OnGatewayConnection, OnGatewayDisconnect } from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { ChatService } from './chat.service';
export declare class ChatGateway implements OnGatewayConnection, OnGatewayDisconnect {
    private readonly chatService;
    server: Server;
    private connectedUsers;
    constructor(chatService: ChatService);
    handleConnection(client: Socket): void;
    handleDisconnect(client: Socket): void;
    handleJoin(data: {
        userId: string;
    }, client: Socket): {
        status: string;
    };
    handleSendMessage(data: {
        senderId: string;
        senderType: string;
        receiverId: string;
        receiverType: string;
        content: string;
        type?: string;
        mediaUrl?: string;
    }, client: Socket): Promise<any>;
}
