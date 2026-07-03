import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';

class AdminMembershipTab extends StatelessWidget {
  const AdminMembershipTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final isDark = state.isDarkMode;

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: state.pricings.length,
      itemBuilder: (context, idx) {
        final pricing = state.pricings[idx];
        Color tierColor = Colors.grey;

        switch (pricing.tier) {
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
                  const SizedBox(width: 8),
                  Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: TextField(
                          controller: priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            prefixText: '₹',
                            isDense: true,
                            contentPadding: EdgeInsets.all(8),
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
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          final double? newPrice = double.tryParse(priceController.text);
                          if (newPrice != null) {
                            state.updatePricing(pricing.tier, newPrice);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${pricing.tier.name} Price Updated Successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                        child: const Text('Save', style: TextStyle(color: Colors.white, fontSize: 11)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Enabled Platform Access & Features:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : const Color(0xFF1A3B6E),
                    ),
                  ),
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
      },
    );
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
                    SnackBar(
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
                  SnackBar(
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
                    SnackBar(
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

