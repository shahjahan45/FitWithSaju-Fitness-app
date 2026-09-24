<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Exercise;
use Illuminate\Http\Request;

class ExerciseController extends Controller
{
    public function index(Request $request)
    {
        $query = Exercise::query()->where('is_active', true);

        if ($request->filled('search')) {
            $search = $request->string('search');
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                  ->orWhere('primary_muscle', 'like', "%{$search}%");
            });
        }

        return response()->json(
            $query->orderBy('name')->paginate(24)
        );
    }

    public function show(Exercise $exercise)
    {
        abort_unless($exercise->is_active, 404);
        return response()->json($exercise);
    }
}
