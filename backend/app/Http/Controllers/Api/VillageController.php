<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Village;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class VillageController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = Village::query();

        if ($search = $request->string('search')->trim()->value()) {
            $query->where('name', 'ilike', "%{$search}%");
        }

        $perPage = min((int) $request->integer('per_page', 100), 500);

        return response()->json($query->orderBy('name')->paginate($perPage));
    }
}
