// lib/screens/add_edit_product_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../providers/inventory_providers.dart';
import '../utils/app_theme.dart';

class AddEditProductScreen extends ConsumerStatefulWidget {
  final Product? product;

  const AddEditProductScreen({super.key, this.product});

  @override
  ConsumerState<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends ConsumerState<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _qtyCtrl;
  late TextEditingController _minCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _costCtrl;
  String _category = 'General';
  String _unit = 'units';
  bool _saving = false;

  final List<String> _categories = [
    'General', 'Medicine', 'Hygiene', 'Stationery',
    'Pantry', 'Office', 'Electronics', 'Lab Equipment', 'Clothing', 'Other'
  ];

  final List<String> _units = [
    'units', 'pcs', 'kg', 'g', 'l', 'ml', 'boxes', 'bottles',
    'tablets', 'pairs', 'sheets', 'reams', 'rolls'
  ];

  bool get _isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _qtyCtrl = TextEditingController(text: p?.quantity.toStringAsFixed(p.quantity % 1 == 0 ? 0 : 2) ?? '');
    _minCtrl = TextEditingController(text: p?.minimumThreshold.toStringAsFixed(0) ?? '');
    _descCtrl = TextEditingController(text: p?.description ?? '');
    _costCtrl = TextEditingController(text: p?.costPrice?.toStringAsFixed(2) ?? '');
    _category = p?.category ?? 'General';
    _unit = p?.unit ?? 'units';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _qtyCtrl.dispose();
    _minCtrl.dispose();
    _descCtrl.dispose();
    _costCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final qty = double.parse(_qtyCtrl.text.trim());
      final min = double.parse(_minCtrl.text.trim());
      final cost = _costCtrl.text.trim().isNotEmpty ? double.tryParse(_costCtrl.text.trim()) : null;

      if (_isEdit) {
        final updated = widget.product!.copyWith(
          name: _nameCtrl.text.trim(),
          category: _category,
          quantity: qty,
          minimumThreshold: min,
          unit: _unit,
          description: _descCtrl.text.trim().isNotEmpty ? _descCtrl.text.trim() : null,
          costPrice: cost,
        );
        await ref.read(productsProvider.notifier).updateProduct(updated);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product updated successfully'),
              backgroundColor: AppTheme.success,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        await ref.read(productsProvider.notifier).createProduct(
          name: _nameCtrl.text.trim(),
          category: _category,
          quantity: qty,
          minimumThreshold: min,
          unit: _unit,
          description: _descCtrl.text.trim().isNotEmpty ? _descCtrl.text.trim() : null,
          costPrice: cost,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product added successfully'),
              backgroundColor: AppTheme.success,
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.danger),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Product' : 'Add Product'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accent))
                  : const Text('Save', style: TextStyle(color: AppTheme.accent, fontFamily: 'Sora', fontWeight: FontWeight.w600, fontSize: 15)),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildSection('Product Info', [
              _buildTextField(
                controller: _nameCtrl,
                label: 'Product Name *',
                hint: 'e.g. Paracetamol 500mg',
                validator: (v) => v == null || v.trim().isEmpty ? 'Product name is required' : null,
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                label: 'Category',
                value: _category,
                items: _categories,
                onChanged: (v) => setState(() => _category = v!),
              ),
              const SizedBox(height: 16),
              if (_descCtrl != null)
                _buildTextField(
                  controller: _descCtrl,
                  label: 'Description (optional)',
                  hint: 'Brief description of this product',
                  maxLines: 2,
                ),
            ]),
            const SizedBox(height: 20),
            _buildSection('Stock Details', [
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildTextField(
                      controller: _qtyCtrl,
                      label: _isEdit ? 'Current Quantity *' : 'Initial Quantity *',
                      hint: '0',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        final n = double.tryParse(v.trim());
                        if (n == null || n < 0) return 'Invalid quantity';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDropdown(
                      label: 'Unit',
                      value: _unit,
                      items: _units,
                      onChanged: (v) => setState(() => _unit = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _minCtrl,
                label: 'Minimum Threshold *',
                hint: 'Alert when stock falls below',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  final n = double.tryParse(v.trim());
                  if (n == null || n < 0) return 'Invalid threshold';
                  return null;
                },
                helperText: 'Low stock alert will trigger when stock ≤ this value',
              ),
            ]),
            const SizedBox(height: 20),
            _buildSection('Optional Info', [
              _buildTextField(
                controller: _costCtrl,
                label: 'Cost Price (₹)',
                hint: '0.00',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
              ),
            ]),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary))
                  : Text(_isEdit ? 'Update Product' : 'Add Product'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: 'Sora',
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? helperText,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(color: AppTheme.textPrimary, fontFamily: 'Sora'),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helperText,
        helperStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontFamily: 'Sora'),
        helperMaxLines: 2,
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items
          .map((i) => DropdownMenuItem(
                value: i,
                child: Text(i, style: const TextStyle(fontFamily: 'Sora', fontSize: 14, color: AppTheme.textPrimary)),
              ))
          .toList(),
      onChanged: onChanged,
      dropdownColor: AppTheme.surface,
      decoration: InputDecoration(labelText: label),
      style: const TextStyle(color: AppTheme.textPrimary, fontFamily: 'Sora'),
    );
  }
}
