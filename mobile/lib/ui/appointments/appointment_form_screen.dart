import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/env.dart';
import '../../data/animals/animals_repository.dart';
import '../../data/appointments/appointments_repository.dart';
import '../../data/db/app_database.dart';
import '../../data/farmers/farmers_repository.dart';
import '../farmers/farmer_picker_sheet.dart';

const Color _green = Color(Env.primaryColorHex);

class AppointmentFormScreen extends ConsumerStatefulWidget {
  const AppointmentFormScreen({super.key, this.existing});

  final AppointmentRow? existing;
  bool get isEdit => existing != null;

  @override
  ConsumerState<AppointmentFormScreen> createState() =>
      _AppointmentFormScreenState();
}

class _AppointmentFormScreenState
    extends ConsumerState<AppointmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reason = TextEditingController();
  FarmerRow? _farmer;
  AnimalRow? _animal;
  late DateTime _scheduledAt;
  String _status = 'scheduled';
  bool _saving = false;

  static const _statuses = [
    ('scheduled', 'Planlandi'),
    ('confirmed', 'Onaylandi'),
    ('in_progress', 'Suruyor'),
    ('completed', 'Tamamlandi'),
    ('cancelled', 'Iptal'),
    ('no_show', 'Gelmedi'),
  ];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _reason.text = e?.reason ?? '';
    _status = e?.status ?? 'scheduled';
    _scheduledAt =
        e?.scheduledAt ?? DateTime.now().add(const Duration(hours: 1));

    // Mevcut kayittan farmer + animal'i yukle (asenkron).
    if (e?.farmerId != null) {
      Future.microtask(() async {
        final f = await ref
            .read(farmersRepositoryProvider)
            .watchById(e!.farmerId!)
            .first;
        if (mounted) setState(() => _farmer = f);
        if (e.animalId != null && f != null) {
          final a = await ref
              .read(animalsRepositoryProvider)
              .watchById(e.animalId!)
              .first;
          if (mounted) setState(() => _animal = a);
        }
      });
    }
  }

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _pickFarmer() async {
    final picked = await FarmerPickerSheet.show(context);
    if (picked != null) {
      setState(() {
        _farmer = picked;
        _animal = null; // ciftci degisince hayvan sifirla
      });
    }
  }

  Future<void> _pickAnimal() async {
    if (_farmer == null) return;
    final animals = await ref
        .read(animalsRepositoryProvider)
        .watchByFarmer(_farmer!.id)
        .first;
    if (!mounted) return;
    if (animals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bu ciftcinin hayvani yok')),
      );
      return;
    }
    final picked = await showModalBottomSheet<AnimalRow?>(
      context: context,
      builder: (_) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('— Hayvan belirtilme —'),
              onTap: () => Navigator.pop(context, null as AnimalRow?),
            ),
            const Divider(height: 1),
            for (final a in animals)
              ListTile(
                leading: const Icon(Icons.pets),
                title: Text(a.name?.isNotEmpty == true
                    ? a.name!
                    : (a.earTag?.isNotEmpty == true
                        ? 'Kupe ${a.earTag}'
                        : 'Isimsiz hayvan')),
                subtitle: Text(a.species),
                onTap: () => Navigator.pop(context, a),
              ),
          ],
        ),
      ),
    );
    setState(() => _animal = picked);
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledAt,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_scheduledAt),
    );
    if (time == null) return;
    setState(() {
      _scheduledAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_farmer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Once ciftci secin')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final repo = ref.read(appointmentsRepositoryProvider);
      final reason = _reason.text.trim().isEmpty ? null : _reason.text.trim();
      final villageId = _animal?.villageId ?? _farmer!.villageId;
      if (widget.isEdit) {
        await repo.update(
          id: widget.existing!.id,
          farmerId: _farmer!.id,
          animalId: _animal?.id,
          villageId: villageId,
          scheduledAt: _scheduledAt,
          reason: reason,
          status: _status,
        );
      } else {
        await repo.create(
          farmerId: _farmer!.id,
          animalId: _animal?.id,
          villageId: villageId,
          scheduledAt: _scheduledAt,
          reason: reason,
          status: _status,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isEdit
              ? 'Randevu guncellendi (sync bekliyor)'
              : 'Randevu olusturuldu (sync bekliyor)'),
        ),
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
    final animalLabel = _animal == null
        ? (_farmer == null ? 'Once ciftci sec' : '— Hayvan belirtilmedi —')
        : (_animal!.name?.isNotEmpty == true
            ? _animal!.name!
            : 'Kupe ${_animal!.earTag ?? "?"}');
    final dt = _scheduledAt;
    final dtLabel =
        '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Randevuyu duzenle' : 'Yeni randevu'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              InkWell(
                onTap: _pickFarmer,
                borderRadius: BorderRadius.circular(4),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Ciftci',
                    border: const OutlineInputBorder(),
                    suffixIcon: Icon(
                      _farmer == null ? Icons.search : Icons.swap_horiz,
                    ),
                  ),
                  child: Text(
                    farmerLabel,
                    style: TextStyle(
                      fontSize: 16,
                      color: _farmer == null
                          ? Theme.of(context).hintColor
                          : null,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _farmer == null ? null : _pickAnimal,
                borderRadius: BorderRadius.circular(4),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Hayvan (opsiyonel)',
                    border: const OutlineInputBorder(),
                    suffixIcon: Icon(
                      _animal == null ? Icons.search : Icons.swap_horiz,
                    ),
                    enabled: _farmer != null,
                  ),
                  child: Text(
                    animalLabel,
                    style: TextStyle(
                      fontSize: 16,
                      color: _animal == null
                          ? Theme.of(context).hintColor
                          : null,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickDateTime,
                borderRadius: BorderRadius.circular(4),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Tarih ve saat',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(dtLabel, style: const TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: const InputDecoration(
                  labelText: 'Durum',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final (v, l) in _statuses)
                    DropdownMenuItem(value: v, child: Text(l)),
                ],
                onChanged: (v) => setState(() => _status = v ?? 'scheduled'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _reason,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Sebep / not (opsiyonel)',
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
