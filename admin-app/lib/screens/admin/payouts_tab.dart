import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';

class AdminPayoutsTab extends StatelessWidget {
  const AdminPayoutsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final isDark = state.isDarkMode;

    final pendingPayouts = state.transactions
        .where((t) => t.type == TransactionType.Withdrawal && t.status == TransactionStatus.Pending)
        .toList();
    final processedPayouts = state.transactions
        .where((t) => t.type == TransactionType.Withdrawal && t.status != TransactionStatus.Pending)
        .toList();

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            labelColor: const Color(0xFFFFC107),
            unselectedLabelColor: isDark ? Colors.white70 : Colors.black54,
            indicatorColor: const Color(0xFFFFC107),
            tabs: [
              Tab(text: 'Pending Requests (${pendingPayouts.length})'),
              Tab(text: 'Payouts History (${processedPayouts.length})'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildPayoutList(context, pendingPayouts, true, state, isDark),
                _buildPayoutList(context, processedPayouts, false, state, isDark),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPayoutList(
    BuildContext context,
    List<TransactionModel> list,
    bool isPending,
    AppStateProvider state,
    bool isDark,
  ) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isPending ? Icons.check_circle_outline : Icons.history, color: const Color(0xFFFFC107), size: 48),
            const SizedBox(height: 12),
            Text(
              isPending ? 'No pending withdrawal requests' : 'No payout history found',
              style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, idx) {
        final tx = list[idx];
        return GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Agent: ${tx.agentCode}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1A3B6E),
                    ),
                  ),
                  Text(
                    '₹${tx.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.greenAccent : Colors.green[800],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                tx.description,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
              Text(
                'Requested: ${tx.date.toString().split('.')[0]}',
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
              if (isPending) ...[
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent),
                      ),
                      onPressed: () {
                        state.processPayout(tx.id, TransactionStatus.Rejected);
                      },
                      child: const Text('Reject & Refund'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: () {
                        state.processPayout(tx.id, TransactionStatus.Success);
                      },
                      child: const Text('Approve & Pay Out', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ] else ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      tx.status == TransactionStatus.Success ? Icons.check_circle : Icons.cancel,
                      color: tx.status == TransactionStatus.Success ? Colors.green : Colors.redAccent,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      tx.status == TransactionStatus.Success ? 'Completed' : 'Rejected',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: tx.status == TransactionStatus.Success ? Colors.green : Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ]
            ],
          ),
        ).marginOnly(bottom: 12);
      },
    );
  }
}
