<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreDrugRequest;
use App\Http\Requests\UpdateDrugRequest;
use App\Models\Drug;
use App\Models\Stock;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DrugController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = Drug::query()->with('stock:id,drug_id,current_quantity,critical_threshold,earliest_expiry_at,last_purchased_at');

        if ($search = $request->string('search')->trim()->value()) {
            $query->where(function ($q) use ($search): void {
                $q->where('name', 'ilike', "%{$search}%")
                  ->orWhere('active_ingredient', 'ilike', "%{$search}%")
                  ->orWhere('manufacturer', 'ilike', "%{$search}%")
                  ->orWhere('barcode', 'ilike', "%{$search}%");
            });
        }

        if ($type = $request->string('drug_type')->value()) {
            $query->where('drug_type', $type);
        }

        if ($request->boolean('is_vaccine')) {
            $query->where('is_vaccine', true);
        }

        if ($request->boolean('low_stock_only')) {
            // current_quantity <= critical_threshold (NULL'lar haric)
            $query->whereHas('stock', function ($q): void {
                $q->whereNotNull('critical_threshold')
                  ->whereColumn('current_quantity', '<=', 'critical_threshold');
            });
        }

        $perPage = min((int) $request->integer('per_page', 50), 200);

        return response()->json($query->orderBy('name')->paginate($perPage));
    }

    public function show(Drug $drug): JsonResponse
    {
        $drug->load([
            'stock',
            'movements' => fn ($q) => $q->latest('occurred_at')->limit(50),
            'movements.performedBy:id,name',
        ]);

        return response()->json(['data' => $drug]);
    }

    public function store(StoreDrugRequest $request): JsonResponse
    {
        $data = $request->validated();
        $criticalThreshold = $data['critical_threshold'] ?? null;
        unset($data['critical_threshold']);

        $drug = Drug::create($data);

        // Her ilac icin baslangic stok kaydi (current_quantity=0).
        Stock::create([
            'drug_id' => $drug->id,
            'current_quantity' => 0,
            'critical_threshold' => $criticalThreshold,
        ]);

        $drug->load('stock');

        return response()->json(['data' => $drug], 201);
    }

    public function update(UpdateDrugRequest $request, Drug $drug): JsonResponse
    {
        $data = $request->validated();
        $criticalThreshold = $data['critical_threshold'] ?? null;
        $hasThreshold = array_key_exists('critical_threshold', $data);
        unset($data['critical_threshold']);

        $drug->update($data);

        if ($hasThreshold && $drug->stock) {
            $drug->stock->update(['critical_threshold' => $criticalThreshold]);
        }

        $drug->load('stock');

        return response()->json(['data' => $drug]);
    }

    public function destroy(Drug $drug): JsonResponse
    {
        $drug->delete();
        $drug->stock?->delete();

        return response()->json(null, 204);
    }
}
