<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class MealPlanTemplateResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->slug,
            'name' => $this->name,
            'description' => $this->description,
            'goal' => $this->goal,
            'days' => $this->days ?? [],
            'updated_at' => $this->updated_at?->toISOString(),
        ];
    }
}
