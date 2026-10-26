import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../services/auth_notifier.dart';
import '../../services/mock_request_service.dart';

/// Screen for customers to create a new structured service request.
class CreateRequestScreen extends StatefulWidget {
  final AuthNotifier? authNotifier;
  final String? preselectedCategory;

  const CreateRequestScreen({
    super.key,
    this.authNotifier,
    this.preselectedCategory,
  });

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descController = TextEditingController();
  final _addressController = TextEditingController();
  final _budgetMinController = TextEditingController();
  final _budgetMaxController = TextEditingController();

  String _selectedCategory = '';
  String _selectedCity = 'city_sahiwal';
  String _selectedCityName = 'Sahiwal';
  DateTime? _preferredDate;
  String? _preferredTimeSlot;
  bool _isQuoteBased = true;
  bool _isLoading = false;

  final List<Map<String, String>> _categories = [
    {'id': 'Plumber', 'label': 'Plumber - پلمبر'},
    {'id': 'Electrician', 'label': 'Electrician - الیکٹریشن'},
    {'id': 'Mistri / Mason', 'label': 'Mistri / Mason - مستری'},
    {'id': 'Car Washer', 'label': 'Car Washer - کار واشر'},
    {'id': 'Mechanic', 'label': 'Mechanic - مکینک'},
    {'id': 'Painter', 'label': 'Painter - پینٹر'},
    {'id': 'Carpenter', 'label': 'Carpenter - ترکھان'},
    {'id': 'Cleaner / Sweeper', 'label': 'Cleaner - صفائی'},
  ];

  final List<Map<String, String>> _cities = [
    {'id': 'city_sahiwal', 'name': 'Sahiwal'},
    {'id': 'city_okara', 'name': 'Okara'},
    {'id': 'city_lahore', 'name': 'Lahore'},
  ];

  final List<String> _timeSlots = [
    '8:00 AM - 10:00 AM',
    '10:00 AM - 12:00 PM',
    '12:00 PM - 2:00 PM',
    '2:00 PM - 4:00 PM',
    '4:00 PM - 6:00 PM',
    '6:00 PM - 8:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory =
        widget.preselectedCategory ?? _categories.first['id']!;
  }

