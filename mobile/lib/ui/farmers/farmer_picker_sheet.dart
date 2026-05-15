import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/env.dart';
import '../../data/db/app_database.dart';
import '../../data/farmers/farmers_repository.dart';
import 'farmer_form_screen.dart';

const Color _green = Color(Env.primaryColorHex);

// Hayvan formundan acilir bottom sheet: arama + liste + "Yeni ciftci"
// butonu. Sectiginde FarmerRow doner. Offline calismas — Drift stream'i.
class FarmerPickerSheet extends ConsumerStatefulWidget {
  const FarmerPickerSheet({super.key});

  static Future<FarmerRow?> show(BuildContext context) {
    return showModalBottomSheet<FarmerRow>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const FarmerPickerSheet(),
    );
  }

  @override
  ConsumerState<FarmerPickerSheet> createState() => _FarmerPickerSheetState();
}

class _FarmerPickerSheetState extends ConsumerState<FarmerPickerSheet> {
  String _query = '';

  Future<void> _addNew() async {
    final created = await Navigator.of(context).push<FarmerRow>(
      MaterialPageRoute(builder: (_) => const FarmerFormScreen()),
    );
    if (created != null && mounted) {
      Navigator.of(context).pop(created);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    final list = ref.watch(farmersSearchProvider(_query));

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      autofocus: false,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Ciftci ara (ad, soyad, telefon)',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (v) => setState(() => _query = v),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _addNew,
                    style: IconButton.styleFrom(backgroundColor: _green),
                    icon: const Icon(Icons.person_add, color: Colors.white),
                    tooltip: 'Yeni ciftci',
                  ),
                ],
              ),
            ),
            Expanded(
              child: list.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Hata: $e')),
                data: (rows) {
                  if (rows.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.people_outline,
                                size: 48, color: Colors.grey),
                            const SizedBox(height: 12),
                            Text(
                              _query.isEmpty
                                  ? 'Henuz ciftci yok'
                                  : 'Sonuc bulunamadi',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 12),
                            FilledButton.icon(
                              onPressed: _addNew,
                              style: FilledButton.styleFrom(
                                backgroundColor: _green,
                              ),
                              icon: const Icon(Icons.person_add),
                              label: const Text('Yeni ciftci ekle'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: rows.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final f = rows[i];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _green.withValues(alpha: 0.15),
                          child: Text(
                            (f.firstName.isNotEmpty ? f.firstName[0] : '?')
                                .toUpperCase(),
                            style: const TextStyle(color: _green),
                          ),
                        ),
                        title: Text('${f.firstName} ${f.lastName}'),
                        subtitle: f.phone == null || f.phone!.isEmpty
                            ? null
                            : Text(f.phone!),
                        onTap: () => Navigator.of(context).pop(f),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
