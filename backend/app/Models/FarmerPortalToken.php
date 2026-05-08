<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class FarmerPortalToken extends Model
{
    use HasUuids;

    protected $fillable = [
        'id', 'farmer_id', 'clinic_id', 'token_hash', 'token_prefix',
        'scope', 'resource_type', 'resource_id', 'expires_at',
        'revoked_at', 'first_accessed_at', 'last_accessed_at',
        'access_count', 'last_ip_hash', 'last_user_agent',
    ];

    protected $casts = [
        'expires_at' => 'datetime',
        'revoked_at' => 'datetime',
        'first_accessed_at' => 'datetime',
        'last_accessed_at' => 'datetime',
        'access_count' => 'integer',
    ];

    protected $hidden = ['token_hash'];

    public function farmer(): BelongsTo
    {
        return $this->belongsTo(Farmer::class);
    }

    public function clinic(): BelongsTo
    {
        return $this->belongsTo(Clinic::class);
    }

    public function isActive(): bool
    {
        return $this->revoked_at === null && $this->expires_at->isFuture();
    }
}
