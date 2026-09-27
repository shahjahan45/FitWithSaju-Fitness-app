<?php

use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\ExerciseController as AdminExerciseController;
use App\Http\Controllers\Auth\AdminAuthController;
use Illuminate\Support\Facades\Route;

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
    Route::patch('/exercises/{exercise}/toggle', [AdminExerciseController::class, 'toggle'])->name('exercises.toggle');
    Route::resource('exercises', AdminExerciseController::class)->except('show');
});
