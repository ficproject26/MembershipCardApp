import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';

class AdminMembershipTab extends StatelessWidget {
  const AdminMembershipTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final isDark = state.isDarkMode;
    final activeCount = state.vipCodes.where((v) => !v.isUsed).length;
    final usedCount = state.vipCodes.where((v) => v.isUsed).length;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        // ── 1-TIME SINGLE-USE VIP CODE GENERATOR ────────────────────────────
        GlassCard(
          padding: const EdgeInsets.all(18),
          borderColor: const Color(0xFFFFC107),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.vpn_key, color: Color(0xFFFFC107), size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '1-Time Single-Use VIP Pass Codes',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Generate 1-Time single-use VIP promo codes for special agents. Each code can be redeemed only 1 time for free Platinum membership.',
                style: TextStyle(color: isDark ? Colors.white60 : Colors.black54, fontSize: 12),
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC107),
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.add_circle, color: Colors.black, size: 20),
                label: const Text(
                  '➕ Generate New 1-Time VIP Pass Code',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                onPressed: () {
                  final newCode = state.generateVipCode();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('🎉 Generated New VIP Pass Code: $newCode'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              if (state.vipCodes.isEmpty)
                Text('No VIP codes generated yet.', style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 12))
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TOTAL CODES: ${state.vipCodes.length}',
                          style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                              child: Text('🟢 Active: $activeCount', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: Colors.red.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                              child: Text('🔴 Used: $usedCount', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: state.vipCodes.map((vip) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: vip.isUsed ? Colors.red.withOpacity(0.08) : const Color(0xFF10B981).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: vip.isUsed ? Colors.red.withOpacity(0.3) : const Color(0xFF10B981).withOpacity(0.5)),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                vip.isUsed ? Icons.cancel_outlined : Icons.check_circle_outline,
                                size: 18,
                                color: vip.isUsed ? Colors.redAccent : const Color(0xFF10B981),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SelectableText(
                                      vip.code,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 14,
                                        color: vip.isUsed ? Colors.redAccent : (isDark ? Colors.white : Colors.black87),
                                        decoration: vip.isUsed ? TextDecoration.lineThrough : null,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      vip.isUsed
                                          ? '❌ USED BY: ${vip.usedByName ?? "Redeemed Member"}'
                                          : '🟢 UNUSED (READY TO SHARE)',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: vip.isUsed ? Colors.redAccent : const Color(0xFF10B981),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!vip.isUsed)
                                InkWell(
                                  onTap: () {
                                    Clipboard.setData(ClipboardData(text: vip.code));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('📋 Copied ${vip.code} to clipboard!'),
                                        backgroundColor: Colors.green,
                                        duration: const Duration(seconds: 2),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.copy, size: 12, color: Colors.black),
                                        SizedBox(width: 4),
                                        Text('COPY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black)),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text('REDEEMED', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
            ],
          ),
        ).marginOnly(bottom: 20),

        // ── MEMBERSHIP PRICING LIST ─────────────────────────────────────────
        ...state.pricings.map((pricing) {
          Color tierColor = Colors.grey;

          switch (pricing.tier) {
            case MembershipTier.Basic:
              tierColor = Colors.grey;
              break;
            case MembershipTier.Silver:
              tierColor = Colors.grey[400]!;
              break;
            case MembershipTier.Gold:
              tierColor = Colors.amber;
              break;
            case MembershipTier.Diamond:
              tierColor = Colors.cyanAccent;
              break;
            case MembershipTier.Platinum:
              tierColor = const Color(0xFFE5E4E2);
              break;
          }

          final TextEditingController priceController =
              TextEditingController(text: pricing.price.toStringAsFixed(0));

        return GlassCard(
          padding: const EdgeInsets.all(18),
          borderColor: tierColor,
          borderOpacity: 0.25,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: tierColor.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.workspace_premium, color: tierColor, size: 28),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${pricing.tier.name} Membership Plan',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : const Color(0xFF1A3B6E),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Configured Cost: ₹${pricing.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? Colors.white60 : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Set Price:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 6),
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        prefixText: '₹',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        border: OutlineInputBorder(),
                      ),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC107),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {
                      final double? newPrice = double.tryParse(priceController.text);
                      if (newPrice != null) {
                        state.updatePricing(pricing.tier, newPrice);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            width: 400,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            content: Text('${pricing.tier.name} Price Updated Successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                    child: const Text('Save', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Enabled Platform Access & Features:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white70 : const Color(0xFF1A3B6E),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      _showAddBenefitDialog(context, state, pricing.tier);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.green.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.add, size: 12, color: Colors.greenAccent),
                          SizedBox(width: 4),
                          Text(
                            'Add New',
                            style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: pricing.benefits.asMap().entries.map((entry) {
                  final bIdx = entry.key;
                  final b = entry.value;
                  return GestureDetector(
                    onTap: () {
                      _showEditBenefitDialog(context, state, pricing.tier, bIdx, b);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A3B6E).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: tierColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            b,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(Icons.edit, size: 10, color: isDark ? Colors.white54 : Colors.black45),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ).marginOnly(bottom: 16);
      }).toList(),
    ]);
  }

  void _showAddBenefitDialog(BuildContext context, AppStateProvider state, MembershipTier tier) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0D1B2A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF1A3B6E), width: 1.5),
          ),
          title: Text(
            'Add Feature to ${tier.name}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Enter feature name',
              hintStyle: TextStyle(color: Colors.white38),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFFC107))),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC107),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                final text = controller.text.trim();
                if (text.isNotEmpty) {
                  state.addBenefit(tier, text);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(behavior: SnackBarBehavior.floating, width: 400, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), 
                      content: Text('Added "$text" to ${tier.name} Plan!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Add', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showEditBenefitDialog(BuildContext context, AppStateProvider state, MembershipTier tier, int index, String currentText) {
    final controller = TextEditingController(text: currentText);
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0D1B2A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF1A3B6E), width: 1.5),
          ),
          title: Text(
            'Edit Feature',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Feature name',
              hintStyle: TextStyle(color: Colors.white38),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFFC107))),
            ),
          ),
          actions: [
            TextButton.icon(
              icon: const Icon(Icons.delete, color: Colors.redAccent, size: 18),
              label: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
              onPressed: () {
                state.deleteBenefit(tier, index);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(behavior: SnackBarBehavior.floating, width: 400, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), 
                    content: Text('Deleted feature from ${tier.name} Plan.'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              },
            ),
            const SizedBox(width: 24),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC107),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                final text = controller.text.trim();
                if (text.isNotEmpty) {
                  state.updateBenefit(tier, index, text);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(behavior: SnackBarBehavior.floating, width: 400, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), 
                      content: Text('Updated feature successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Save', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}

