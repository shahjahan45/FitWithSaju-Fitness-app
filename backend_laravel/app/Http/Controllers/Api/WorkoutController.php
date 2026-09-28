<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Workout;

class WorkoutController extends Controller
{
    public function index()
    {
        return response()->json(
            Workout::query()
                ->where('is_active', true)
                ->orderBy('title')
                ->paginate(20)
        );
    }

    public function show(Workout $workout)
    {
        abort_unless($workout->is_active, 404);
        return response()->json($workout->load('exercises'));
    }
}
