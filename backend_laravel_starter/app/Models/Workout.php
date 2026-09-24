<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Workout extends Model
{
    protected $fillable = [
        'title',
        'slug',
        'description',
        'difficulty',
        'duration_minutes',
        'is_active',
    ];

    protected $casts = [
        'is_active' => 'boolean',
    ];

    public function exercises()
    {
        return $this->belongsToMany(Exercise::class)
            ->withPivot(['position', 'sets', 'reps', 'rest_seconds'])
            ->orderBy('workout_exercises.position');
    }
}
