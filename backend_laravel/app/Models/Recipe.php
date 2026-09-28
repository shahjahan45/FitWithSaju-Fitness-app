<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class Recipe extends Model
{
    use SoftDeletes;

    protected $fillable = [
        'source_id', 'name', 'slug', 'slot', 'cuisine', 'prep_minutes',
        'yield_servings', 'serving_label', 'calories', 'protein', 'carbs', 'fat',
        'artwork', 'image_path', 'dietary_tags', 'allergens', 'instructions',
        'nutrition_provenance', 'review_status', 'reviewed_by', 'reviewed_at',
        'status', 'sort_order',
    ];

    protected function casts(): array
    {
        return [
            'prep_minutes' => 'integer',
            'yield_servings' => 'integer',
            'calories' => 'float',
            'protein' => 'float',
            'carbs' => 'float',
            'fat' => 'float',
            'dietary_tags' => 'array',
            'allergens' => 'array',
            'instructions' => 'array',
            'reviewed_at' => 'datetime',
            'sort_order' => 'integer',
        ];
    }

    public function ingredients(): BelongsToMany
    {
        return $this->belongsToMany(Ingredient::class, 'recipe_ingredients')
            ->withPivot(['quantity', 'unit', 'sort_order'])
            ->withTimestamps()
            ->orderByPivot('sort_order');
    }

    public function scopePublished(Builder $query): Builder
    {
        return $query->where('status', 'published');
    }
}
