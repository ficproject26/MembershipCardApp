import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function fixCreditCardCommissions() {
  console.log('Checking Credit Card Stage1/Stage2 & duplicate transactions...');

  // 1. Find all Credit Card leads that are NOT final Approved
  const stageLeads = await prisma.lead.findMany({
    where: {
      serviceType: { contains: 'Credit Card', mode: 'insensitive' },
      status: { notIn: ['Approved', 'approved'] }
    }
  });

  console.log(`Found ${stageLeads.length} Credit Card leads not in final Approved state.`);

  let revertedCount = 0;
  for (const lead of stageLeads) {
    if (!lead.agentId) continue;

    const txs = await prisma.transaction.findMany({
      where: {
        agentId: lead.agentId,
        type: 'DirectCommission',
        description: { contains: lead.id }
      }
    });

    for (const tx of txs) {
      console.log(`Reverting Tx ${tx.id} of ₹${tx.amount} for Agent ${lead.agentId} on Lead ${lead.id} (${lead.status})`);
      
      await prisma.agent.update({
        where: { id: lead.agentId },
        data: {
          walletBalance: { decrement: tx.amount },
          totalEarnings: { decrement: tx.amount }
        }
      });

      await prisma.transaction.delete({
        where: { id: tx.id }
      });

      revertedCount++;
    }
  }

  // 2. Remove duplicate transactions for ALL leads (keep only 1 per lead)
  const allLeads = await prisma.lead.findMany();
  for (const lead of allLeads) {
    if (!lead.agentId) continue;

    const txs = await prisma.transaction.findMany({
      where: {
        agentId: lead.agentId,
        type: 'DirectCommission',
        description: { contains: lead.id }
      },
      orderBy: { date: 'asc' }
    });

    if (txs.length > 1) {
      // Keep the first transaction, delete the rest and deduct from wallet
      for (let i = 1; i < txs.length; i++) {
        const dupTx = txs[i];
        console.log(`Reverting duplicate Tx ${dupTx.id} of ₹${dupTx.amount} for Lead ${lead.id}`);

        await prisma.agent.update({
          where: { id: lead.agentId },
          data: {
            walletBalance: { decrement: dupTx.amount },
            totalEarnings: { decrement: dupTx.amount }
          }
        });

        await prisma.transaction.delete({
          where: { id: dupTx.id }
        });

        revertedCount++;
      }
    }
  }

  console.log(`Cleanup complete. Reverted/deleted ${revertedCount} incorrect/duplicate commission transactions.`);
  await prisma.$disconnect();
}

fixCreditCardCommissions().catch(e => {
  console.error(e);
  prisma.$disconnect();
});
