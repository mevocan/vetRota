<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1\Sync;

use App\Http\Controllers\Controller;
use App\Http\Requests\Sync\SyncPhotoUploadRequest;
use App\Models\MedicalRecord;
use App\Models\MedicalRecordPhoto;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Storage;

// M4.2: muayene fotograflari icin ayri kanal. /sync/push metadata'yi
// alabilir ama binary yuk transaction'i kirar; ayri endpoint multipart
// stream ile dosyayi storage'a yazar, metadata kaydini olusturur.
//
// sync-api.md §6 paterni: idempotency anahtari client UUID (id alani) —
// ayni id ikinci kez gelirse mevcut kaydi doner, dosyayi tekrar yazar
// (overwrite), yeni satir uretmez.
class SyncPhotoController extends Controller
{
    public function __invoke(SyncPhotoUploadRequest $request): JsonResponse
    {
        /** @var \App\Models\User $user */
        $user = auth()->user();
        $clinicId = $user->clinic_id;
        $deviceId = $request->attributes->get('device_id');

        $photoId = $request->input('id');
        $animalId = $request->input('animal_id');
        $mrId = $request->input('medical_record_id');

        // Tenant ihlali kontrolu — muayene baska kliniginki olmasin.
        $mr = MedicalRecord::where('id', $mrId)->where('clinic_id', $clinicId)->first();
        if (!$mr) {
            return response()->json([
                'error' => 'medical_record_not_in_clinic',
            ], 403);
        }

        $file = $request->file('photo');
        $ext = $file->getClientOriginalExtension() ?: $file->extension();
        $relPath = "photos/{$clinicId}/{$animalId}/{$photoId}.{$ext}";

        // Yazimi tek transaction'da tutmuyoruz — dosya yazimi rollback
        // edilemez. Once dosyayi yaz, sonra metadata upsert; metadata
        // hatasinda dosya kalir (orphan), gunluk cron silebilir.
        Storage::disk('local')->put($relPath, file_get_contents($file->getRealPath()));

        $photo = MedicalRecordPhoto::updateOrCreate(
            ['id' => $photoId],
            [
                'clinic_id' => $clinicId,
                'medical_record_id' => $mrId,
                'animal_id' => $animalId,
                'storage_path' => $relPath,
                'original_filename' => $file->getClientOriginalName(),
                'mime_type' => $file->getMimeType(),
                'size_bytes' => $file->getSize(),
                'taken_at' => $request->input('taken_at'),
                'caption' => $request->input('caption'),
                'origin_device_id' => $deviceId,
            ],
        );

        // refresh ki trigger'in doldurdugu version + last_modified_at gelsin.
        $photo->refresh();

        return response()->json([
            'id' => $photo->id,
            'storage_path' => $photo->storage_path,
            'version' => $photo->version,
            'last_modified_at' => $photo->last_modified_at?->toIso8601String(),
        ]);
    }
}
