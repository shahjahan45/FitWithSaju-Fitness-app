<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class PublicCatalogTest extends TestCase
{
    use RefreshDatabase;

    public function test_public_catalog_routes_are_available(): void
    {
        $this->getJson('/api/exercises')->assertOk();
        $this->getJson('/api/recipes')->assertOk();
        $this->getJson('/api/meal-plan-templates')->assertOk();
    }
}
