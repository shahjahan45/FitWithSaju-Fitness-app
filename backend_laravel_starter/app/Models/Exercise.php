<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Exercise extends Model
{
    use SoftDeletes;

    protected $fillable = [
        'source_id',
        'name',
        'slug',
        'description',
        'target_muscles',
        'body_parts',
        'equipments',
        'secondary_muscles',
        'instructions',
        'sets',
        'reps',
        'rest_seconds',
        'media_path',
        'thumbnail_path',
        'sort_order',
        'is_active',
    ];

    protected function casts(): array
    {
        return [
            'target_muscles' => 'array',
            'body_parts' => 'array',
            'equipments' => 'array',
            'secondary_muscles' => 'array',
            'instructions' => 'array',
            'sets' => 'integer',
            'rest_seconds' => 'integer',
            'sort_order' => 'integer',
            'is_active' => 'boolean',
        ];
    }

    public function scopeActive(Builder $query): Builder
    {
        return $query->where('is_active', true);
    }
}
