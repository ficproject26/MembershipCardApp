import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';

class AdminCommissionTab extends StatelessWidget {
  const AdminCommissionTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final isDark = state.isDarkMode;

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: state.commissions.length,
      itemBuilder: (context, idx) {
        final comm = state.commissions[idx];

        final TextEditingController directController =
            TextEditingController(text: (comm.directRate * 100).toStringAsFixed(1));
        final TextEditingController indirectController =
            TextEditingController(text: (comm.indirectRate * 100).toStringAsFixed(1));

        return GlassCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A3B6E).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.percent_rounded, color: const Color(0xFFFFC107), size: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            comm.serviceType,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF1A3B6E),
                            ),
                          ),
                          Text(
                            'Configured Commission Rates',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.white60 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC107),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      final double? directVal = double.tryParse(directController.text);
                      final double? indirectVal = double.tryParse(indirectController.text);
                      if (directVal != null && indirectVal != null) {
                        state.updateCommission(
                          comm.serviceType,
                          directVal / 100.0,
                          indirectVal / 100.0,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${comm.serviceType} Commission Configured!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                    child: const Text('Update', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Direct (Level 1) Rate (%)',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFFFFC107)),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: directController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            suffixText: '%',
                            isDense: true,
                            contentPadding: const EdgeInsets.all(10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Indirect (Level 2) Rate (%)',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFFFFC107)),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: indirectController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            suffixText: '%',
                            isDense: true,
                            contentPadding: const EdgeInsets.all(10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ).marginOnly(bottom: 16);
      },
    );
  }
}
