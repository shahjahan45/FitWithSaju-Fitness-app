<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Exercise;

class DashboardController extends Controller
{
    public function __invoke()
    {
        return view('admin.dashboard', [
            'exerciseCount' => Exercise::count(),
            'activeExerciseCount' => Exercise::active()->count(),
            'mediaCount' => Exercise::whereNotNull('media_path')->count(),
            'recentExercises' => Exercise::latest('updated_at')->limit(6)->get(),
        ]);
    }
}
