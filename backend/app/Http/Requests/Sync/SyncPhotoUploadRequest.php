<?php

declare(strict_types=1);

namespace App\Http\Requests\Sync;

use Illuminate\Foundation\Http\FormRequest;

class SyncPhotoUploadRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true; // device.match middleware + auth:api zaten korur.
    }

    public function rules(): array
    {
        return [
            // Client UUID — idempotency anahtari ve photo.id olur.
            'id' => ['required', 'uuid'],
            'medical_record_id' => ['required', 'uuid', 'exists:medical_records,id'],
            'animal_id' => ['required', 'uuid', 'exists:animals,id'],
            'taken_at' => ['required', 'date'],
            'caption' => ['nullable', 'string', 'max:2000'],
            // 10 MB MVP limiti; gerekirse config'e tasinir.
            'photo' => ['required', 'file', 'image', 'max:10240', 'mimes:jpg,jpeg,png,webp'],
        ];
    }
}
