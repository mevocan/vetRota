<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class Clinic extends Model
{
    use HasUuids;
    use SoftDeletes;

    public const TIER_FREE = 'free';
    public const TIER_PREMIUM = 'premium';

    protected $fillable = [
        'name',
        'phone',
        'email',
        'city',
        'district',
        'settings',
        'subscription_tier',
        'subscription_expires_at',
    ];

    protected function casts(): array
    {
        return [
            'settings' => 'array',
            'subscription_expires_at' => 'datetime',
        ];
    }

    // M10.1: Premium aktif mi? tier=premium VE expires_at ya null ya gelecekte.
    public function isPremium(): bool
    {
        if ($this->subscription_tier !== self::TIER_PREMIUM) {
            return false;
        }

        return $this->subscription_expires_at === null
            || $this->subscription_expires_at->isFuture();
    }

    public function users(): HasMany
    {
        return $this->hasMany(User::class);
    }

    public function farmers(): HasMany
    {
        return $this->hasMany(Farmer::class);
    }

    public function animals(): HasMany
    {
        return $this->hasMany(Animal::class);
    }
}
