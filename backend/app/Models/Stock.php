<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class Stock extends Model
{
    use HasFactory;
    use HasUuids;
    use SoftDeletes;

    protected $fillable = [
        'drug_id',
        'current_quantity',
        'critical_threshold',
        'reorder_quantity',
        'last_purchased_at',
        'earliest_expiry_at',
    ];

    protected function casts(): array
    {
        return [
            'current_quantity' => 'decimal:3',
            'critical_threshold' => 'decimal:3',
            'reorder_quantity' => 'decimal:3',
            'last_purchased_at' => 'datetime',
            'earliest_expiry_at' => 'date',
        ];
    }

    public function drug(): BelongsTo
    {
        return $this->belongsTo(Drug::class);
    }

    public function movements(): HasMany
    {
        return $this->hasMany(StockMovement::class);
    }

    public function isCritical(): bool
    {
        if ($this->critical_threshold === null) {
            return false;
        }

        return (float) $this->current_quantity <= (float) $this->critical_threshold;
    }
}
