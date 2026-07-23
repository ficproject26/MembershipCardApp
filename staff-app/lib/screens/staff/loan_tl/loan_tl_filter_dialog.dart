import 'package:flutter/material.dart';

class LoanTlFilterDialog extends StatefulWidget {
  final Function(Map<String, String>) onApplyFilters;

  const LoanTlFilterDialog({super.key, required this.onApplyFilters});

  @override
  State<LoanTlFilterDialog> createState() => _LoanTlFilterDialogState();
}

class _LoanTlFilterDialogState extends State<LoanTlFilterDialog> {
  String? _selectedDateRange;
  String? _selectedLoanType;
  String? _selectedStatus;
  final TextEditingController _minAmountController = TextEditingController();
  final TextEditingController _maxAmountController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  final Color primaryDark = const Color(0xFF0D1B2A);
  final Color cardDark = const Color(0xFF1B263B);
  final Color accentGold = const Color(0xFFFFC107);

  final List<String> _dateRanges = ['Today', 'This Week', 'This Month', 'Last 3 Months', 'All Time'];
  final List<String> _loanTypes = ['Personal Loan', 'Home Loan', 'Business Loan', 'Education Loan', 'Gold Loan', 'Car Loan'];
  final List<String> _statuses = ['Pending', 'With KYC', 'Verified', 'Bank', 'Approved', 'Disbursed', 'Rejected'];

  void _resetFilters() {
    setState(() {
      _selectedDateRange = null;
      _selectedLoanType = null;
      _selectedStatus = null;
      _minAmountController.clear();
      _maxAmountController.clear();
      _nameController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: cardDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                TextButton(
                  onPressed: _resetFilters,
                  child: const Text('Clear all', style: TextStyle(color: Colors.blue, fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Date Range
            const Text('Date Range', style: TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: primaryDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  dropdownColor: primaryDark,
                  hint: const Text('Select date range', style: TextStyle(color: Colors.white38, fontSize: 13)),
                  value: _selectedDateRange,
                  isExpanded: true,
                  icon: const Icon(Icons.calendar_today, color: Colors.white54, size: 18),
                  items: _dateRanges.map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(color: Colors.white)))).toList(),
                  onChanged: (val) => setState(() => _selectedDateRange = val),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Loan Type
            const Text('Loan Type', style: TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: primaryDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  dropdownColor: primaryDark,
                  hint: const Text('Select loan type', style: TextStyle(color: Colors.white38, fontSize: 13)),
                  value: _selectedLoanType,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
                  items: _loanTypes.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(color: Colors.white)))).toList(),
                  onChanged: (val) => setState(() => _selectedLoanType = val),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Loan Amount
            const Text('Loan Amount', style: TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minAmountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Min Amount',
                      hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                      filled: true,
                      fillColor: primaryDark,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('to', style: TextStyle(color: Colors.white54)),
                ),
                Expanded(
                  child: TextField(
                    controller: _maxAmountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Max Amount',
                      hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                      filled: true,
                      fillColor: primaryDark,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Applicant Name
            const Text('Applicant Name', style: TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Enter applicant name',
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                filled: true,
                fillColor: primaryDark,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 14),

            // Status
            const Text('Status', style: TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: primaryDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  dropdownColor: primaryDark,
                  hint: const Text('Select status', style: TextStyle(color: Colors.white38, fontSize: 13)),
                  value: _selectedStatus,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
                  items: _statuses.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(color: Colors.white)))).toList(),
                  onChanged: (val) => setState(() => _selectedStatus = val),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Bottom Buttons matching Screenshot 5
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _resetFilters();
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Reset', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onApplyFilters({
                        'dateRange': _selectedDateRange ?? '',
                        'loanType': _selectedLoanType ?? '',
                        'minAmount': _minAmountController.text,
                        'maxAmount': _maxAmountController.text,
                        'name': _nameController.text,
                        'status': _selectedStatus ?? '',
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentGold,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
