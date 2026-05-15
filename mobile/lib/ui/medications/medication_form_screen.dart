import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/env.dart';
import '../../data/db/app_database.dart';
import '../../data/drugs/drugs_repository.dart';

const Color _green = Color(Env.primaryColorHex);

class MedicationFormScreen extends ConsumerStatefulWidget {
  const MedicationFormScreen({super.key, this.existing});

  final DrugRow? existing;
  bool get isEdit => existing != null;

  @override
  ConsumerState<MedicationFormScreen> createState() =>
      _MedicationFormScreenState();
}

class _MedicationFormScreenState extends ConsumerState<MedicationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _activeIngredient;
  late final TextEditingController _manufacturer;
  late final TextEditingController _packageSize;
  late String _drugType;
  late String _unit;
  late bool _isVaccine;
  bool _saving = false;

  static const _drugTypes = [
    ('antibiotic', 'Antibiyotik'),
    ('vaccine', 'Asi'),
    ('antiparasitic', 'Antiparaziter'),
    ('antiinflammatory', 'Antienflamatuar'),
    ('analgesic', 'Agri kesici'),
    ('vitamin', 'Vitamin'),
    ('hormone', 'Hormon'),
    ('other', 'Diger'),
  ];

  static const _units = [
    ('ml', 'ml'),
    ('tablet', 'tablet'),
    ('doz', 'doz'),
    ('g', 'g'),
    ('flakon', 'flakon'),
    ('ampul', 'ampul'),
  ];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _activeIngredient = TextEditingController(text: e?.activeIngredient ?? '');
    _manufacturer = TextEditingController(text: e?.manufacturer ?? '');
    _packageSize = TextEditingController(
      text: e?.packageSize?.toString() ?? '',
    );
    _drugType = e?.drugType ?? 'antibiotic';
    _unit = e?.unit ?? 'ml';
    _isVaccine = e?.isVaccine ?? false;
  }

  @override
  void dispose() {
    _name.dispose();
    _activeIngredient.dispose();
    _manufacturer.dispose();
    _packageSize.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final repo = ref.read(drugsRepositoryProvider);
      final packageSize = double.tryParse(
        _packageSize.text.trim().replaceAll(',', '.'),
      );
      final name = _name.text.trim();
      final activeIngredient = _activeIngredient.text.trim().isEmpty
          ? null
          : _activeIngredient.text.trim();
      final manufacturer = _manufacturer.text.trim().isEmpty
          ? null
          : _manufacturer.text.trim();

      if (widget.isEdit) {
        await repo.update(
          id: widget.existing!.id,
          name: name,
          drugType: _drugType,
          unit: _unit,
          activeIngredient: activeIngredient,
          manufacturer: manufacturer,
          packageSize: packageSize,
          isVaccine: _isVaccine,
        );
      } else {
        await repo.create(
          name: name,
          drugType: _drugType,
          unit: _unit,
          activeIngredient: activeIngredient,
          manufacturer: manufacturer,
          packageSize: packageSize,
          isVaccine: _isVaccine,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isEdit
              ? 'Ilac guncellendi (sync bekliyor)'
              : 'Ilac eklendi (sync bekliyor)'),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Ilaci duzenle' : 'Yeni ilac'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: 'Ilac adi',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Ad zorunlu' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _activeIngredient,
                decoration: const InputDecoration(
                  labelText: 'Etken madde (opsiyonel)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _manufacturer,
                decoration: const InputDecoration(
                  labelText: 'Uretici (opsiyonel)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _drugType,
                decoration: const InputDecoration(
                  labelText: 'Tur',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final (v, l) in _drugTypes)
                    DropdownMenuItem(value: v, child: Text(l)),
                ],
                onChanged: (v) => setState(() {
                  _drugType = v ?? 'antibiotic';
                  if (_drugType == 'vaccine') _isVaccine = true;
                }),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _unit,
                decoration: const InputDecoration(
                  labelText: 'Birim',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final (v, l) in _units)
                    DropdownMenuItem(value: v, child: Text(l)),
                ],
                onChanged: (v) => setState(() => _unit = v ?? 'ml'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _packageSize,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Ambalaj boyutu (opsiyonel)',
                  helperText: 'Birim cinsinden, orn. 100',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Asi mi?'),
                subtitle:
                    const Text('Asi takvimi ve hatirlatici icin gerekli'),
                value: _isVaccine,
                activeThumbColor: _green,
                onChanged: (v) => setState(() => _isVaccine = v),
              ),
              const SizedBox(height: 16),
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
