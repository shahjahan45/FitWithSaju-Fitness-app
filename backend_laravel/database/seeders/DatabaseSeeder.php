<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $this->call([
            FitWithSajuAdminSeeder::class,
            ExerciseSeeder::class,
            RecipeSeeder::class,
            MealPlanTemplateSeeder::class,
        ]);
    }
}
