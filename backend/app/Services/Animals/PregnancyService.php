<?php

declare(strict_types=1);

namespace App\Services\Animals;

use App\Models\Animal;
use Carbon\Carbon;

// M7.1: Tur bazli gebelik suresi gunu. expected_birth_date hesabi
// burada tek yerde — controller/observer'lar buradan cagirir.
class PregnancyService
{
    // Yaklasik ortalama gebelik suresi (gun).
    private const GESTATION_DAYS = [
        'cattle' => 283,
        'sheep' => 150,
        'goat' => 150,
        'horse' => 340,
    ];

    public function gestationDaysFor(string $species): int
    {
        return self::GESTATION_DAYS[$species] ?? 283;
    }

    public function calculateBirthDate(string $species, Carbon $startedAt): Carbon
    {
        return $startedAt->copy()->addDays($this->gestationDaysFor($species));
    }

    public function markPregnant(
        Animal $animal,
        ?Carbon $startedAt = null,
        ?string $notes = null,
    ): Animal {
        $start = $startedAt ?? Carbon::today();
        $animal->forceFill([
            'is_pregnant' => true,
            'pregnancy_started_at' => $start->toDateString(),
            'expected_birth_date' => $this->calculateBirthDate($animal->species, $start)->toDateString(),
            'pregnancy_notes' => $notes,
        ])->save();
        return $animal;
    }

    public function markNotPregnant(Animal $animal): Animal
    {
        $animal->forceFill([
            'is_pregnant' => false,
            'pregnancy_started_at' => null,
            'expected_birth_date' => null,
            'pregnancy_notes' => null,
        ])->save();
        return $animal;
    }
}
