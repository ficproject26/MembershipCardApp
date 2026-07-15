import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';

class AdminStaffTab extends StatefulWidget {
  const AdminStaffTab({Key? key}) : super(key: key);

  @override
  State<AdminStaffTab> createState() => _AdminStaffTabState();
}

class _AdminStaffTabState extends State<AdminStaffTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';
  String _phone = '';
  String _password = '';
  StaffRole _selectedRole = StaffRole.kycDepartment;
  bool _isSubmitting = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final isDark = state.isDarkMode;

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFFFC107),
          unselectedLabelColor: isDark ? Colors.white54 : Colors.black54,
          indicatorColor: const Color(0xFFFFC107),
          tabs: const [
            Tab(text: 'Staff Directory'),
            Tab(text: 'Add Staff'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildStaffDirectory(state, isDark),
              _buildAddStaffForm(state, isDark),
            ],
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Staff Directory
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildStaffDirectory(AppStateProvider state, bool isDark) {
    if (state.isLoadingStaff) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.staff.isEmpty) {
      return Center(
        child: Text(
          'No staff members registered yet.',
          style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.staff.length,
      itemBuilder: (ctx, i) {
        final staff = state.staff[i];
        return Card(
          color: isDark ? const Color(0xFF1E212D) : Colors.white,
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  backgroundColor: const Color(0xFF1A3B6E),
                  child: Text(staff.name[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 12),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(staff.name, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                      Text(staff.role.displayName, style: const TextStyle(color: Color(0xFFFFC107), fontWeight: FontWeight.w600, fontSize: 12)),
                      Text('${staff.email} • ${staff.phoneNumber}',
                          style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 11)),
                    ],
                  ),
                ),
                // Edit button
                IconButton(
                  tooltip: 'Edit',
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  color: const Color(0xFFFFC107),
                  onPressed: () => _showEditSheet(context, staff, isDark),
                ),
                // Delete button
                IconButton(
                  tooltip: 'Delete',
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: Colors.red,
                  onPressed: () => _confirmDelete(context, staff, isDark),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Edit Sheet
  // ──────────────────────────────────────────────────────────────────────────

  void _showEditSheet(BuildContext context, StaffModel staff, bool isDark) {
    final nameCtrl = TextEditingController(text: staff.name);
    final phoneCtrl = TextEditingController(text: staff.phoneNumber);
    StaffRole selectedRole = staff.role;
    bool isSaving = false;
    final editFormKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (_, scrollCtrl) => Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E212D) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFC107).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.edit_outlined, color: Color(0xFFFFC107), size: 22),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Edit Staff Member',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollCtrl,
                    padding: EdgeInsets.fromLTRB(24, 0, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
                    child: Form(
                      key: editFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sheetField(
                            'Full Name', nameCtrl, Icons.person_outline, isDark,
                            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 16),
                          _sheetField(
                            'Phone Number', phoneCtrl, Icons.phone_outlined, isDark,
                            keyboardType: TextInputType.phone,
                            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 16),
                          Text('Role',
                              style: TextStyle(
                                color: isDark ? Colors.white54 : Colors.black54,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              )),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<StaffRole>(
                            value: selectedRole,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: isDark ? const Color(0xFF2C3140) : const Color(0xFFF3F4F6),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.black12)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: Color(0xFFFFC107), width: 1.5)),
                            ),
                            dropdownColor: isDark ? const Color(0xFF2C3140) : Colors.white,
                            items: StaffRole.values
                                .where((r) => r != StaffRole.other)
                                .map((r) => DropdownMenuItem(
                                      value: r,
                                      child: Text(r.displayName,
                                          style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                                    ))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) setSheetState(() => selectedRole = val);
                            },
                          ),
                          const SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFC107),
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              icon: isSaving
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                                  : const Icon(Icons.save_outlined),
                              label: Text(
                                isSaving ? 'Saving…' : 'Save Changes',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              onPressed: isSaving
                                  ? null
                                  : () async {
                                      if (!editFormKey.currentState!.validate()) return;
                                      setSheetState(() => isSaving = true);
                                      final result =
                                          await Provider.of<AppStateProvider>(context, listen: false)
                                              .updateStaff(staff.id, {
                                        'name': nameCtrl.text.trim(),
                                        'phoneNumber': phoneCtrl.text.trim(),
                                        'role': selectedRole.name,
                                      });
                                      if (ctx.mounted) Navigator.pop(ctx);
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(result != null
                                                ? '${result.name} updated successfully ✅'
                                                : 'Failed to update staff'),
                                            backgroundColor: result != null ? Colors.green : Colors.red,
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      }
                                    },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sheetField(
    String label,
    TextEditingController ctrl,
    IconData icon,
    bool isDark, {
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: isDark ? Colors.white54 : Colors.black54,
                fontSize: 13,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          keyboardType: keyboardType,
          validator: validator,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: isDark ? Colors.white38 : Colors.black38, size: 20),
            filled: true,
            fillColor: isDark ? const Color(0xFF2C3140) : const Color(0xFFF3F4F6),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.black12)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFFFC107), width: 1.5)),
            errorBorder:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red)),
            errorStyle: const TextStyle(color: Colors.redAccent),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Delete Confirmation
  // ──────────────────────────────────────────────────────────────────────────

  void _confirmDelete(BuildContext context, StaffModel staff, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E212D) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red),
            const SizedBox(width: 8),
            Text('Delete Staff',
                style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${staff.name}"?\nThis action cannot be undone.',
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final success =
                  await Provider.of<AppStateProvider>(context, listen: false).deleteStaff(staff.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? '${staff.name} deleted successfully'
                        : 'Failed to delete staff'),
                    backgroundColor: success ? Colors.green : Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Add Staff Form
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildAddStaffForm(AppStateProvider state, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E212D) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              if (!isDark)
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.manage_accounts, color: Color(0xFFFFC107)),
                    const SizedBox(width: 8),
                    Text(
                      'Register New Staff',
                      style: TextStyle(
                          color: isDark ? Colors.white : Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildTextField('Full Name', Icons.person, (val) => _name = val, isDark),
                const SizedBox(height: 16),
                _buildTextField('Email Address', Icons.email, (val) => _email = val, isDark,
                    keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 16),
                _buildTextField('Phone Number', Icons.phone, (val) => _phone = val, isDark,
                    keyboardType: TextInputType.phone),
                const SizedBox(height: 16),
                TextFormField(
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                    prefixIcon: Icon(Icons.lock, color: isDark ? Colors.white54 : Colors.black54),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: isDark ? Colors.white54 : Colors.black54),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF2C3140) : const Color(0xFFF3F4F6),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Required';
                    if (val.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                  onSaved: (val) => _password = val!,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<StaffRole>(
                  value: _selectedRole,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDark ? const Color(0xFF2C3140) : const Color(0xFFF3F4F6),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  ),
                  dropdownColor: isDark ? const Color(0xFF2C3140) : Colors.white,
                  items: StaffRole.values
                      .where((role) => role != StaffRole.other)
                      .map((role) => DropdownMenuItem(
                            value: role,
                            child: Text(role.displayName,
                                style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedRole = val);
                  },
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC107),
                      foregroundColor: const Color(0xFF1A3B6E),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    onPressed: _isSubmitting
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              setState(() => _isSubmitting = true);
                              final staff = await state.registerStaff(
                                name: _name,
                                email: _email,
                                phoneNumber: _phone,
                                role: _selectedRole,
                                password: _password,
                              );
                              setState(() => _isSubmitting = false);

                              if (staff != null) {
                                _formKey.currentState!.reset();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    behavior: SnackBarBehavior.floating,
                                    width: 400,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    content: Text('Staff member ${staff.name} successfully registered!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                _tabController.animateTo(0);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    behavior: SnackBarBehavior.floating,
                                    width: 400,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    content: Text(state.error?.replaceAll('Exception: ', '') ?? 'Failed to register staff.'),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }
                            }
                          },
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Color(0xFF1A3B6E))
                        : const Text('Add Staff Member',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, Function(String) onSave, bool isDark,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
        prefixIcon: Icon(icon, color: isDark ? Colors.white54 : Colors.black54),
        filled: true,
        fillColor: isDark ? const Color(0xFF2C3140) : const Color(0xFFF3F4F6),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      ),
      keyboardType: keyboardType,
      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
      onSaved: (val) => onSave(val!),
    );
  }
}
