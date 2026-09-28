<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Facades\Storage;

class RecipeResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->source_id,
            'name' => $this->name,
            'slug' => $this->slug,
            'slot' => $this->slot,
            'artwork' => $this->artwork,
            'image_url' => $this->image_path ? url(Storage::disk('public')->url($this->image_path)) : null,
            'cuisine' => $this->cuisine,
            'prep_minutes' => $this->prep_minutes,
            'yield_servings' => $this->yield_servings,
            'serving_label' => $this->serving_label,
            'nutrition' => [
                'calories' => $this->calories,
                'protein' => $this->protein,
                'carbs' => $this->carbs,
                'fat' => $this->fat,
            ],
            'dietary_tags' => $this->dietary_tags ?? [],
            'allergens' => $this->allergens ?? [],
            'ingredients' => $this->ingredients->map(fn ($ingredient) => [
                'name' => $ingredient->name,
                'quantity' => (float) $ingredient->pivot->quantity,
                'unit' => $ingredient->pivot->unit ?: $ingredient->default_unit,
                'category' => $ingredient->category,
            ])->values(),
            'instructions' => $this->instructions ?? [],
            'nutrition_provenance' => $this->nutrition_provenance,
            'review_status' => $this->review_status,
            'updated_at' => $this->updated_at?->toISOString(),
        ];
    }
}
