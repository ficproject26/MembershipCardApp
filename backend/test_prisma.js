const { PrismaClient } = require('@prisma/client');
const { PrismaBetterSqlite3 } = require('@prisma/adapter-better-sqlite3');
const path = require('path');
const Database = require('better-sqlite3');

const dbPath = path.resolve(__dirname, 'dev.db');
const sqlite = new Database(dbPath);
const adapter = new PrismaBetterSqlite3(sqlite);
const prisma = new PrismaClient({ adapter });

async function main() {
  try {
    const res = await prisma.message.create({
      data: {
        senderId: 'admin',
        senderType: 'Admin',
        receiverId: 'guru',
        receiverType: 'Agent',
        content: 'Test message DB',
      },
    });
    console.log('Created:', res);
  } catch (err) {
    console.error('Error:', err);
  } finally {
    await prisma.$disconnect();
  }
}
main();
