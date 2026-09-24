<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Exercise extends Model
{
    protected $fillable = [
        'name',
        'slug',
        'description',
        'primary_muscle',
        'equipment',
        'difficulty',
        'instructions',
        'sets',
        'reps',
        'rest_seconds',
        'media_url',
        'thumbnail_url',
        'is_active',
    ];

    protected $casts = [
        'is_active' => 'boolean',
    ];
}
