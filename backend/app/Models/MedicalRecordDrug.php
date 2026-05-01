<?php

declare(strict_types=1);

namespace App\Models;

use App\Models\Concerns\HasSyncColumns;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;

class MedicalRecordDrug extends Model
{
    use HasSyncColumns;
    use HasUuids;
    use SoftDeletes;

    protected $fillable = [
        'clinic_id',
        'medical_record_id',
        'drug_id',
        'quantity',
        'unit',
        'route',
        'frequency',
        'unit_price',
        'batch_number',
        'notes',
    ];

    protected function casts(): array
    {
        return [
            'quantity' => 'decimal:3',
            'unit_price' => 'decimal:2',
        ];
    }

    public function medicalRecord(): BelongsTo
    {
        return $this->belongsTo(MedicalRecord::class);
    }

    public function drug(): BelongsTo
    {
        return $this->belongsTo(Drug::class);
    }

    public function clinic(): BelongsTo
    {
        return $this->belongsTo(Clinic::class);
    }
}
