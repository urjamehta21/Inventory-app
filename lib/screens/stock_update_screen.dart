// lib/screens/stock_update_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../providers/inventory_providers.dart';
import '../utils/app_theme.dart';
import '../widgets/stock_status_badge.dart';
import '../widgets/stock_status_badge.dart' show StockProgressBar;

class StockUpdateScreen extends ConsumerStatefulWidget {
  final Product? product;

  const StockUpdateScreen({super.key, this.product});

  @override
  ConsumerState<StockUpdateScreen> createState() => _StockUpdateScreenState();
}

class _StockUpdateScreenState extends ConsumerState<StockUpdateScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _inQtyCtrl = TextEditingController();
  final _outQtyCtrl = TextEditingController();
  final _inNoteCtrl = TextEditingController();
  final _outNoteCtrl = TextEditingController();
  Product? _selectedProduct;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _selectedProduct = widget.product;
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _inQtyCtrl.dispose();
    _outQtyCtrl.dispose();
    _inNoteCtrl.dispose();
    _outNoteCtrl.dispose();
    super.dispose();
  }

  Future<void> _doStockIn() async {
    final qty = double.tryParse(_inQtyCtrl.text.trim());
    if (qty == null || qty <= 0) {
      _showError('Please enter a valid quantity greater than 0');
      return;
    }
    if (_selectedProduct == null) {
      _showError('Please select a product');
      return;
    }
    setState(() => _loading = true);
    try {
      await ref.read(productsProvider.notifier).stockIn(
        _selectedProduct!.id,
        qty,
        note: _inNoteCtrl.text.trim().isNotEmpty ? _inNoteCtrl.text.trim() : null,
      );
      _inQtyCtrl.clear();
      _inNoteCtrl.clear();
      // Reload product
      final updated = ref.read(productsProvider).firstWhere((p) => p.id == _selectedProduct!.id);
      setState(() => _selectedProduct = updated);
      _showSuccess('Added $qty ${_selectedProduct!.unit} to ${_selectedProduct!.name}');
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _doStockOut() async {
    final qty = double.tryParse(_outQtyCtrl.text.trim());
    if (qty == null || qty <= 0) {
      _showError('Please enter a valid quantity greater than 0');
      return;
    }
    if (_selectedProduct == null) {
      _showError('Please select a product');
      return;
    }
    if (qty > _selectedProduct!.quantity) {
      _showError('Insufficient stock. Available: ${_selectedProduct!.quantity} ${_selectedProduct!.unit}');
      return;
    }
    setState(() => _loading = true);
    try {
      await ref.read(productsProvider.notifier).stockOut(
        _selectedProduct!.id,
        qty,
        note: _outNoteCtrl.text.trim().isNotEmpty ? _outNoteCtrl.text.trim() : null,
      );
      _outQtyCtrl.clear();
      _outNoteCtrl.clear();
      final updated = ref.read(productsProvider).firstWhere((p) => p.id == _selectedProduct!.id);
      setState(() => _selectedProduct = updated);
      _showSuccess('Removed $qty ${_selectedProduct!.unit} from ${_selectedProduct!.name}');
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppTheme.danger),
    );
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppTheme.success),
    );
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsProvider);

    return Scaffold(
      backgroundColor: AppTheme.primary,
      appBar: AppBar(
        title: const Text('Update Stock'),
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: const [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_rounded, size: 18, color: AppTheme.stockNormal),
                  SizedBox(width: 8),
                  Text('Stock In', style: TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.remove_circle_rounded, size: 18, color: AppTheme.accentOrange),
                  SizedBox(width: 8),
                  Text('Stock Out', style: TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
          indicatorColor: AppTheme.accent,
          labelColor: AppTheme.textPrimary,
          unselectedLabelColor: AppTheme.textSecondary,
        ),
      ),
      body: Column(
        children: [
          // Product selector
          if (widget.product == null) _buildProductSelector(products),

          // Selected product info
          if (_selectedProduct != null) _buildProductInfo(),

          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _buildStockInForm(),
                _buildStockOutForm(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductSelector(List<Product> products) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Product>(
          value: _selectedProduct,
          hint: const Text('Select a product', style: TextStyle(color: AppTheme.textSecondary, fontFamily: 'Sora')),
          isExpanded: true,
          dropdownColor: AppTheme.surface,
          style: const TextStyle(color: AppTheme.textPrimary, fontFamily: 'Sora', fontSize: 14),
          items: products.map((p) => DropdownMenuItem(
            value: p,
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: p.stockStatus.color),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(p.name, overflow: TextOverflow.ellipsis)),
                Text(
                  '${p.quantity} ${p.unit}',
                  style: TextStyle(color: p.stockStatus.color, fontSize: 12),
                ),
              ],
            ),
          )).toList(),
          onChanged: (p) => setState(() => _selectedProduct = p),
        ),
      ),
    );
  }

  Widget _buildProductInfo() {
    final p = _selectedProduct!;
    final status = p.stockStatus;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: status.color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.name,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      fontFamily: 'Sora',
                    ),
                  ),
                  Text(p.category, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontFamily: 'Sora')),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${p.quantity} ${p.unit}',
                    style: TextStyle(
                      color: status.color,
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                      fontFamily: 'Sora',
                    ),
                  ),
                  Text('Min: ${p.minimumThreshold} ${p.unit}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontFamily: 'Sora')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          StockProgressBar(quantity: p.quantity, threshold: p.minimumThreshold),
          const SizedBox(height: 8),
          StockStatusBadge(status: status, compact: true),
        ],
      ),
    );
  }

  Widget _buildStockInForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.stockNormal.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.stockNormal.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.add_circle_rounded, color: AppTheme.stockNormal, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Add Stock',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Sora',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _QtyInput(
                  controller: _inQtyCtrl,
                  label: 'Quantity to Add *',
                  unit: _selectedProduct?.unit ?? 'units',
                  color: AppTheme.stockNormal,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _inNoteCtrl,
                  style: const TextStyle(color: AppTheme.textPrimary, fontFamily: 'Sora'),
                  decoration: const InputDecoration(
                    labelText: 'Note (optional)',
                    hintText: 'e.g. Purchase order #1234',
                    prefixIcon: Icon(Icons.note_rounded, color: AppTheme.textSecondary, size: 18),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : _doStockIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.stockNormal,
                      foregroundColor: AppTheme.primary,
                    ),
                    icon: _loading
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary))
                        : const Icon(Icons.add_rounded),
                    label: const Text('Add to Stock'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockOutForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.accentOrange.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.accentOrange.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.remove_circle_rounded, color: AppTheme.accentOrange, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Remove Stock',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Sora',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _QtyInput(
                  controller: _outQtyCtrl,
                  label: 'Quantity to Remove *',
                  unit: _selectedProduct?.unit ?? 'units',
                  color: AppTheme.accentOrange,
                  max: _selectedProduct?.quantity,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _outNoteCtrl,
                  style: const TextStyle(color: AppTheme.textPrimary, fontFamily: 'Sora'),
                  decoration: const InputDecoration(
                    labelText: 'Note (optional)',
                    hintText: 'e.g. Sold, used in lab, dispensed',
                    prefixIcon: Icon(Icons.note_rounded, color: AppTheme.textSecondary, size: 18),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : _doStockOut,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentOrange,
                      foregroundColor: AppTheme.primary,
                    ),
                    icon: _loading
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary))
                        : const Icon(Icons.remove_rounded),
                    label: const Text('Remove from Stock'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String unit;
  final Color color;
  final double? max;

  const _QtyInput({
    required this.controller,
    required this.label,
    required this.unit,
    required this.color,
    this.max,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
      style: TextStyle(color: color, fontFamily: 'Sora', fontSize: 24, fontWeight: FontWeight.w700),
      decoration: InputDecoration(
        labelText: label,
        hintText: '0',
        hintStyle: TextStyle(color: color.withOpacity(0.3), fontSize: 24, fontWeight: FontWeight.w700, fontFamily: 'Sora'),
        suffixText: unit,
        suffixStyle: const TextStyle(color: AppTheme.textSecondary, fontFamily: 'Sora'),
        helperText: max != null ? 'Available: $max $unit' : null,
        helperStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontFamily: 'Sora'),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: 1.5),
        ),
      ),
    );
  }
}
