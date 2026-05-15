import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/env.dart';
import '../../data/drugs/drugs_repository.dart';
import 'medication_detail_screen.dart';
import 'medication_form_screen.dart';

const Color _green = Color(Env.primaryColorHex);

class MedicationsListScreen extends ConsumerStatefulWidget {
  const MedicationsListScreen({super.key});

  @override
  ConsumerState<MedicationsListScreen> createState() =>
      _MedicationsListScreenState();
}

class _MedicationsListScreenState extends ConsumerState<MedicationsListScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final list = ref.watch(drugsListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ilaclar & Stok')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _green,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Yeni ilac'),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const MedicationFormScreen()),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Ara (ad, etken madde, uretici)',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: list.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Hata: $e')),
              data: (rows) {
                final filtered = _query.trim().isEmpty
                    ? rows
                    : rows.where((d) {
                        final q = _query.trim().toLowerCase();
                        return d.drug.name.toLowerCase().contains(q) ||
                            (d.drug.activeIngredient
                                    ?.toLowerCase()
                                    .contains(q) ??
                                false) ||
                            (d.drug.manufacturer
                                    ?.toLowerCase()
                                    .contains(q) ??
                                false);
                      }).toList();
                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      _query.isEmpty ? 'Henuz ilac yok' : 'Sonuc yok',
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final dws = filtered[i];
                    final d = dws.drug;
                    final qty = dws.hasStock
                        ? '${_fmtNum(dws.currentQuantity)} ${d.unit}'
                        : 'stok yok';
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: d.isVaccine
                            ? Colors.purple.shade100
                            : _green.withValues(alpha: 0.15),
                        child: Icon(
                          d.isVaccine ? Icons.vaccines : Icons.medication,
                          color: d.isVaccine ? Colors.purple : _green,
                        ),
                      ),
                      title: Text(d.name),
                      subtitle: Text(
                        [
                          if (d.activeIngredient != null &&
                              d.activeIngredient!.isNotEmpty)
                            d.activeIngredient,
                          _drugTypeLabel(d.drugType),
                        ].where((s) => s != null && s.isNotEmpty).join(' · '),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            qty,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: dws.isLow ? Colors.red : Colors.black87,
                            ),
                          ),
                          if (dws.isLow)
                            const Text(
                              'kritik',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.red,
                              ),
                            ),
                        ],
                      ),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              MedicationDetailScreen(drugId: d.id),
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

  String _fmtNum(double v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(2);
  }

  String _drugTypeLabel(String t) {
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
