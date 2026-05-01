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

    protected $fillable = [
        'name',
        'phone',
        'email',
        'city',
        'district',
        'settings',
    ];

    protected function casts(): array
    {
        return [
            'settings' => 'array',
        ];
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
