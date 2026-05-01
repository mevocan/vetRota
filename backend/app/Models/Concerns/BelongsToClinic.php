<?php

declare(strict_types=1);

namespace App\Models\Concerns;

// Tenant tablolarinda clinic_id otomatik doldurmasi icin trait.
// Auth bagli ise auth()->user()->clinic_id kullanilir; degilse hicbir
// sey yapilmaz (seeder/test'lerde explicit set edilir).
//
// Global tenant scope M3.2'de eklenecek (auth + middleware ile birlikte).
trait BelongsToClinic
{
    public static function bootBelongsToClinic(): void
    {
        static::creating(function ($model): void {
            if ($model->clinic_id !== null) {
                return;
            }
            $user = auth()->user();
            if ($user && isset($user->clinic_id)) {
                $model->clinic_id = $user->clinic_id;
            }
        });
    }

    public function clinic()
    {
        return $this->belongsTo(\App\Models\Clinic::class);
    }
}
