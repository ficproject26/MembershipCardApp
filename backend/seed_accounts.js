const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

async function main() {
  console.log('Seeding demo accounts...');

  // Seed Agents
  const agents = [
    {
      name: 'John Doe',
      email: 'john@fic.com',
      phoneNumber: '9876543210',
      agentCode: 'FIC1001',
      password: 'password',
      membership: 'Gold',
      walletBalance: 1250.0,
      totalEarnings: 5000.0,
      kycStatus: 'Approved',
      aadhaarNumber: '123456789012',
      panNumber: 'ABCDE1234F',
    },
    {
      name: 'Jane Smith',
      email: 'jane@fic.com',
      phoneNumber: '9876543211',
      agentCode: 'FIC1002',
      password: 'password',
      membership: 'Platinum',
      walletBalance: 4500.0,
      totalEarnings: 12000.0,
      kycStatus: 'Pending',
      aadhaarNumber: '234567890123',
      panNumber: 'BCDEF2345G',
    },
  ];

  for (const agent of agents) {
    await prisma.agent.upsert({
      where: { email: agent.email },
      update: agent,
      create: agent,
    });
  }

  // Seed Staff
  const staffs = [
    {
      name: 'Alice Johnson',
      email: 'alice@fic.com',
      phoneNumber: '8765432100',
      role: 'HR',
      password: 'password',
    },
    {
      name: 'Bob Wilson',
      email: 'bob@fic.com',
      phoneNumber: '8765432101',
      role: 'KYC',
      password: 'password',
    },
    {
      name: 'Charlie Davis',
      email: 'charlie@fic.com',
      phoneNumber: '8765432102',
      role: 'CreditCardTL',
      password: 'password',
    },
  ];

  for (const staff of staffs) {
    await prisma.staff.upsert({
      where: { email: staff.email },
      update: staff,
      create: staff,
    });
  }

  console.log('Demo accounts seeded successfully!');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
