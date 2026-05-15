import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/env.dart';
import '../../data/animals/animals_repository.dart';
import '../../data/db/app_database.dart';
import '../../data/farmers/farmers_repository.dart';
import '../../data/vaccinations/vaccine_schedules_repository.dart';
import '../farmers/farmer_picker_sheet.dart';

const Color _green = Color(Env.primaryColorHex);

class VaccineScheduleFormScreen extends ConsumerStatefulWidget {
  const VaccineScheduleFormScreen({super.key, this.initialAnimal});

  final AnimalRow? initialAnimal;

  @override
  ConsumerState<VaccineScheduleFormScreen> createState() =>
      _VaccineScheduleFormScreenState();
}

class _VaccineScheduleFormScreenState
    extends ConsumerState<VaccineScheduleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _intervalCtl = TextEditingController(text: '180');
  final _remindCtl = TextEditingController(text: '7');
  final _notesCtl = TextEditingController();
  DateTime _firstDue = DateTime.now().add(const Duration(days: 7));
  FarmerRow? _farmer;
  AnimalRow? _animal;
  DrugRow? _drug;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialAnimal != null) {
      _animal = widget.initialAnimal;
      // farmer otomatik yuklenir
      Future.microtask(() async {
        final f = await ref
            .read(farmersRepositoryProvider)
            .watchById(widget.initialAnimal!.farmerId)
            .first;
        if (mounted) setState(() => _farmer = f);
      });
    }
  }

  @override
  void dispose() {
    _intervalCtl.dispose();
    _remindCtl.dispose();
    _notesCtl.dispose();
    super.dispose();
  }

  Future<void> _pickFarmer() async {
    final picked = await FarmerPickerSheet.show(context);
    if (picked != null) {
      setState(() {
        _farmer = picked;
        _animal = null;
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
            for (final a in animals)
              ListTile(
                leading: const Icon(Icons.pets),
                title: Text(a.name?.isNotEmpty == true
                    ? a.name!
                    : 'Kupe ${a.earTag ?? "?"}'),
                subtitle: Text(a.species),
                onTap: () => Navigator.pop(context, a),
              ),
          ],
        ),
      ),
    );
    if (picked != null) setState(() => _animal = picked);
  }

  Future<void> _pickDrug() async {
    final drugs =
        await ref.read(vaccineDrugsProvider.future);
    if (!mounted) return;
    if (drugs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Asi olan ilac yok. Once Ilaclar > Yeni ile ekleyin.')),
      );
      return;
    }
    final picked = await showModalBottomSheet<DrugRow?>(
      context: context,
      builder: (_) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final d in drugs)
              ListTile(
                leading: const Icon(Icons.vaccines, color: Colors.purple),
                title: Text(d.name),
                subtitle: d.activeIngredient == null
                    ? null
                    : Text(d.activeIngredient!),
                onTap: () => Navigator.pop(context, d),
              ),
          ],
        ),
      ),
    );
    if (picked != null) setState(() => _drug = picked);
  }

  Future<void> _pickFirstDue() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _firstDue,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) setState(() => _firstDue = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_animal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hayvan secin')),
      );
      return;
    }
    if (_drug == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Asi (ilac) secin')),
      );
      return;
    }
    final interval = int.tryParse(_intervalCtl.text.trim()) ?? 0;
    final remind = int.tryParse(_remindCtl.text.trim()) ?? 7;
    if (interval <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aralik 1 veya daha buyuk olmali')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(vaccineSchedulesRepositoryProvider).create(
            animalId: _animal!.id,
            drugId: _drug!.id,
            intervalDays: interval,
            firstDueDate: _firstDue,
            remindDaysBefore: remind,
            notes: _notesCtl.text.trim().isEmpty
                ? null
                : _notesCtl.text.trim(),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Asi plani eklendi (sync bekliyor)')),
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
        ? (_farmer == null ? 'Once ciftci sec' : 'Hayvan sec')
        : (_animal!.name?.isNotEmpty == true
            ? _animal!.name!
            : 'Kupe ${_animal!.earTag ?? "?"}');
    final drugLabel = _drug == null ? 'Asi (ilac) sec' : _drug!.name;
    final dueLabel =
        '${_firstDue.day.toString().padLeft(2, '0')}.${_firstDue.month.toString().padLeft(2, '0')}.${_firstDue.year}';

    return Scaffold(
      appBar: AppBar(title: const Text('Yeni asi plani')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              InkWell(
                onTap: _pickFarmer,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Ciftci',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.search),
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
              InkWell(
                onTap: _farmer == null ? null : _pickAnimal,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Hayvan',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.search),
                  ),
                  child: Text(animalLabel,
                      style: TextStyle(
                        color: _animal == null
                            ? Theme.of(context).hintColor
                            : null,
                      )),
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickDrug,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Asi',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.vaccines),
                  ),
                  child: Text(drugLabel,
                      style: TextStyle(
                        color: _drug == null
                            ? Theme.of(context).hintColor
                            : null,
                      )),
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickFirstDue,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Ilk yapilacak tarih',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.event),
                  ),
                  child: Text(dueLabel),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _intervalCtl,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: const InputDecoration(
                  labelText: 'Tekrar araligi (gun)',
                  border: OutlineInputBorder(),
                  helperText: 'Orn. 180 = 6 ay',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _remindCtl,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: const InputDecoration(
                  labelText: 'Hatirlatma (gun once)',
                  border: OutlineInputBorder(),
                  helperText: 'Kac gun once SMS gitsin',
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