  @override
  void dispose() {
    _descController.dispose();
    _addressController.dispose();
    _budgetMinController.dispose();
    _budgetMaxController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() => _preferredDate = picked);
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory.isEmpty) {
      _showError('Please select a service category');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = widget.authNotifier?.currentUser;
      final request = await MockRequestService().createRequest(
        customerId: user?.uid ?? 'customer_demo_001',
        customerName: user?.name ?? 'Guest Customer',
        serviceCategory: _selectedCategory,
        description: _descController.text.trim(),
        serviceAddress: _addressController.text.trim(),
        cityId: _selectedCity,
        preferredDate: _preferredDate,
        preferredTimeSlot: _preferredTimeSlot,
        budgetMin: double.tryParse(_budgetMinController.text),
        budgetMax: double.tryParse(_budgetMaxController.text),
        isQuoteBased: _isQuoteBased,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.success,
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Service request sent successfully!'),
            ],
          ),
        ),
      );
      Navigator.pop(context, request);
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.error,
        content: Text(msg),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Service Request'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: AppConstants.paddingScreen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.info.withAlpha(20),
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  border: Border.all(color: AppColors.info.withAlpha(50)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.info, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Describe your problem clearly. Service provider will review and send a quote.',
                        style:
                            TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.spaceL),

              // Service Category
              _buildSectionTitle('Service Category *'),
              const SizedBox(height: AppConstants.spaceS),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: _inputDecoration('Select category'),
                items: _categories
                    .map((cat) => DropdownMenuItem(
                          value: cat['id'],
                          child: Text(cat['label']!),
                        ))
                    .toList(),
                onChanged: (val) =>
                    setState(() => _selectedCategory = val ?? ''),
                validator: (val) =>
                    (val == null || val.isEmpty) ? 'Select a category' : null,
              ),
              const SizedBox(height: AppConstants.spaceM),

              // City
              _buildSectionTitle('City *'),
              const SizedBox(height: AppConstants.spaceS),
              DropdownButtonFormField<String>(
                initialValue: _selectedCity,
                decoration: _inputDecoration('Select city'),
                items: _cities
                    .map((city) => DropdownMenuItem(
                          value: city['id'],
                          child: Text(city['name']!),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedCity = val;
                      _selectedCityName =
                          _cities.firstWhere((c) => c['id'] == val)['name']!;
                    });
                  }
                },
              ),
              const SizedBox(height: AppConstants.spaceM),

              // Service Address
              _buildSectionTitle('Service Address *'),
              const SizedBox(height: AppConstants.spaceS),
              TextFormField(
                controller: _addressController,
                decoration: _inputDecoration(
                    'e.g. House #12, Block B, $_selectedCityName'),
                maxLines: 2,
                validator: (val) =>
                    (val == null || val.trim().isEmpty)
                        ? 'Address is required'
                        : null,
              ),
              const SizedBox(height: AppConstants.spaceM),

              // Problem Description
              _buildSectionTitle('Describe the Problem *'),
              const SizedBox(height: AppConstants.spaceS),
              TextFormField(
                controller: _descController,
                decoration: _inputDecoration(
                    'Describe what needs to be done in detail...'),
                maxLines: 4,
                maxLength: 500,
                validator: (val) =>
                    (val == null || val.trim().length < 10)
                        ? 'Please describe the problem (min 10 characters)'
                        : null,
              ),
              const SizedBox(height: AppConstants.spaceM),

              // Preferred Date
              _buildSectionTitle('Preferred Date'),
              const SizedBox(height: AppConstants.spaceS),
              InkWell(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.cardBorder),
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusS),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded,
                          color: AppColors.primary, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        _preferredDate != null
                            ? '${_preferredDate!.day}/${_preferredDate!.month}/${_preferredDate!.year}'
                            : 'Select preferred date (optional)',
                        style: TextStyle(
                          color: _preferredDate != null
                              ? AppColors.textPrimary
                              : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spaceM),

              // Time Slot
              _buildSectionTitle('Preferred Time Slot'),
              const SizedBox(height: AppConstants.spaceS),
              DropdownButtonFormField<String>(
                initialValue: _preferredTimeSlot,
                decoration: _inputDecoration('Select time slot (optional)'),
                items: [
                  const DropdownMenuItem(
                      value: null, child: Text('Any time')),
                  ..._timeSlots.map((slot) =>
                      DropdownMenuItem(value: slot, child: Text(slot))),
                ],
                onChanged: (val) =>
                    setState(() => _preferredTimeSlot = val),
              ),
              const SizedBox(height: AppConstants.spaceM),

              // Pricing Type
              _buildSectionTitle('Pricing Type'),
              const SizedBox(height: AppConstants.spaceS),
              Row(
                children: [
                  Expanded(
                    child: _PricingTypeCard(
                      title: 'Get Quote',
                      subtitle: 'Provider will send a price',
                      icon: Icons.request_quote_rounded,
                      isSelected: _isQuoteBased,
                      onTap: () => setState(() => _isQuoteBased = true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PricingTypeCard(
                      title: 'Set Budget',
                      subtitle: 'Enter your min/max budget',
                      icon: Icons.account_balance_wallet_rounded,
                      isSelected: !_isQuoteBased,
                      onTap: () => setState(() => _isQuoteBased = false),
                    ),
                  ),
                ],
              ),
              if (!_isQuoteBased) ...[
                const SizedBox(height: AppConstants.spaceM),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _budgetMinController,
                        decoration:
                            _inputDecoration('Min budget (Rs.)'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _budgetMaxController,
                        decoration:
                            _inputDecoration('Max budget (Rs.)'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: AppConstants.spaceXL),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submitRequest,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child:
                              CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send_rounded),
                  label: Text(
                    _isLoading ? 'Sending...' : 'Send Service Request',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusM),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spaceL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
          const TextStyle(color: AppColors.textMuted, fontSize: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusS),
        borderSide: const BorderSide(color: AppColors.cardBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusS),
        borderSide: const BorderSide(color: AppColors.cardBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusS),
        borderSide:
            const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }
}

class _PricingTypeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PricingTypeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withAlpha(15)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textSecondary,
                size: 22),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textPrimary,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
