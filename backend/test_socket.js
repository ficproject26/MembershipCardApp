const io = require('socket.io-client');

const socket = io('http://localhost:3001', { transports: ['websocket'] });

socket.on('connect', () => {
  console.log('Connected to server');
  socket.emit('join', { userId: 'admin' });

  setTimeout(() => {
    console.log('Sending message...');
    socket.emit('sendMessage', {
      senderId: 'admin',
      senderType: 'Admin',
      receiverId: 'guru',
      receiverType: 'Agent',
      content: 'Hello from test',
    });
  }, 1000);
});

socket.on('newMessage', (msg) => {
  console.log('Received message:', msg);
  process.exit(0);
});

socket.on('connect_error', (err) => {
  console.error('Connection Error:', err);
  process.exit(1);
});
