import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/farmers/farmers_repository.dart';
import '../../data/payments/payments_repository.dart';

// M7.3: Hayvan detayinda sahibi bakiyesi + 'Odeme al' aksiyonu.
// balance: pozitif = avans (alacak ciftcide degil veterinerde), negatif = borc.
class FarmerBalanceCard extends ConsumerWidget {
  const FarmerBalanceCard({super.key, required this.farmerId});

  final String farmerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncFarmer = ref.watch(farmerByIdProvider(farmerId));
    return asyncFarmer.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (f) {
        if (f == null) return const SizedBox.shrink();
        final balance = f.balance;
        final hasDebt = balance < 0;
        final color = hasDebt
            ? Colors.red.shade50
            : (balance > 0 ? Colors.green.shade50 : Colors.grey.shade50);
        final borderColor = hasDebt
            ? Colors.red.shade200
            : (balance > 0 ? Colors.green.shade200 : Colors.grey.shade300);
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: hasDebt ? Colors.red : Colors.green,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${f.firstName} ${f.lastName}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        hasDebt
                            ? 'Borc: ${(-balance).toStringAsFixed(2)} TL'
                            : (balance > 0
                                ? 'Avans: ${balance.toStringAsFixed(2)} TL'
                                : 'Bakiye: 0.00 TL'),
                        style: TextStyle(
                          color: hasDebt ? Colors.red.shade700 : Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _openSheet(context, ref, f.id),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Odeme al'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openSheet(BuildContext context, WidgetRef ref, String farmerId) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _PaymentSheet(farmerId: farmerId),
    );
  }
}

class _PaymentSheet extends ConsumerStatefulWidget {
  const _PaymentSheet({required this.farmerId});
  final String farmerId;

  @override
  ConsumerState<_PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends ConsumerState<_PaymentSheet> {
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _method = 'cash';
  bool _saving = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final raw = _amountCtrl.text.trim().replaceAll(',', '.');
    final amount = double.tryParse(raw);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gecerli bir tutar girin (>0)')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(paymentsRepositoryProvider).create(
            farmerId: widget.farmerId,
            amount: amount,
            method: _method,
            notes: _notesCtrl.text.trim().isEmpty
                ? null
                : _notesCtrl.text.trim(),
          );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(
          'Odeme kaydedildi (${amount.toStringAsFixed(2)} TL, sync bekliyor)',
        )),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20, 0, 20, 20 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Odeme al',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            TextField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*[.,]?\d{0,2}')),
              ],
              decoration: const InputDecoration(
                labelText: 'Tutar (TL)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _method,
              decoration: const InputDecoration(
                labelText: 'Yontem',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'cash', child: Text('Nakit')),
                DropdownMenuItem(value: 'transfer', child: Text('Havale')),
                DropdownMenuItem(value: 'other', child: Text('Diger')),
              ],
              onChanged: (v) => setState(() => _method = v ?? 'cash'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Not (opsiyonel)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: const Icon(Icons.check),
              label: Text(_saving ? 'Kaydediliyor...' : 'Kaydet'),
            ),
          ],
        ),
      ),
    );
  }
}
