const fs = require('fs');
let schema = fs.readFileSync('prisma/schema.prisma', 'utf-8');

schema = schema.replace(/provider = "mongodb"/g, 'provider = "sqlite"');
schema = schema.replace(/@map\("_id"\) @db\.ObjectId/g, '@default(uuid())');
schema = schema.replace(/@db\.ObjectId/g, '');

fs.writeFileSync('prisma/schema.prisma', schema);
console.log('Schema updated for SQLite');
