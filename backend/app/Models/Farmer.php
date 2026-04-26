<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class Farmer extends Model
{
    use HasFactory;
    use HasUuids;
    use SoftDeletes;

    protected $fillable = [
        'village_id',
        'first_name',
        'last_name',
        'phone',
        'email',
        'address_detail',
        'balance',
        'sms_notifications_enabled',
        'preferred_sms_language',
        'notes',
    ];

    protected function casts(): array
    {
        return [
            'balance' => 'decimal:2',
            'sms_notifications_enabled' => 'boolean',
        ];
    }

    public function village(): BelongsTo
    {
        return $this->belongsTo(Village::class);
    }

    public function animals(): HasMany
    {
        return $this->hasMany(Animal::class);
    }
}
