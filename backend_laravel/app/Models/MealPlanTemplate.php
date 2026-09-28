<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class MealPlanTemplate extends Model
{
    use SoftDeletes;

    protected $fillable = ['name', 'slug', 'description', 'goal', 'days', 'status', 'sort_order'];

    protected function casts(): array
    {
        return ['days' => 'array', 'sort_order' => 'integer'];
    }

    public function scopePublished(Builder $query): Builder
    {
        return $query->where('status', 'published');
    }
}
