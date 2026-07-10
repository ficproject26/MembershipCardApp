import { WebSocketGateway, WebSocketServer } from '@nestjs/websockets';
import { Server } from 'socket.io';

@WebSocketGateway({ cors: { origin: '*' } })
export class SystemGateway {
  @WebSocketServer()
  server: Server;

  broadcastDataChanged(model: string, action: string) {
    if (this.server) {
      this.server.emit('system_data_changed', { model, action });
    }
  }
}
