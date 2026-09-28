<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('ingredients', function (Blueprint $table) {
            $table->id();
            $table->string('name')->unique();
            $table->string('slug')->unique();
            $table->string('category')->default('Other')->index();
            $table->string('default_unit', 30)->nullable();
            $table->boolean('is_active')->default(true)->index();
            $table->timestamps();
        });

        Schema::create('recipes', function (Blueprint $table) {
            $table->id();
            $table->string('source_id', 100)->unique();
            $table->string('name');
            $table->string('slug')->unique();
            $table->string('slot', 40)->index();
            $table->string('cuisine', 80)->default('International')->index();
            $table->unsignedSmallInteger('prep_minutes')->default(0);
            $table->unsignedSmallInteger('yield_servings')->default(1);
            $table->string('serving_label')->default('1 serving');
            $table->decimal('calories', 10, 2)->default(0);
            $table->decimal('protein', 10, 2)->default(0);
            $table->decimal('carbs', 10, 2)->default(0);
            $table->decimal('fat', 10, 2)->default(0);
            $table->string('artwork', 20)->nullable();
            $table->string('image_path')->nullable();
            $table->json('dietary_tags')->nullable();
            $table->json('allergens')->nullable();
            $table->json('instructions')->nullable();
            $table->string('nutrition_provenance')->nullable();
            $table->string('review_status', 30)->default('unreviewed')->index();
            $table->string('reviewed_by')->nullable();
            $table->timestamp('reviewed_at')->nullable();
            $table->string('status', 20)->default('draft')->index();
            $table->unsignedInteger('sort_order')->default(0)->index();
            $table->timestamps();
            $table->softDeletes();
            $table->index('name');
        });

        Schema::create('recipe_ingredients', function (Blueprint $table) {
            $table->id();
            $table->foreignId('recipe_id')->constrained()->cascadeOnDelete();
            $table->foreignId('ingredient_id')->constrained()->cascadeOnDelete();
            $table->decimal('quantity', 12, 3)->default(0);
            $table->string('unit', 30)->nullable();
            $table->unsignedInteger('sort_order')->default(0);
            $table->timestamps();
            $table->unique(['recipe_id', 'ingredient_id']);
        });

        Schema::create('meal_plan_templates', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('slug')->unique();
            $table->text('description')->nullable();
            $table->string('goal', 80)->default('Balanced eating')->index();
            $table->json('days');
            $table->string('status', 20)->default('draft')->index();
            $table->unsignedInteger('sort_order')->default(0)->index();
            $table->timestamps();
            $table->softDeletes();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('meal_plan_templates');
        Schema::dropIfExists('recipe_ingredients');
        Schema::dropIfExists('recipes');
        Schema::dropIfExists('ingredients');
    }
};
