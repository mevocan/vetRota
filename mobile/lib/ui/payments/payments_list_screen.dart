import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/env.dart';
import '../../data/payments/payments_repository.dart';
import 'payment_form_screen.dart';

const Color _green = Color(Env.primaryColorHex);

// Global odeme ledger'i — tum klinige ait odemeler, en yeniden eskiye.
class PaymentsListScreen extends ConsumerStatefulWidget {
  const PaymentsListScreen({super.key});

  @override
  ConsumerState<PaymentsListScreen> createState() =>
      _PaymentsListScreenState();
}

class _PaymentsListScreenState extends ConsumerState<PaymentsListScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final list = ref.watch(paymentsAllProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Borc / odeme')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _green,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Yeni odeme'),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PaymentFormScreen()),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Ara (ciftci, not)',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          list.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (rows) {
              final total = rows.fold<double>(0, (s, r) => s + r.row.amount);
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Card(
                  color: _green.withValues(alpha: 0.08),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Icons.account_balance_wallet,
                            color: _green),
                        const SizedBox(width: 8),
                        const Text('Toplam (gosterilenler): '),
                        const Spacer(),
                        Text(
                          '${total.toStringAsFixed(2)} TL',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _green,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          Expanded(
            child: list.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Hata: $e')),
              data: (rows) {
                final q = _query.trim().toLowerCase();
                final filtered = q.isEmpty
                    ? rows
                    : rows.where((p) {
                        return (p.farmerName ?? '')
                                .toLowerCase()
                                .contains(q) ||
                            (p.row.notes ?? '').toLowerCase().contains(q);
                      }).toList();
                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      _query.isEmpty
                          ? 'Henuz odeme kaydi yok'
                          : 'Sonuc yok',
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final p = filtered[i];
                    final isNeg = p.row.amount < 0;
                    final color = isNeg ? Colors.red : _green;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: color.withValues(alpha: 0.15),
                        child: Icon(
                          isNeg ? Icons.remove : Icons.add,
                          color: color,
                        ),
                      ),
                      title: Text(p.farmerName ?? '—'),
                      subtitle: Text(
                        '${_fmtDate(p.row.paidAt)} · ${_methodLabel(p.row.method)}'
                        '${p.row.notes != null && p.row.notes!.isNotEmpty ? " · ${p.row.notes}" : ""}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text(
                        '${p.row.amount.toStringAsFixed(2)} TL',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.'
      '${d.month.toString().padLeft(2, '0')}.${d.year}';

  static String _methodLabel(String m) {
    switch (m) {
      case 'bank_transfer':
        return 'Havale';
      case 'credit_card':
        return 'Kart';
      case 'other':
        return 'Diger';
      default:
        return 'Nakit';
    }
  }
}
