<?php

declare(strict_types=1);

namespace App\Models;

use App\Models\Concerns\HasSyncColumns;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;

class MedicalRecordPhoto extends Model
{
    use HasSyncColumns;
    use HasUuids;
    use SoftDeletes;

    protected $fillable = [
        'clinic_id',
        'medical_record_id',
        'animal_id',
        'storage_path',
        'original_filename',
        'mime_type',
        'size_bytes',
        'width',
        'height',
        'taken_at',
        'caption',
    ];

    protected function casts(): array
    {
        return [
            'taken_at' => 'datetime',
            'size_bytes' => 'integer',
            'width' => 'integer',
            'height' => 'integer',
        ];
    }

    public function medicalRecord(): BelongsTo
    {
        return $this->belongsTo(MedicalRecord::class);
    }

    public function animal(): BelongsTo
    {
        return $this->belongsTo(Animal::class);
    }

    public function clinic(): BelongsTo
    {
        return $this->belongsTo(Clinic::class);
    }
}
