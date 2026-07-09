import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';

class AgentWalletTab extends StatelessWidget {
  const AgentWalletTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final agent = state.currentAgent!;
    final isDark = state.isDarkMode;

    final myTx = state.transactions.where((t) => t.agentCode == agent.agentCode).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Elegant Debit Card Style Wallet Widget
          GlassCard(
            padding: const EdgeInsets.all(20),
            color: const Color(0xFFFFC107),
            backgroundOpacity: 0.15,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Forge Cash Wallet',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70, fontSize: 12),
                    ),
                    const Icon(Icons.wifi, color: Colors.white70, size: 20),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  'AVAILABLE BALANCE',
                  style: TextStyle(fontSize: 10, color: Colors.white60, fontWeight: FontWeight.bold),
                ),
                Text(
                  '₹${agent.walletBalance.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'AGENT: ${agent.agentCode}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white70),
                    ),
                    Text(
                      'KYC: ${agent.kycStatus.name}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70),
                    ),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Payout Withdrawal / KYC Actions Section
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    if (agent.kycStatus != KycStatus.Approved) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(behavior: SnackBarBehavior.floating, width: 400, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), 
                          content: Text('Payout requires an APPROVED KYC status. Please submit KYC first.'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      return;
                    }
                    if (agent.walletBalance <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(behavior: SnackBarBehavior.floating, width: 400, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), 
                          content: Text('Wallet balance is 0. Cannot withdraw.'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      return;
                    }
                    _showWithdrawalDialog(context, state, agent.walletBalance);
                  },
                  icon: const Icon(Icons.arrow_upward, color: Colors.white),
                  label: const Text('Request Payout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              if (agent.kycStatus == KycStatus.NotSubmitted || agent.kycStatus == KycStatus.Rejected) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC107),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      _showKycSubmissionForm(context, state);
                    },
                    icon: const Icon(Icons.verified_user, color: Colors.white),
                    label: const Text('Submit KYC', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),

          // Transaction History list
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Wallet Activities',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1A3B6E),
                ),
              ),
              Text(
                '${myTx.length} Entries',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (myTx.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: Text(
                  'No wallet activities recorded yet.',
                  style: TextStyle(color: isDark ? Colors.white30 : Colors.black38),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: myTx.length,
              itemBuilder: (context, idx) {
                final tx = myTx[idx];
                Color txColor = Colors.grey;
                IconData txIcon = Icons.swap_horiz;

                switch (tx.type) {
                  case TransactionType.DirectCommission:
                    txColor = Colors.green;
                    txIcon = Icons.arrow_downward;
                    break;
                  case TransactionType.IndirectCommission:
                    txColor = Colors.teal;
                    txIcon = Icons.group;
                    break;
                  case TransactionType.Withdrawal:
                    txColor = Colors.redAccent;
                    txIcon = Icons.arrow_upward;
                    break;
                  case TransactionType.Upgrade:
                    txColor = Colors.amber;
                    txIcon = Icons.workspace_premium;
                    break;
                }

                return GlassCard(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: txColor.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(txIcon, color: txColor, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tx.description,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            Text(
                              '${tx.type.name} • ${tx.date.toString().split(' ')[0]}',
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark ? Colors.white38 : Colors.black38,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${tx.type == TransactionType.Withdrawal || tx.type == TransactionType.Upgrade ? "-" : "+"} ₹${tx.amount.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: tx.type == TransactionType.Withdrawal || tx.type == TransactionType.Upgrade
                                  ? Colors.redAccent
                                  : Colors.greenAccent,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: tx.status == TransactionStatus.Success
                                  ? Colors.green.withOpacity(0.15)
                                  : tx.status == TransactionStatus.Pending
                                      ? Colors.amber.withOpacity(0.15)
                                      : Colors.red.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              tx.status.name,
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: tx.status == TransactionStatus.Success
                                    ? Colors.green
                                    : tx.status == TransactionStatus.Pending
                                        ? Colors.amber
                                        : Colors.red,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ).marginOnly(bottom: 10);
              },
            ),
        ],
      ),
    );
  }

  void _showWithdrawalDialog(BuildContext context, AppStateProvider state, double maxBalance) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Request Payout Withdrawal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Available: ₹${maxBalance.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  prefixText: '₹',
                  labelText: 'Withdrawal Amount',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                final double? amount = double.tryParse(controller.text);
                if (amount == null || amount <= 0 || amount > maxBalance) {
                  showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text("Notification"), content: Text('Invalid withdrawal amount entered.'), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))]));
                  return;
                }
                state.requestWithdrawal(amount);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(behavior: SnackBarBehavior.floating, width: 400, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), 
                    content: Text('Payout request submitted for approval!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Submit Request', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showKycSubmissionForm(BuildContext context, AppStateProvider state) {
    final aadhaarController = TextEditingController();
    final panController = TextEditingController();
    final bankAccController = TextEditingController();
    final ifscController = TextEditingController();
    final bankNameController = TextEditingController();
    
    bool isUploading = false;
    bool isPhotoUploaded = false;
    String photoUrl = '';
    String? panError;
    final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Submit KYC Verification Documents'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: aadhaarController,
                      keyboardType: TextInputType.number,
                      maxLength: 12,
                      decoration: const InputDecoration(
                        labelText: 'Aadhaar Card Number (12 Digits)',
                        hintText: 'e.g. 1234 5678 9012',
                        counterText: '',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: panController,
                      maxLength: 10,
                      textCapitalization: TextCapitalization.characters,
                      onChanged: (value) {
                        setState(() {
                          if (value.isEmpty) {
                            panError = null;
                          } else if (value.length == 10 && !panRegex.hasMatch(value.toUpperCase())) {
                            panError = 'Invalid format (e.g. ABCDE1234F)';
                          } else {
                            panError = null;
                          }
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'PAN Card Number (10 Characters)',
                        hintText: 'e.g. ABCDE1234F',
                        counterText: '',
                        errorText: panError,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: bankAccController,
                      keyboardType: TextInputType.number,
                      maxLength: 18,
                      decoration: const InputDecoration(
                        labelText: 'Bank Account Number',
                        hintText: 'e.g. 1234567890',
                        counterText: '',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: ifscController,
                      maxLength: 11,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: 'Bank IFSC Code (11 Characters)',
                        hintText: 'e.g. HDFC0001234',
                        counterText: '',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: bankNameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name (As per Bank)',
                        hintText: 'e.g. John Doe',
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Photo Verification Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isPhotoUploaded ? Colors.green : Colors.grey.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            isPhotoUploaded ? Icons.check_circle : Icons.camera_alt,
                            color: isPhotoUploaded ? Colors.green : Colors.grey,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isPhotoUploaded ? 'ID Photo Attached' : 'Photo Verification Required',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isPhotoUploaded ? Colors.green : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (!isPhotoUploaded)
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1A3B6E),
                              ),
                              onPressed: isUploading ? null : () async {
                                setState(() => isUploading = true);
                                // Simulate network delay for photo upload
                                await Future.delayed(const Duration(seconds: 1));
                                setState(() {
                                  isUploading = false;
                                  isPhotoUploaded = true;
                                  photoUrl = 'https://via.placeholder.com/150/000000/FFFFFF/?text=Verified+ID'; // Simulated photo URL
                                });
                              },
                              icon: isUploading 
                                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Icon(Icons.upload_file, color: Colors.white, size: 16),
                              label: Text(
                                isUploading ? 'Uploading...' : 'Upload ID Photo',
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFC107)),
                  onPressed: () {
                    String aadhaar = aadhaarController.text.trim();
                    String pan = panController.text.trim().toUpperCase();
                    String bankAcc = bankAccController.text.trim();
                    String ifsc = ifscController.text.trim().toUpperCase();
                    String bankName = bankNameController.text.trim();

                    if (aadhaar.length != 12) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(behavior: SnackBarBehavior.floating, width: 400, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), content: Text('Error: Aadhaar Number must be exactly 12 digits.'), backgroundColor: Colors.red),
                      );
                      return;
                    }
                    if (pan.length != 10) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(behavior: SnackBarBehavior.floating, width: 400, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), content: Text('Error: PAN Card Number must be exactly 10 characters.'), backgroundColor: Colors.red),
                      );
                      return;
                    }
                    
                    // Validate PAN format (5 letters, 4 numbers, 1 letter)
                    final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');
                    if (!panRegex.hasMatch(pan)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(behavior: SnackBarBehavior.floating, width: 400, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), content: Text('Error: Invalid PAN format (e.g. ABCDE1234F).'), backgroundColor: Colors.red),
                      );
                      return;
                    }

                    if (bankAcc.length < 9) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(behavior: SnackBarBehavior.floating, width: 400, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), content: Text('Error: Bank Account Number is too short.'), backgroundColor: Colors.red),
                      );
                      return;
                    }
                    if (ifsc.length != 11) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(behavior: SnackBarBehavior.floating, width: 400, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), content: Text('Error: IFSC Code must be exactly 11 characters.'), backgroundColor: Colors.red),
                      );
                      return;
                    }
                    if (bankName.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(behavior: SnackBarBehavior.floating, width: 400, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), content: Text('Error: Please enter your Full Name as per Bank.'), backgroundColor: Colors.red),
                      );
                      return;
                    }

                    if (!isPhotoUploaded) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(behavior: SnackBarBehavior.floating, width: 400, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), content: Text('Error: Please upload an ID photo for verification.'), backgroundColor: Colors.red),
                      );
                      return;
                    }

                    state.submitKyc(
                      aadhaar: aadhaar,
                      pan: pan,
                      bankAccountNumber: bankAcc,
                      bankIfscCode: ifsc,
                      bankAccountName: bankName,
                      photoUrl: photoUrl,
                    );

                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(behavior: SnackBarBehavior.floating, width: 400, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), 
                        content: Text('KYC Submitted! Approval is now in the admin queue.'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  child: const Text('Submit for Review', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }
        );
      },
    );
  }
}
