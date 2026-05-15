import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/env.dart';
import '../../data/db/app_database.dart';
import '../../data/farmers/farmers_repository.dart';
import '../../data/payments/payments_repository.dart';
import '../farmers/farmer_picker_sheet.dart';

const Color _green = Color(Env.primaryColorHex);

// Yeni odeme girisi. farmer pre-fill ile farmer ledger ekranindan da
// acilabilir.
class PaymentFormScreen extends ConsumerStatefulWidget {
  const PaymentFormScreen({super.key, this.initialFarmer});

  final FarmerRow? initialFarmer;

  @override
  ConsumerState<PaymentFormScreen> createState() =>
      _PaymentFormScreenState();
}

class _PaymentFormScreenState extends ConsumerState<PaymentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtl = TextEditingController();
  final _notesCtl = TextEditingController();
  String _method = 'cash';
  DateTime _paidAt = DateTime.now();
  FarmerRow? _farmer;
  bool _saving = false;

  static const _methods = [
    ('cash', 'Nakit'),
    ('bank_transfer', 'Havale/EFT'),
    ('credit_card', 'Kredi karti'),
    ('other', 'Diger'),
  ];

  @override
  void initState() {
    super.initState();
    _farmer = widget.initialFarmer;
  }

  @override
  void dispose() {
    _amountCtl.dispose();
    _notesCtl.dispose();
    super.dispose();
  }

  Future<void> _pickFarmer() async {
    final picked = await FarmerPickerSheet.show(context);
    if (picked != null) setState(() => _farmer = picked);
  }

  Future<void> _pickPaidAt() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _paidAt,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      lastDate: DateTime.now().add(const Duration(days: 7)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_paidAt),
    );
    if (time == null) return;
    setState(() => _paidAt =
        DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_farmer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Once ciftci secin')),
      );
      return;
    }
    final amount = double.tryParse(
      _amountCtl.text.trim().replaceAll(',', '.'),
    );
    if (amount == null || amount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tutar 0 olamaz')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(paymentsRepositoryProvider).create(
            farmerId: _farmer!.id,
            amount: amount,
            method: _method,
            paidAt: _paidAt,
            notes: _notesCtl.text.trim().isEmpty
                ? null
                : _notesCtl.text.trim(),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Odeme kaydedildi (sync bekliyor)')),
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
    final farmerLabel = _farmer == null
        ? 'Ciftci sec'
        : '${_farmer!.firstName} ${_farmer!.lastName}';
    final dt = _paidAt;
    final dtLabel =
        '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    return Scaffold(
      appBar: AppBar(title: const Text('Yeni odeme')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              InkWell(
                onTap: widget.initialFarmer != null ? null : _pickFarmer,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Ciftci',
                    border: const OutlineInputBorder(),
                    suffixIcon: widget.initialFarmer != null
                        ? null
                        : const Icon(Icons.search),
                  ),
                  child: Text(farmerLabel,
                      style: TextStyle(
                        color: _farmer == null
                            ? Theme.of(context).hintColor
                            : null,
                      )),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountCtl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,\-]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Tutar (TL)',
                  helperText: 'Iptal/dusum icin negatif tutar girin',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  final n = double.tryParse(
                    (v ?? '').trim().replaceAll(',', '.'),
                  );
                  if (n == null) return 'Gecerli tutar girin';
                  if (n == 0) return '0 olamaz';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _method,
                decoration: const InputDecoration(
                  labelText: 'Yontem',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final (v, l) in _methods)
                    DropdownMenuItem(value: v, child: Text(l)),
                ],
                onChanged: (v) => setState(() => _method = v ?? 'cash'),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickPaidAt,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Tarih ve saat',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(dtLabel),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesCtl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Not (opsiyonel)',
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
