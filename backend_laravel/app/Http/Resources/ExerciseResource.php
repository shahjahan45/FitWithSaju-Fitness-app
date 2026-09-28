<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Facades\Storage;

class ExerciseResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->source_id,
            'name' => $this->name,
            'description' => $this->description,
            'target_muscles' => $this->target_muscles ?? [],
            'body_parts' => $this->body_parts ?? [],
            'equipments' => $this->equipments ?? [],
            'secondary_muscles' => $this->secondary_muscles ?? [],
            'instructions' => $this->instructions ?? [],
            'sets' => $this->sets,
            'reps' => $this->reps,
            'rest_seconds' => $this->rest_seconds,
            'thumbnail_url' => $this->publicUrl($this->thumbnail_path),
            'media_url' => $this->publicUrl($this->media_path),
            'updated_at' => $this->updated_at?->toISOString(),
        ];
    }

    private function publicUrl(?string $path): ?string
    {
        if (! $path) {
            return null;
        }

        return url(Storage::disk('public')->url($path));
    }
}
