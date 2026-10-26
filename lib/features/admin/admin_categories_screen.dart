import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/category_model.dart';
import '../../services/mock_category_service.dart';

/// Admin screen for managing service categories (CRUD + enable/disable).
class AdminCategoriesScreen extends StatefulWidget {
  const AdminCategoriesScreen({super.key});

  @override
  State<AdminCategoriesScreen> createState() => _AdminCategoriesScreenState();
}

class _AdminCategoriesScreenState extends State<AdminCategoriesScreen> {
  final MockCategoryService _service = MockCategoryService();
  List<CategoryModel> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    final cats = await _service.getAllCategories();
    if (mounted) {
      setState(() {
        _categories = cats;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleCategory(CategoryModel cat) async {
    await _service.toggleCategory(cat.id, !cat.isEnabled);
    _loadCategories();
  }

  void _showAddEditDialog({CategoryModel? existing}) {
    final nameController =
        TextEditingController(text: existing?.name ?? '');
    final nameUrduController =
        TextEditingController(text: existing?.nameUrdu ?? '');
    final descController =
        TextEditingController(text: existing?.description ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'Add Category' : 'Edit Category'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                    labelText: 'Name (English)',
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: nameUrduController,
                decoration: const InputDecoration(
                    labelText: 'نام (اردو)',
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder()),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              Navigator.pop(ctx);
              if (existing == null) {
                final id =
                    'cat_${nameController.text.toLowerCase().replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}';
                await _service.addCategory(CategoryModel(
                  id: id,
                  name: nameController.text.trim(),
                  nameUrdu: nameUrduController.text.trim(),
                  description: descController.text.trim(),
                  sortOrder: _categories.length + 1,
                ));
              } else {
                await _service.updateCategory(existing.copyWith(
                  name: nameController.text.trim(),
                  nameUrdu: nameUrduController.text.trim(),
                  description: descController.text.trim(),
                ));
              }
              _loadCategories();
            },
            child: Text(existing == null ? 'Add' : 'Save',
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(CategoryModel cat) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text(
            'Are you sure you want to delete "${cat.name}"? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(context);
              await _service.deleteCategory(cat.id);
              _loadCategories();
            },
            child: const Text('Delete',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadCategories,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Category'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _categories.isEmpty
              ? const Center(child: Text('No categories found.'))
              : ListView.separated(
                  padding: AppConstants.paddingScreen,
                  itemCount: _categories.length,
                  separatorBuilder: (_, r) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: cat.isEnabled
                            ? AppColors.surface
                            : AppColors.background,
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusM),
                        border: Border.all(
                            color: cat.isEnabled
                                ? AppColors.cardBorder
                                : AppColors.cardBorder.withAlpha(100)),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: cat.isEnabled
                                ? AppColors.primary.withAlpha(20)
                                : AppColors.cardBorder,
                            borderRadius:
                                BorderRadius.circular(AppConstants.radiusS),
                          ),
                          child: Icon(Icons.handyman_rounded,
                              color: cat.isEnabled
                                  ? AppColors.primary
                                  : AppColors.textMuted,
                              size: 22),
                        ),
                        title: Text(cat.name,
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: cat.isEnabled
                                    ? AppColors.textPrimary
                                    : AppColors.textMuted)),
                        subtitle: Text(
                          cat.nameUrdu.isNotEmpty
                              ? '${cat.nameUrdu} • ${cat.subCategories.length} sub-cats'
                              : '${cat.subCategories.length} sub-categories',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                              value: cat.isEnabled,
                              onChanged: (_) => _toggleCategory(cat),
                              activeThumbColor: AppColors.success,
                            ),
                            PopupMenuButton<String>(
                              onSelected: (val) {
                                if (val == 'edit') {
                                  _showAddEditDialog(existing: cat);
                                }
                                if (val == 'delete') _confirmDelete(cat);
                              },
                              itemBuilder: (_) => [
                                const PopupMenuItem(
                                    value: 'edit', child: Text('Edit')),
                                const PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Delete',
                                        style: TextStyle(
                                            color: AppColors.error))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
