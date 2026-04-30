<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class StockMovement extends Model
{
    use HasFactory;
    use HasUuids;

    // Ledger - asla silinmez. SoftDeletes yok.

    protected $fillable = [
        'stock_id',
        'drug_id',
        'movement_type',
        'quantity',
        'unit_price',
        'batch_number',
        'expiry_date',
        'supplier_name',
        'related_medical_record_id',
        'related_movement_id',
        'performed_by',
        'notes',
        'occurred_at',
    ];

    protected function casts(): array
    {
        return [
            'quantity' => 'decimal:3',
            'unit_price' => 'decimal:2',
            'expiry_date' => 'date',
            'occurred_at' => 'datetime',
        ];
    }

    public function stock(): BelongsTo
    {
        return $this->belongsTo(Stock::class);
    }

    public function drug(): BelongsTo
    {
        return $this->belongsTo(Drug::class);
    }

    public function performedBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'performed_by');
    }

    public function medicalRecord(): BelongsTo
    {
        return $this->belongsTo(MedicalRecord::class, 'related_medical_record_id');
    }
}
