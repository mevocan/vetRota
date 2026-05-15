import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/env.dart';
import '../../data/db/app_database.dart';
import '../../data/drugs/drugs_repository.dart';

const Color _green = Color(Env.primaryColorHex);

// Yeni stok hareketi: alis (purchase) / kullanim (usage) /
// ayarlama (adjustment) / zayi (waste). Ledger additive — silinmez.
class StockMovementFormScreen extends ConsumerStatefulWidget {
  const StockMovementFormScreen({super.key, required this.drug});

  final DrugRow drug;

  @override
  ConsumerState<StockMovementFormScreen> createState() =>
      _StockMovementFormScreenState();
}

class _StockMovementFormScreenState
    extends ConsumerState<StockMovementFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantity = TextEditingController();
  final _unitPrice = TextEditingController();
  final _supplier = TextEditingController();
  final _notes = TextEditingController();
  DateTime? _expiry;
  String _movementType = 'purchase';
  bool _saving = false;

  static const _types = [
    ('purchase', 'Alis (giris)'),
    ('usage', 'Kullanim (cikis)'),
    ('adjustment', 'Ayarlama'),
    ('waste', 'Zayi'),
  ];

  @override
  void dispose() {
    _quantity.dispose();
    _unitPrice.dispose();
    _supplier.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickExpiry() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiry ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() => _expiry = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final qty =
          double.tryParse(_quantity.text.trim().replaceAll(',', '.')) ?? 0;
      final price = double.tryParse(
        _unitPrice.text.trim().replaceAll(',', '.'),
      );
      await ref.read(drugsRepositoryProvider).addStockMovement(
            drugId: widget.drug.id,
            movementType: _movementType,
            quantity: qty,
            unitPrice: price,
            expiryDate: _expiry,
            supplierName: _supplier.text.trim().isEmpty
                ? null
                : _supplier.text.trim(),
            notes:
                _notes.text.trim().isEmpty ? null : _notes.text.trim(),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hareket kaydedildi (sync bekliyor)')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kayit hatasi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final showSupplier = _movementType == 'purchase';
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.drug.name} — Stok hareketi'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DropdownButtonFormField<String>(
                initialValue: _movementType,
                decoration: const InputDecoration(
                  labelText: 'Hareket tipi',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final (v, l) in _types)
                    DropdownMenuItem(value: v, child: Text(l)),
                ],
                onChanged: (v) =>
                    setState(() => _movementType = v ?? 'purchase'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _quantity,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                decoration: InputDecoration(
                  labelText: 'Miktar (${widget.drug.unit})',
                  border: const OutlineInputBorder(),
                ),
                validator: (v) {
                  final n = double.tryParse(
                    (v ?? '').trim().replaceAll(',', '.'),
                  );
                  if (n == null || n <= 0) return 'Pozitif miktar girin';
                  return null;
                },
              ),
              if (showSupplier) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _unitPrice,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Birim fiyat (TL, opsiyonel)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _supplier,
                  decoration: const InputDecoration(
                    labelText: 'Tedarikci (opsiyonel)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _pickExpiry,
                  borderRadius: BorderRadius.circular(4),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Son kullanma tarihi (opsiyonel)',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      _expiry == null
                          ? 'Sec...'
                          : '${_expiry!.day.toString().padLeft(2, '0')}.'
                              '${_expiry!.month.toString().padLeft(2, '0')}.'
                              '${_expiry!.year}',
                      style: TextStyle(
                        color: _expiry == null
                            ? Theme.of(context).hintColor
                            : null,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              TextFormField(
                controller: _notes,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Notlar (opsiyonel)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: _green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Kaydet', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
