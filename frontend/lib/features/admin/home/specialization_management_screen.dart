import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/admin_service.dart';
import '../../../core/models/specialization_model.dart';

class SpecializationManagementScreen extends StatefulWidget {
  const SpecializationManagementScreen({super.key});

  @override
  State<SpecializationManagementScreen> createState() => _SpecializationManagementScreenState();
}

class _SpecializationManagementScreenState extends State<SpecializationManagementScreen> {
  final AdminService _adminService = AdminService();
  bool _isLoading = true;
  List<Specialization> _specializations = [];

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedIcon = 'medical_services';

  final List<String> _availableIcons = [
    'medical_services',
    'favorite',
    'face',
    'child_care',
    'psychology',
    'tooth',
    'visibility',
    'hearing',
    'pregnant_woman',
    'biotech',
  ];

  @override
  void initState() {
    super.initState();
    _loadSpecializations();
  }

  Future<void> _loadSpecializations() async {
    setState(() => _isLoading = true);
    try {
      final specs = await _adminService.getSpecializations();
      setState(() {
        _specializations = specs;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading specializations: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Specialization'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name (e.g., Cardiology)'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  const Text('Select Icon'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _availableIcons.map((iconName) {
                      return GestureDetector(
                        onTap: () => setDialogState(() => _selectedIcon = iconName),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _selectedIcon == iconName ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                            border: Border.all(
                              color: _selectedIcon == iconName ? AppColors.primary : Colors.grey.withOpacity(0.3),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(_getIconData(iconName), color: _selectedIcon == iconName ? AppColors.primary : Colors.grey),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final success = await _adminService.addSpecialization(
                    _nameController.text,
                    _descController.text,
                    _selectedIcon,
                  );
                  if (success) {
                    _nameController.clear();
                    _descController.clear();
                    Navigator.pop(context);
                    _loadSpecializations();
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'favorite': return Icons.favorite;
      case 'face': return Icons.face;
      case 'child_care': return Icons.child_care;
      case 'psychology': return Icons.psychology;
      case 'tooth': return Icons.health_and_safety; // Material doesn't have a tooth icon by default, using fallback
      case 'visibility': return Icons.visibility;
      case 'hearing': return Icons.hearing;
      case 'pregnant_woman': return Icons.pregnant_woman;
      case 'biotech': return Icons.biotech;
      default: return Icons.medical_services;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Specializations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _specializations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.category_outlined, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text('No specializations found', style: AppTextStyles.bodyLarge),
                      const SizedBox(height: 8),
                      ElevatedButton(onPressed: _showAddDialog, child: const Text('Add Your First')),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _specializations.length,
                  itemBuilder: (context, index) {
                    final spec = _specializations[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: Icon(_getIconData(spec.icon), color: AppColors.primary),
                        ),
                        title: Text(spec.name, style: AppTextStyles.h3),
                        subtitle: Text(spec.description),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.error),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Specialization?'),
                                content: Text('Are you sure you want to delete ${spec.name}?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('Delete', style: TextStyle(color: AppColors.error)),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              final success = await _adminService.deleteSpecialization(spec.id);
                              if (success) _loadSpecializations();
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
