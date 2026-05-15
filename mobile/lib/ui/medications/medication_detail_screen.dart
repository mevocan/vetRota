import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/env.dart';
import '../../data/db/app_database.dart';
import '../../data/drugs/drugs_repository.dart';
import 'medication_form_screen.dart';
import 'stock_movement_form_screen.dart';

const Color _green = Color(Env.primaryColorHex);

class MedicationDetailScreen extends ConsumerWidget {
  const MedicationDetailScreen({super.key, required this.drugId});

  final String drugId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drugAsync = ref.watch(drugByIdProvider(drugId));
    final stockAsync = ref.watch(drugStockProvider(drugId));
    final movementsAsync = ref.watch(drugMovementsProvider(drugId));

    return Scaffold(
      appBar: AppBar(
        title: drugAsync.maybeWhen(
          data: (d) => Text(d?.name ?? 'Ilac'),
          orElse: () => const Text('Ilac'),
        ),
        actions: [
          drugAsync.maybeWhen(
            data: (d) => d == null
                ? const SizedBox.shrink()
                : IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: 'Duzenle',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            MedicationFormScreen(existing: d),
                      ),
                    ),
                  ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      floatingActionButton: drugAsync.maybeWhen(
        data: (d) => d == null
            ? null
            : FloatingActionButton.extended(
                backgroundColor: _green,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.add),
                label: const Text('Stok hareketi'),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => StockMovementFormScreen(drug: d),
                  ),
                ),
              ),
        orElse: () => null,
      ),
      body: drugAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
        data: (drug) {
          if (drug == null) {
            return const Center(child: Text('Ilac bulunamadi'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _InfoCard(drug: drug),
              const SizedBox(height: 12),
              stockAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
                data: (s) => _StockCard(stock: s, unit: drug.unit),
              ),
              const SizedBox(height: 16),
              Text(
                'Stok hareketleri',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              movementsAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (e, _) => Text('Hata: $e'),
                data: (ms) {
                  if (ms.isEmpty) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Henuz hareket yok'),
                      ),
                    );
                  }
                  return Card(
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: ms.length,
                      separatorBuilder: (_, _) =>
                          const Divider(height: 1),
                      itemBuilder: (_, i) =>
                          _MovementTile(m: ms[i], unit: drug.unit),
                    ),
                  );
                },
              ),
              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.drug});
  final DrugRow drug;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  drug.isVaccine ? Icons.vaccines : Icons.medication,
                  color: drug.isVaccine ? Colors.purple : _green,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    drug.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (drug.activeIngredient != null &&
                drug.activeIngredient!.isNotEmpty)
              _kv('Etken madde', drug.activeIngredient!),
            if (drug.manufacturer != null && drug.manufacturer!.isNotEmpty)
              _kv('Uretici', drug.manufacturer!),
            _kv('Tur', _drugTypeLabel(drug.drugType)),
            _kv('Birim', drug.unit),
            if (drug.packageSize != null)
              _kv('Ambalaj', '${drug.packageSize} ${drug.unit}'),
            if (drug.isVaccine) _kv('Asi', 'evet'),
          ],
        ),
      ),
    );
  }

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            SizedBox(
              width: 110,
              child: Text(k,
                  style: const TextStyle(color: Colors.black54)),
            ),
            Expanded(child: Text(v)),
          ],
        ),
      );

  static String _drugTypeLabel(String t) {
    switch (t) {
      case 'antibiotic':
        return 'Antibiyotik';
      case 'vaccine':
        return 'Asi';
      case 'antiparasitic':
        return 'Antiparaziter';
      case 'antiinflammatory':
        return 'Antienflamatuar';
      case 'analgesic':
        return 'Agri kesici';
      case 'vitamin':
        return 'Vitamin';
      case 'hormone':
        return 'Hormon';
      default:
        return 'Diger';
    }
  }
}

class _StockCard extends StatelessWidget {
  const _StockCard({required this.stock, required this.unit});
  final StockRow? stock;
  final String unit;

  @override
  Widget build(BuildContext context) {
    if (stock == null) {
      return Card(
        color: Colors.grey.shade100,
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Bu ilac icin henuz stok kaydi yok. Ilk hareketi ekleyince '
            'olusturulur.',
          ),
        ),
      );
    }
    final s = stock!;
    final isLow = s.criticalThreshold != null &&
        s.currentQuantity <= s.criticalThreshold!;
    return Card(
      color: isLow ? Colors.red.shade50 : _green.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              isLow ? Icons.warning_amber : Icons.inventory_2,
              size: 32,
              color: isLow ? Colors.red : _green,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_fmt(s.currentQuantity)} $unit',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isLow ? Colors.red : Colors.black87,
                        ),
                  ),
                  if (s.criticalThreshold != null)
                    Text(
                      'Kritik esik: ${_fmt(s.criticalThreshold!)} $unit',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.black54),
                    ),
                  if (s.earliestExpiryAt != null)
                    Text(
                      'Yakin SKT: ${s.earliestExpiryAt!.day.toString().padLeft(2, '0')}.'
                      '${s.earliestExpiryAt!.month.toString().padLeft(2, '0')}.'
                      '${s.earliestExpiryAt!.year}',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.black54),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _fmt(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(2);
}

class _MovementTile extends StatelessWidget {
  const _MovementTile({required this.m, required this.unit});
  final StockMovementRow m;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final isIn = m.movementType == 'purchase' || m.movementType == 'adjustment';
    final color = isIn ? Colors.green.shade700 : Colors.red.shade700;
    final sign = isIn ? '+' : '−';
    return ListTile(
      dense: true,
      leading: Icon(
        isIn ? Icons.arrow_downward : Icons.arrow_upward,
        color: color,
      ),
      title: Text('$sign${_fmt(m.quantity)} $unit'),
      subtitle: Text(
        '${_typeLabel(m.movementType)} · '
        '${m.occurredAt.day.toString().padLeft(2, '0')}.'
        '${m.occurredAt.month.toString().padLeft(2, '0')}.'
        '${m.occurredAt.year}'
        '${m.supplierName != null ? " · ${m.supplierName}" : ""}',
        style: const TextStyle(fontSize: 12),
      ),
      trailing: m.unitPrice != null
          ? Text(
              '${m.unitPrice!.toStringAsFixed(2)} TL',
              style: const TextStyle(fontSize: 12),
            )
          : null,
    );
  }

  static String _fmt(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(2);

  static String _typeLabel(String t) {
    switch (t) {
      case 'purchase':
        return 'Alis';
      case 'usage':
        return 'Kullanim';
      case 'adjustment':
        return 'Ayarlama';
      case 'waste':
        return 'Zayi';
      default:
        return t;
    }
  }
}
