<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreAnimalRequest;
use App\Http\Requests\UpdateAnimalRequest;
use App\Models\Animal;
use App\Models\Clinic;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use PHPOpenSourceSaver\JWTAuth\Facades\JWTAuth;

class AnimalController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = Animal::query()->with(['farmer:id,first_name,last_name,phone', 'village:id,name,district,city']);

        if ($search = $request->string('search')->trim()->value()) {
            $query->where(function ($q) use ($search): void {
                $q->where('ear_tag', 'ilike', "%{$search}%")
                  ->orWhere('name', 'ilike', "%{$search}%");
            });
        }

        if ($species = $request->string('species')->value()) {
            $query->where('species', $species);
        }

        if ($villageId = $request->string('village_id')->value()) {
            $query->where('village_id', $villageId);
        }

        if ($farmerId = $request->string('farmer_id')->value()) {
            $query->where('farmer_id', $farmerId);
        }

        $perPage = min((int) $request->integer('per_page', 25), 100);
        $animals = $query->latest()->paginate($perPage);

        return response()->json($animals);
    }

    public function show(Animal $animal): JsonResponse
    {
        $animal->load(['farmer', 'village']);

        return response()->json(['data' => $animal]);
    }

    public function store(StoreAnimalRequest $request): JsonResponse
    {
        // M10.1: Free tier 100 hayvan limiti (proje.md §4.1 Ozellik 2).
        $clinicId = JWTAuth::parseToken()->getPayload()->get('clinic_id');
        $clinic = $clinicId ? Clinic::find($clinicId) : null;
        if ($clinic && ! $clinic->isPremium()) {
            $count = Animal::where('clinic_id', $clinicId)->count();
            if ($count >= 100) {
                return response()->json([
                    'error' => 'free_animal_limit',
                    'message' => 'Free pakette en fazla 100 hayvan kayıt edebilirsiniz. Premium\'a geçin.',
                    'limit' => 100,
                    'current' => $count,
                ], 402);
            }
        }

        $animal = Animal::create($request->validated());
        $animal->load(['farmer:id,first_name,last_name', 'village:id,name']);

        return response()->json(['data' => $animal], 201);
    }

    public function update(UpdateAnimalRequest $request, Animal $animal): JsonResponse
    {
        $animal->update($request->validated());
        $animal->load(['farmer:id,first_name,last_name', 'village:id,name']);

        return response()->json(['data' => $animal]);
    }

    public function destroy(Animal $animal): JsonResponse
    {
        $animal->delete();

        return response()->json(null, 204);
    }
}
