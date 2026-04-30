<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Database\Eloquent\SoftDeletes;

class Drug extends Model
{
    use HasFactory;
    use HasUuids;
    use SoftDeletes;

    protected $fillable = [
        'name',
        'active_ingredient',
        'manufacturer',
        'barcode',
        'drug_type',
        'requires_prescription',
        'unit',
        'package_size',
        'is_vaccine',
        'vaccine_duration_days',
        'suitable_species',
        'default_price',
    ];

    protected function casts(): array
    {
        return [
            'requires_prescription' => 'boolean',
            'is_vaccine' => 'boolean',
            'package_size' => 'decimal:2',
            'default_price' => 'decimal:2',
            'suitable_species' => 'array',
            'vaccine_duration_days' => 'integer',
        ];
    }

    public function stock(): HasOne
    {
        return $this->hasOne(Stock::class);
    }

    public function movements(): HasMany
    {
        return $this->hasMany(StockMovement::class);
    }
}
