<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreFarmerRequest;
use App\Http\Requests\UpdateFarmerRequest;
use App\Models\Farmer;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class FarmerController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = Farmer::query()
            ->with('village:id,name,district,city')
            ->withCount('animals');

        if ($search = $request->string('search')->trim()->value()) {
            $query->where(function ($q) use ($search): void {
                $q->where('first_name', 'ilike', "%{$search}%")
                  ->orWhere('last_name', 'ilike', "%{$search}%")
                  ->orWhere('phone', 'ilike', "%{$search}%");
            });
        }

        if ($villageId = $request->string('village_id')->value()) {
            $query->where('village_id', $villageId);
        }

        $perPage = min((int) $request->integer('per_page', 50), 200);

        return response()->json($query->orderBy('first_name')->paginate($perPage));
    }

    public function show(Farmer $farmer): JsonResponse
    {
        $farmer->load([
            'village',
            'animals' => fn ($q) => $q->latest()->limit(50),
        ]);
        $farmer->loadCount('animals');

        return response()->json(['data' => $farmer]);
    }

    public function store(StoreFarmerRequest $request): JsonResponse
    {
        $farmer = Farmer::create($request->validated());
        $farmer->load('village:id,name,district,city');

        return response()->json(['data' => $farmer], 201);
    }

    public function update(UpdateFarmerRequest $request, Farmer $farmer): JsonResponse
    {
        $farmer->update($request->validated());
        $farmer->load('village:id,name,district,city');

        return response()->json(['data' => $farmer]);
    }

    public function destroy(Farmer $farmer): JsonResponse
    {
        $farmer->delete();

        return response()->json(null, 204);
    }
}
