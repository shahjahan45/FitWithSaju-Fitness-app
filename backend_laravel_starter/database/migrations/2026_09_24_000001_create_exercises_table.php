<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('exercises', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('slug')->unique();
            $table->text('description')->nullable();
            $table->string('primary_muscle');
            $table->string('equipment')->nullable();
            $table->string('difficulty')->default('Beginner');
            $table->text('instructions')->nullable();
            $table->unsignedTinyInteger('sets')->default(3);
            $table->string('reps')->default('10-12');
            $table->unsignedSmallInteger('rest_seconds')->default(60);
            $table->string('media_url')->nullable();
            $table->string('thumbnail_url')->nullable();
            $table->boolean('is_active')->default(true)->index();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('exercises');
    }
};
