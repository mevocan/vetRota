<?php

namespace App\Models;

use Database\Factories\UserFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\Hidden;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use PHPOpenSourceSaver\JWTAuth\Contracts\JWTSubject;

#[Fillable(['name', 'email', 'password', 'clinic_id', 'device_id', 'role'])]
#[Hidden(['password', 'remember_token'])]
class User extends Authenticatable implements JWTSubject
{
    /** @use HasFactory<UserFactory> */
    use HasFactory, Notifiable;

    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

    public function clinic(): BelongsTo
    {
        return $this->belongsTo(Clinic::class);
    }

    public function getJWTIdentifier(): mixed
    {
        return $this->getKey();
    }

    /**
     * M3.2: device_id login akisinda set edilir; JWT icinde tasinir.
     * sync-api.md §3 uyari: middleware X-Device-Id header'i ile karsilastirir.
     */
    public function getJWTCustomClaims(): array
    {
        return [
            'clinic_id' => $this->clinic_id,
            'device_id' => $this->device_id,
            'role' => $this->role,
        ];
    }
}
