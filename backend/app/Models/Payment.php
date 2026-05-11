<?php

declare(strict_types=1);

namespace App\Models;

use App\Models\Concerns\BelongsToClinic;
use App\Models\Concerns\HasSyncColumns;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;

// M7.3: Ciftci odemesi (alacak/iade). Ledger — silinmez, ters
// hareket olarak duzeltilir. farmers.balance PaymentObserver ile
// guncellenir.
class Payment extends Model
{
    use BelongsToClinic;
    use HasSyncColumns;
    use HasUuids;
    use SoftDeletes;

    protected $fillable = [
        'clinic_id',
        'farmer_id',
        'vet_id',
        'amount',
        'method',
        'paid_at',
        'notes',
    ];

    protected function casts(): array
    {
        return [
            'amount' => 'decimal:2',
            'paid_at' => 'datetime',
        ];
    }

    public function farmer(): BelongsTo
    {
        return $this->belongsTo(Farmer::class);
    }

    public function vet(): BelongsTo
    {
        return $this->belongsTo(User::class, 'vet_id');
    }
}
