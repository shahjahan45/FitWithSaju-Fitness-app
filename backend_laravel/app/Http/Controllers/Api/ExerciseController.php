<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\ExerciseResource;
use App\Models\Exercise;
use Illuminate\Http\Request;

class ExerciseController extends Controller
{
    public function index(Request $request)
    {
        $query = Exercise::query()->active();

        if ($request->filled('search')) {
            $search = trim((string) $request->input('search'));
            $query->where(function ($builder) use ($search) {
                $builder->where('name', 'like', "%{$search}%")
                    ->orWhereJsonContains('target_muscles', $search)
                    ->orWhereJsonContains('secondary_muscles', $search)
                    ->orWhereJsonContains('body_parts', $search)
                    ->orWhereJsonContains('equipments', $search);
            });
        }

        foreach ([
            'body_part' => 'body_parts',
            'equipment' => 'equipments',
            'muscle' => 'target_muscles',
        ] as $parameter => $column) {
            if ($request->filled($parameter)) {
                $query->whereJsonContains($column, (string) $request->input($parameter));
            }
        }

        $perPage = min(max((int) $request->integer('per_page', 60), 1), 200);
        $items = $query
            ->orderBy('sort_order')
            ->orderBy('name')
            ->paginate($perPage)
            ->withQueryString();

        return ExerciseResource::collection($items);
    }

    public function show(string $exercise)
    {
        $item = Exercise::query()
            ->active()
            ->where(function ($query) use ($exercise) {
                $query->where('source_id', $exercise)->orWhere('slug', $exercise);
            })
            ->firstOrFail();

        return new ExerciseResource($item);
    }
}
