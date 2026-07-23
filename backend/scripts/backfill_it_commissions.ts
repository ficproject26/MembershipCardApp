import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function backfill() {
  console.log('Starting IT Projects & Delivered leads commission backfill...');

  const leads = await prisma.lead.findMany({
    include: { agent: true }
  });

  const configs = await prisma.commissionConfig.findMany();
  console.log(`Found ${leads.length} total leads and ${configs.length} commission configs.`);

  const defaults: Record<string, any> = {
    'Loan': { silverRate: 1200, goldRate: 1800, diamondRate: 2200, platinumRate: 2500 },
    'Credit Card': { silverRate: 1000, goldRate: 1500, diamondRate: 1800, platinumRate: 2000 },
    'Jobs': { silverRate: 400, goldRate: 700, diamondRate: 900, platinumRate: 1000 },
    'Insurance': { silverRate: 1500, goldRate: 2200, diamondRate: 2700, platinumRate: 3000 },
    'IT Projects': { silverRate: 3000, goldRate: 4500, diamondRate: 5500, platinumRate: 6000 },
    'BPO Services': { silverRate: 2500, goldRate: 3500, diamondRate: 4500, platinumRate: 5000 },
  };

  let creditedCount = 0;

  for (const lead of leads) {
    if (!lead.agentId) continue;

    const sType = (lead.serviceType || '').toLowerCase();
    const status = (lead.status || '').toLowerCase();

    let shouldPay = false;
    if (sType.includes('loan')) {
      if (['dispatched', 'disbursed', 'approved', 'stage3approved'].includes(status)) shouldPay = true;
    } else if (sType.includes('credit')) {
      if (['approved', 'stage1approved', 'stage2approved', 'stage3approved'].includes(status)) shouldPay = true;
    } else if (sType.includes('job')) {
      if (['converted', 'selected', 'approved', 'joined'].includes(status)) shouldPay = true;
    } else if (sType.includes('insur')) {
      if (['approved', 'stage1approved', 'stage2approved', 'stage3approved', 'active'].includes(status)) shouldPay = true;
    } else if (sType.includes('it project') || sType.includes('it')) {
      if (['delivered', 'stage2approved', 'stage3approved', 'approved', 'converted'].includes(status)) shouldPay = true;
    } else if (sType.includes('bpo')) {
      if (['approved', 'converted', 'selected'].includes(status)) shouldPay = true;
    } else {
      if (['approved', 'delivered', 'disbursed', 'dispatched'].includes(status)) shouldPay = true;
    }

    if (!shouldPay) continue;

    // Check existing transaction
    const existingTx = await prisma.transaction.findFirst({
      where: {
        agentId: lead.agentId,
        type: 'DirectCommission',
        description: { contains: lead.id }
      }
    });

    if (existingTx) {
      console.log(`Lead ${lead.id} (${lead.serviceType} - ${lead.status}) already credited.`);
      continue;
    }

    let serviceKey = 'Loan';
    if (sType.includes('credit')) serviceKey = 'Credit Card';
    else if (sType.includes('job')) serviceKey = 'Jobs';
    else if (sType.includes('insur')) serviceKey = 'Insurance';
    else if (sType.includes('it project') || sType.includes('it')) serviceKey = 'IT Projects';
    else if (sType.includes('bpo')) serviceKey = 'BPO Services';

    const config = configs.find(c => c.serviceType.toLowerCase().includes(serviceKey.toLowerCase()));
    const rateConfig = config || defaults[serviceKey] || { silverRate: 3000, goldRate: 4500, diamondRate: 5500, platinumRate: 6000 };

    const agent = lead.agent || await prisma.agent.findUnique({ where: { id: lead.agentId } });
    if (!agent) continue;

    const tier = (agent.membership || 'Silver').toLowerCase();
    let payout = rateConfig.silverRate || 3000;
    if (tier === 'platinum') payout = rateConfig.platinumRate || 6000;
    else if (tier === 'diamond') payout = rateConfig.diamondRate || 5500;
    else if (tier === 'gold') payout = rateConfig.goldRate || 4500;

    await prisma.agent.update({
      where: { id: agent.id },
      data: {
        walletBalance: { increment: payout },
        totalEarnings: { increment: payout },
      }
    });

    await prisma.transaction.create({
      data: {
        agentId: agent.id,
        amount: payout,
        type: 'DirectCommission',
        status: 'Success',
        description: `Direct Comm. for approved lead #${lead.id} (${lead.customerName || 'Customer'})`,
      }
    });

    creditedCount++;
    console.log(`✅ Credited ₹${payout} to Agent ${agent.agentCode} (${agent.name}) for Lead ${lead.id} (${lead.serviceType} - ${lead.status})`);
  }

  console.log(`Backfill complete. Credited ${creditedCount} missing commissions.`);
  await prisma.$disconnect();
}

backfill().catch(e => {
  console.error(e);
  prisma.$disconnect();
});
