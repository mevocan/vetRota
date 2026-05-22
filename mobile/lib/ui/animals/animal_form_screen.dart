import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/env.dart';
import '../../data/animals/animals_repository.dart';
import '../../data/db/app_database.dart';
import '../farmers/farmer_picker_sheet.dart';

const Color _green = Color(Env.primaryColorHex);

// Yeni hayvan formu — offline-first: kayit Drift'e yazilir.
// Ciftci secimi FarmerPickerSheet ile yapilir; ciftci yoksa sheet
// icinden yeni ciftci eklenebilir.
class AnimalFormScreen extends ConsumerStatefulWidget {
  const AnimalFormScreen({super.key});

  @override
  ConsumerState<AnimalFormScreen> createState() => _AnimalFormScreenState();
}

class _AnimalFormScreenState extends ConsumerState<AnimalFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _earTagController = TextEditingController();
  final _breedController = TextEditingController();
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();

  FarmerRow? _selectedFarmer;
  String _species = 'cattle';
  String? _gender;
  bool _saving = false;

  static const _speciesOptions = [
    ('cattle', 'Sigir'),
    ('sheep', 'Koyun'),
    ('goat', 'Keci'),
    ('horse', 'At'),
    ('dog', 'Kopek'),
    ('cat', 'Kedi'),
    ('poultry', 'Kanatli'),
    ('other', 'Diger'),
  ];

  // Backend gender'i zorunlu tutuyor (animals.gender NOT NULL). 'unknown'
  // secenegi, cinsiyeti bilinmeyen hayvanlar icin gecerli bir deger saglar.
  static const _genderOptions = [
    ('male', 'Erkek'),
    ('female', 'Disi'),
    ('unknown', 'Bilinmiyor'),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _earTagController.dispose();
    _breedController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickFarmer() async {
    final picked = await FarmerPickerSheet.show(context);
    if (picked != null) {
      setState(() => _selectedFarmer = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFarmer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Once ciftci secin')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(animalsRepositoryProvider).create(
            farmerId: _selectedFarmer!.id,
            villageId: _selectedFarmer!.villageId,
            species: _species,
            name: _nameController.text.trim().isEmpty
                ? null
                : _nameController.text.trim(),
            earTag: _earTagController.text.trim().isEmpty
                ? null
                : _earTagController.text.trim(),
            breed: _breedController.text.trim().isEmpty
                ? null
                : _breedController.text.trim(),
            gender: _gender,
            weightKg: double.tryParse(
              _weightController.text.trim().replaceAll(',', '.'),
            ),
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hayvan kaydedildi (sync bekliyor)')),
        );
        Navigator.of(context).pop();
      }
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
    final farmerLabel = _selectedFarmer == null
        ? 'Ciftci sec'
        : '${_selectedFarmer!.firstName} ${_selectedFarmer!.lastName}';
    return Scaffold(
      appBar: AppBar(title: const Text('Yeni hayvan')),
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
                      _selectedFarmer == null
                          ? Icons.search
                          : Icons.swap_horiz,
                    ),
                  ),
                  child: Text(
                    farmerLabel,
                    style: TextStyle(
                      fontSize: 16,
                      color: _selectedFarmer == null
                          ? Theme.of(context).hintColor
                          : null,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _species,
                decoration: const InputDecoration(
                  labelText: 'Tur',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final (value, label) in _speciesOptions)
                    DropdownMenuItem(value: value, child: Text(label)),
                ],
                onChanged: (v) => setState(() => _species = v ?? 'cattle'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Isim (opsiyonel)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _earTagController,
                decoration: const InputDecoration(
                  labelText: 'Kupe no (opsiyonel)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _breedController,
                decoration: const InputDecoration(
                  labelText: 'Irk (opsiyonel)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                initialValue: _gender,
                decoration: const InputDecoration(
                  labelText: 'Cinsiyet',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final (value, label) in _genderOptions)
                    DropdownMenuItem<String?>(value: value, child: Text(label)),
                ],
                validator: (v) => v == null ? 'Cinsiyet secin' : null,
                onChanged: (v) => setState(() => _gender = v),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Agirlik (kg, opsiyonel)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notlar (opsiyonel)',
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
