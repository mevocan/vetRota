<?php

declare(strict_types=1);

namespace App\Http\Requests\Sync;

use Illuminate\Foundation\Http\FormRequest;

// sync-api.md §4. FK siralamasi onemli; processor sirasi da ayni.
class SyncPushRequest extends FormRequest
{
    /** FK dependency order. */
    public const TABLES = [
        'villages',
        'farmers',
        'animals',
        'appointments',
        'medical_records',
        'medical_record_drugs',
        'drugs',
        'stocks',
        'stock_movements',
    ];

    public function authorize(): bool
    {
        return auth()->check();
    }

    public function rules(): array
    {
        $rules = [
            'client_sync_id' => ['required', 'string', 'min:8', 'max:64'],
            'device_id'      => ['required', 'uuid'],
            'client_time'    => ['required', 'date'],
            'batch'          => ['required', 'array'],
        ];

        foreach (self::TABLES as $table) {
            $rules["batch.{$table}"]                            = ['sometimes', 'array'];
            $rules["batch.{$table}.*.op"]                       = ['required', 'in:upsert,delete'];
            $rules["batch.{$table}.*.id"]                       = ['required', 'uuid'];
            $rules["batch.{$table}.*.expected_version"]         = ['required', 'integer', 'min:0'];
            $rules["batch.{$table}.*.client_last_modified_at"]  = ['sometimes', 'date'];
            $rules["batch.{$table}.*.data"]                     = ['sometimes', 'array'];
        }

        return $rules;
    }
}
