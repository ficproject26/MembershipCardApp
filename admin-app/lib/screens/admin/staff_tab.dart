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
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF1A3B6E),
              child: Text(staff.name[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
            ),
            title: Text(staff.name, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(staff.role.displayName, style: const TextStyle(color: Color(0xFFFFC107), fontWeight: FontWeight.w600)),
                Text('${staff.email} • ${staff.phoneNumber}', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 12)),
              ],
            ),
          ),
        );
      },
    );
  }

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
              if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
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
                      style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildTextField('Full Name', Icons.person, (val) => _name = val, isDark),
                const SizedBox(height: 16),
                _buildTextField('Email Address', Icons.email, (val) => _email = val, isDark, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 16),
                _buildTextField('Phone Number', Icons.phone, (val) => _phone = val, isDark, keyboardType: TextInputType.phone),
                const SizedBox(height: 16),
                TextFormField(
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                    prefixIcon: Icon(Icons.lock, color: isDark ? Colors.white54 : Colors.black54),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: isDark ? Colors.white54 : Colors.black54),
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
                            child: Text(role.displayName, style: TextStyle(color: isDark ? Colors.white : Colors.black)),
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
                                  SnackBar(content: Text('Staff member ${staff.name} successfully registered!'), backgroundColor: Colors.green),
                                );
                                _tabController.animateTo(0);
                              } else if (state.error != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(state.error!), backgroundColor: Colors.red),
                                );
                              }
                            }
                          },
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Color(0xFF1A3B6E))
                        : const Text('Add Staff Member', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, Function(String) onSave, bool isDark, {TextInputType keyboardType = TextInputType.text}) {
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
