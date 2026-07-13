import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  OnGatewayConnection,
  OnGatewayDisconnect,
  MessageBody,
  ConnectedSocket,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { ChatService } from './chat.service';

@WebSocketGateway({
  cors: {
    origin: '*',
  },
})
export class ChatGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;

  // Map to store userId -> Socket ID
  private connectedUsers = new Map<string, string>();

  constructor(private readonly chatService: ChatService) {}

  handleConnection(client: Socket) {
    console.log(`Client connected: ${client.id}`);
  }

  handleDisconnect(client: Socket) {
    console.log(`Client disconnected: ${client.id}`);
    for (const [userId, socketId] of this.connectedUsers.entries()) {
      if (socketId === client.id) {
        this.connectedUsers.delete(userId);
        break;
      }
    }
  }

  @SubscribeMessage('join')
  handleJoin(@MessageBody() data: { userId: string }, @ConnectedSocket() client: Socket) {
    this.connectedUsers.set(data.userId, client.id);
    console.log(`User ${data.userId} joined with socket ${client.id}`);
    return { status: 'joined' };
  }

  @SubscribeMessage('sendMessage')
  async handleSendMessage(
    @MessageBody()
    data: {
      senderId: string;
      senderType: string;
      receiverId: string;
      receiverType: string;
      content: string;
      type?: string;
      mediaUrl?: string;
    },
    @ConnectedSocket() client: Socket,
  ) {
    // Save message to DB
    const message = await this.chatService.saveMessage(data);

    // If receiver is connected, send it to them
    const receiverSocketId = this.connectedUsers.get(data.receiverId);
    if (receiverSocketId) {
      this.server.to(receiverSocketId).emit('newMessage', message);
    }
    
    // Also echo it back to the sender so their UI can confirm delivery
    client.emit('newMessage', message);

    return message;
  }

  @SubscribeMessage('webrtc-signaling')
  handleWebRTCSignaling(
    @MessageBody() data: { to: string; type: string; payload?: any; callerId?: string; callerName?: string; callerType?: string; isVideo?: boolean },
    @ConnectedSocket() client: Socket,
  ) {
    const receiverSocketId = this.connectedUsers.get(data.to);
    if (receiverSocketId) {
      this.server.to(receiverSocketId).emit('webrtc-signaling', data);
    } else {
      // If receiver is offline and someone is calling them
      if (data.type === 'call-initiate') {
        client.emit('webrtc-signaling', { type: 'call-reject', reason: 'User offline' });
      }
    }
  }
}
