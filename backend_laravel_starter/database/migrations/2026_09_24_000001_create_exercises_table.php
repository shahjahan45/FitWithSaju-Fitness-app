<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('exercises', function (Blueprint $table) {
            $table->id();
            $table->string('source_id')->unique();
            $table->string('name');
            $table->string('slug')->unique();
            $table->text('description')->nullable();
            $table->json('target_muscles')->nullable();
            $table->json('body_parts')->nullable();
            $table->json('equipments')->nullable();
            $table->json('secondary_muscles')->nullable();
            $table->json('instructions')->nullable();
            $table->unsignedTinyInteger('sets')->default(3);
            $table->string('reps')->default('10–12');
            $table->unsignedSmallInteger('rest_seconds')->default(60);
            $table->string('media_path')->nullable();
            $table->string('thumbnail_path')->nullable();
            $table->unsignedInteger('sort_order')->default(0)->index();
            $table->boolean('is_active')->default(true)->index();
            $table->timestamps();
            $table->softDeletes();

            $table->index('name');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('exercises');
    }
};
