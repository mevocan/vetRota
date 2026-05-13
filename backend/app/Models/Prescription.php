<?php

declare(strict_types=1);

namespace App\Models;

use App\Models\Concerns\BelongsToClinic;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;

// M7.4: Recete. Muayeneden uretilir; ilac listesi MR uzerinden okunur
// (medical_record_drugs). Sync disi — server tarafinda olusturulur.
class Prescription extends Model
{
    use BelongsToClinic;
    use HasUuids;
    use SoftDeletes;

    protected $fillable = [
        'clinic_id',
        'medical_record_id',
        'farmer_id',
        'animal_id',
        'vet_id',
        'prescription_number',
        'notes',
        'portal_token_id',
        'sms_sent_at',
    ];

    protected function casts(): array
    {
        return [
            'sms_sent_at' => 'datetime',
        ];
    }

    public function medicalRecord(): BelongsTo
    {
        return $this->belongsTo(MedicalRecord::class);
    }

    public function farmer(): BelongsTo
    {
        return $this->belongsTo(Farmer::class);
    }

    public function animal(): BelongsTo
    {
        return $this->belongsTo(Animal::class);
    }

    public function vet(): BelongsTo
    {
        return $this->belongsTo(User::class, 'vet_id');
    }

    public function portalToken(): BelongsTo
    {
        return $this->belongsTo(FarmerPortalToken::class, 'portal_token_id');
    }
}
