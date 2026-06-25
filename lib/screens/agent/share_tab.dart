import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../providers/app_state_provider.dart';
import '../../widgets/glass_card.dart';

class AgentShareTab extends StatelessWidget {
  const AgentShareTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final agent = state.currentAgent!;
    final isDark = state.isDarkMode;

    final String referralLink = 'https://ficclub.in/join?ref=${agent.agentCode}';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Elegant QR Sharing Card
          GlassCard(
            padding: const EdgeInsets.all(24),
            borderColor: const Color(0xFFFFC107),
            borderOpacity: 0.25,
            child: Column(
              children: [
                Text(
                  'Your referral QR Code',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1A3B6E),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Scan this QR code to join under your network directly',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // QR Display
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: QrImageView(
                    data: referralLink,
                    version: QrVersions.auto,
                    size: 200.0,
                    gapless: false,
                    foregroundColor: const Color(0xFF1A3B6E),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Agent Reference Code',
                  style: TextStyle(fontSize: 10, color: isDark ? Colors.white38 : Colors.black38),
                ),
                Text(
                  agent.agentCode,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: isDark ? Colors.white : const Color(0xFF1A3B6E),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Referral Link box
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Referral Link',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : const Color(0xFF1A3B6E),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
                        ),
                        child: Text(
                          referralLink,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : Colors.black87),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A3B6E),
                        padding: const EdgeInsets.all(12),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        // Simulated copy to clipboard
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Referral link copied to clipboard!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      child: const Icon(Icons.copy, color: Colors.white, size: 18),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
