import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/env.dart';
import '../../data/db/app_database.dart';
import '../../data/farmers/farmers_repository.dart';
import 'farmer_form_screen.dart';

const Color _green = Color(Env.primaryColorHex);

// Ciftciler liste ekrani — arama + yeni + duzenleme.
class FarmersListScreen extends ConsumerStatefulWidget {
  const FarmersListScreen({super.key});

  @override
  ConsumerState<FarmersListScreen> createState() => _FarmersListScreenState();
}

class _FarmersListScreenState extends ConsumerState<FarmersListScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final list = ref.watch(farmersSearchProvider(_query));

    return Scaffold(
      appBar: AppBar(title: const Text('Ciftciler')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _green,
        foregroundColor: Colors.white,
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const FarmerFormScreen()),
        ),
        icon: const Icon(Icons.person_add),
        label: const Text('Yeni'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Ara (ad, soyad, telefon)',
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
                if (rows.isEmpty) {
                  return Center(
                    child: Text(
                      _query.isEmpty ? 'Henuz ciftci yok' : 'Sonuc yok',
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: rows.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
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
                      trailing: f.localSyncStatus == LocalSyncStatus.pending
                          ? const Icon(Icons.sync_problem,
                              size: 18, color: Colors.orange)
                          : null,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => FarmerFormScreen(existing: f),
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
}
