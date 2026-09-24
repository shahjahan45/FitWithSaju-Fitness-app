<?php

use App\Http\Controllers\Api\ExerciseController;
use App\Http\Controllers\Api\WorkoutController;
use Illuminate\Support\Facades\Route;

Route::get('/exercises', [ExerciseController::class, 'index']);
Route::get('/exercises/{exercise:slug}', [ExerciseController::class, 'show']);

Route::get('/workouts', [WorkoutController::class, 'index']);
Route::get('/workouts/{workout:slug}', [WorkoutController::class, 'show']);
