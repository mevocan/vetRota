import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../config/env.dart';
import '../../data/db/app_database.dart';
import '../../data/photos/photos_repository.dart';

const Color _green = Color(Env.primaryColorHex);

// Hayvan detayinda kronolojik foto seridi (en yeni solda).
// Local foto varsa file:// gosterir; sadece server path varsa
// "indirilmedi" placeholder'i (M4.6 MVP — full download cache sonra).
class PhotoStripForAnimal extends ConsumerWidget {
  const PhotoStripForAnimal({super.key, required this.animalId});

  final String animalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPhotos = ref.watch(photosByAnimalProvider(animalId));
    return asyncPhotos.when(
      loading: () => const SizedBox.shrink(),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Foto hatasi: $e'),
      ),
      data: (photos) {
        if (photos.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Fotograflar (${photos.length})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 110,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: photos.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => _PhotoTile(photo: photos[i]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({required this.photo});
  final MedicalRecordPhotoRow photo;

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('dd.MM.yyyy').format(photo.takenAt.toLocal());
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => _PhotoFullScreen(photo: photo),
          ),
        );
      },
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _Thumbnail(photo: photo),
              ),
              if (photo.uploadStatus == LocalUploadStatus.pending)
                const Positioned(
                  top: 4,
                  right: 4,
                  child: Icon(
                    Icons.cloud_upload,
                    size: 14,
                    color: Colors.orange,
                  ),
                ),
              if (photo.uploadStatus == LocalUploadStatus.failed)
                const Positioned(
                  top: 4,
                  right: 4,
                  child: Icon(
                    Icons.cloud_off,
                    size: 14,
                    color: Colors.red,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(dateLabel, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.photo});
  final MedicalRecordPhotoRow photo;

  @override
  Widget build(BuildContext context) {
    if (photo.localPath != null && File(photo.localPath!).existsSync()) {
      return Image.file(
        File(photo.localPath!),
        width: 80,
        height: 80,
        fit: BoxFit.cover,
      );
    }
    // Lokalde yok, sadece server'da var. Ag indirme M4.6+ TODO.
    return Container(
      width: 80,
      height: 80,
      color: Colors.black12,
      child: const Center(
        child: Icon(Icons.cloud_download, color: Colors.black38),
      ),
    );
  }
}

class _PhotoFullScreen extends StatelessWidget {
  const _PhotoFullScreen({required this.photo});
  final MedicalRecordPhotoRow photo;

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('dd.MM.yyyy HH:mm')
        .format(photo.takenAt.toLocal());
    final hasLocal =
        photo.localPath != null && File(photo.localPath!).existsSync();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(dateLabel),
      ),
      body: Center(
        child: hasLocal
            ? InteractiveViewer(
                child: Image.file(File(photo.localPath!)),
              )
            : Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.cloud_download,
                        size: 64, color: Colors.white54),
                    SizedBox(height: 16),
                    Text(
                      'Bu foto henuz cihaza indirilmedi.\n'
                      'Server URL: indirme cache MVP sonrasi.',
                      style: TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: photo.caption == null
          ? null
          : Container(
              padding: const EdgeInsets.all(16),
              color: _green.withValues(alpha: 0.9),
              child: Text(
                photo.caption!,
                style: const TextStyle(color: Colors.white),
              ),
            ),
    );
  }
}
