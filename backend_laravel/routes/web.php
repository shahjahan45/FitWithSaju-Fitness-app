<?php

use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\ExerciseController as AdminExerciseController;
use App\Http\Controllers\Admin\IngredientController as AdminIngredientController;
use App\Http\Controllers\Admin\MealPlanTemplateController as AdminMealPlanTemplateController;
use App\Http\Controllers\Admin\RecipeController as AdminRecipeController;
use App\Http\Controllers\Admin\SearchController;
use App\Http\Controllers\Auth\AdminAuthController;
use Illuminate\Support\Facades\Route;

Route::get('/', fn () => redirect()->route('admin.login'));

Route::get('/login', fn () => redirect()->route('admin.login'))->name('login');

Route::middleware('guest')->group(function () {
    Route::get('/admin/login', [AdminAuthController::class, 'create'])->name('admin.login');
    Route::post('/admin/login', [AdminAuthController::class, 'store'])->name('admin.login.store');
});

Route::post('/admin/logout', [AdminAuthController::class, 'destroy'])
    ->middleware('auth')
    ->name('admin.logout');

Route::prefix('admin')->name('admin.')->middleware(['auth', 'admin'])->group(function () {
    Route::get('/', DashboardController::class)->name('dashboard');
    Route::get('/search', SearchController::class)->name('search');

    Route::patch('/exercises/{exercise}/toggle', [AdminExerciseController::class, 'toggle'])->name('exercises.toggle');
    Route::resource('exercises', AdminExerciseController::class)->except('show');

    Route::patch('/recipes/{recipe}/publish', [AdminRecipeController::class, 'publish'])->name('recipes.publish');
    Route::resource('recipes', AdminRecipeController::class)->except('show');
    Route::resource('ingredients', AdminIngredientController::class)->except('show');
    Route::resource('meal-templates', AdminMealPlanTemplateController::class)
        ->parameters(['meal-templates' => 'meal_template'])
        ->except('show');
});
