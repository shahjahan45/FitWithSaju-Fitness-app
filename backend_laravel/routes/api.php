<?php

use App\Http\Controllers\Api\ExerciseController;
use App\Http\Controllers\Api\MealPlanTemplateController;
use App\Http\Controllers\Api\RecipeController;
use App\Http\Controllers\Api\WorkoutController;
use Illuminate\Support\Facades\Route;

Route::get('/exercises', [ExerciseController::class, 'index']);
Route::get('/exercises/{exercise}', [ExerciseController::class, 'show']);

Route::get('/recipes', [RecipeController::class, 'index']);
Route::get('/recipes/{recipe}', [RecipeController::class, 'show']);
Route::get('/meal-plan-templates', [MealPlanTemplateController::class, 'index']);
Route::get('/meal-plan-templates/{template}', [MealPlanTemplateController::class, 'show']);

Route::get('/workouts', [WorkoutController::class, 'index']);
Route::get('/workouts/{workout:slug}', [WorkoutController::class, 'show']);
