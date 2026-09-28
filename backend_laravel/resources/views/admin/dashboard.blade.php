@extends('layouts.admin')
@section('title','Dashboard · FitWithSaju Admin')
@section('heading','Dashboard')
@section('subheading','Manage exercise and nutrition content from one focused workspace.')
@section('page_actions')
<a class="btn btn-light" href="{{ route('admin.exercises.create') }}"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 5v14M5 12h14"/></svg>Exercise</a>
<a class="btn btn-primary" href="{{ route('admin.recipes.create') }}"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 5v14M5 12h14"/></svg>New recipe</a>
@endsection
@section('content')
@php
$totalContent = max(1, $exerciseCount + $recipeCount + $templateCount);
$exercisePct = ($exerciseCount / $totalContent) * 100;
$recipePct = ($recipeCount / $totalContent) * 100;
$otherPct = max(0, 100 - $exercisePct - $recipePct);
$exerciseEnd = number_format($exercisePct, 2, '.', '').'%';
$recipeEnd = number_format($exercisePct + $recipePct, 2, '.', '').'%';
$exercisePublishPct = $exerciseCount ? round(($activeExerciseCount / $exerciseCount) * 100) : 0;
$recipePublishPct = $recipeCount ? round(($publishedRecipeCount / $recipeCount) * 100) : 0;
$recipeReviewPct = $recipeCount ? round(($reviewedRecipeCount / $recipeCount) * 100) : 0;
$exerciseMediaPct = $exerciseCount ? round(($mediaCount / $exerciseCount) * 100) : 0;
@endphp
<div class="grid">
    <div class="card pad metric card-hover">
        <div class="metric-top"><div><strong>{{ $activeExerciseCount }}</strong><div class="metric-label">Visible exercises</div></div><div class="metric-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M6 8v8M18 8v8M3.5 10v4M20.5 10v4M8.5 12h7"/><rect x="4.5" y="6" width="3" height="12" rx="1"/><rect x="16.5" y="6" width="3" height="12" rx="1"/></svg></div></div>
        <div class="metric-note"><span class="metric-trend">{{ $exercisePublishPct }}%</span> of exercise catalog is visible</div>
    </div>
    <div class="card pad metric card-hover">
        <div class="metric-top"><div><strong>{{ $publishedRecipeCount }}</strong><div class="metric-label">Published recipes</div></div><div class="metric-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M5 3h10l4 4v14H5z"/><path d="M15 3v5h5M8 12h8M8 16h6"/></svg></div></div>
        <div class="metric-note"><span class="metric-trend">{{ $recipePublishPct }}%</span> of recipes are published</div>
    </div>
    <div class="card pad metric card-hover">
        <div class="metric-top"><div><strong>{{ $ingredientCount }}</strong><div class="metric-label">Ingredients</div></div><div class="metric-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M20 4c-8 0-14 4-14 10 0 3 2 5 5 5 6 0 9-7 9-15Z"/><path d="M4 20c3-6 7-9 13-12"/></svg></div></div>
        <div class="metric-note"><span class="metric-trend neutral">Reusable</span> nutrition building blocks</div>
    </div>
    <div class="card pad metric card-hover">
        <div class="metric-top"><div><strong>{{ $exerciseCount }}</strong><div class="metric-label">Total exercises</div></div><div class="metric-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><circle cx="12" cy="12" r="8"/><path d="M8 12h8M12 8v8"/></svg></div></div>
        <div class="metric-note"><span class="metric-trend">{{ $exerciseMediaPct }}%</span> have demonstration media</div>
    </div>
    <div class="card pad metric card-hover">
        <div class="metric-top"><div><strong>{{ $recipeCount }}</strong><div class="metric-label">Total recipes</div></div><div class="metric-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M4 10h16l-1 8a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2l-1-8Z"/><path d="M7 10a5 5 0 0 1 10 0M12 5V3"/></svg></div></div>
        <div class="metric-note"><span class="metric-trend">{{ $recipeReviewPct }}%</span> nutrition reviewed</div>
    </div>
    <div class="card pad metric card-hover">
        <div class="metric-top"><div><strong>{{ $templateCount }}</strong><div class="metric-label">Meal plan templates</div></div><div class="metric-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><rect x="4" y="5" width="16" height="15" rx="2"/><path d="M8 3v4M16 3v4M4 10h16"/></svg></div></div>
        <div class="metric-note"><span class="metric-trend">{{ $publishedTemplateCount }}</span> currently published</div>
    </div>
</div>

<div style="height:16px"></div>
<div class="grid-2">
    <section class="card pad">
        <div class="panel-head"><div><div class="panel-title">Content health</div><div class="panel-sub">Publishing, review and media readiness from current records</div></div><span class="badge on">Live data</span></div>
        <div class="health-list">
            <div class="health-row"><span class="health-label">Exercise visibility</span><span class="health-value">{{ $activeExerciseCount }}/{{ $exerciseCount }}</span><div class="progress"><span style="width:{{ $exercisePublishPct }}%"></span></div></div>
            <div class="health-row"><span class="health-label">Exercise media coverage</span><span class="health-value">{{ $mediaCount }}/{{ $exerciseCount }}</span><div class="progress"><span style="width:{{ $exerciseMediaPct }}%"></span></div></div>
            <div class="health-row"><span class="health-label">Recipe publishing</span><span class="health-value">{{ $publishedRecipeCount }}/{{ $recipeCount }}</span><div class="progress"><span style="width:{{ $recipePublishPct }}%"></span></div></div>
            <div class="health-row"><span class="health-label">Nutrition review coverage</span><span class="health-value">{{ $reviewedRecipeCount }}/{{ $recipeCount }}</span><div class="progress"><span style="width:{{ $recipeReviewPct }}%"></span></div></div>
        </div>
    </section>
    <section class="card pad">
        <div class="panel-head"><div><div class="panel-title">Content distribution</div><div class="panel-sub">Breakdown of managed content types</div></div></div>
        <div class="donut-row">
            <div class="donut" style="--exercise-end:{{ $exerciseEnd }};--recipe-end:{{ $recipeEnd }}"><div class="donut-center"><div><strong>{{ $exerciseCount + $recipeCount + $templateCount }}</strong><span>Total content</span></div></div></div>
            <div class="legend">
                <div class="legend-item"><span class="dot green"></span><span>Exercises</span><strong>{{ $exerciseCount }}</strong></div>
                <div class="legend-item"><span class="dot blue"></span><span>Recipes</span><strong>{{ $recipeCount }}</strong></div>
                <div class="legend-item"><span class="dot gray"></span><span>Meal plans</span><strong>{{ $templateCount }}</strong></div>
            </div>
        </div>
    </section>
</div>

<div style="height:16px"></div>
<section class="card table-card">
    <div class="pad" style="padding-bottom:8px"><div class="panel-head"><div><div class="panel-title">Recently updated recipes</div><div class="panel-sub">Latest nutrition content changes</div></div><a class="btn btn-primary btn-sm" href="{{ route('admin.recipes.create') }}"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 5v14M5 12h14"/></svg>New recipe</a></div></div>
    <div class="table-wrap"><table class="table"><thead><tr><th>Recipe</th><th>Meal</th><th>Review</th><th>Status</th><th>Last updated</th><th>Actions</th></tr></thead><tbody>
    @forelse($recentRecipes as $recipe)
        <tr>
            <td><div class="entity">@if($recipe->image_path)<img class="preview" src="{{ asset('storage/'.$recipe->image_path) }}" alt="">@else<div class="preview" style="display:grid;place-items:center;font-size:22px">{{ $recipe->artwork ?: '🍽️' }}</div>@endif<div><div class="entity-title">{{ $recipe->name }}</div><div class="entity-meta">{{ $recipe->source_id }} · {{ $recipe->cuisine }}</div></div></div></td>
            <td><span class="chip">{{ $recipe->slot }}</span></td>
            <td><span class="badge {{ $recipe->review_status === 'reviewed' ? 'on' : ($recipe->review_status === 'needs_review' ? 'warn' : 'neutral') }}">{{ str_replace('_',' ',$recipe->review_status) }}</span></td>
            <td><span class="badge {{ $recipe->status==='published'?'on':($recipe->status==='draft'?'neutral':'off') }}">{{ ucfirst($recipe->status) }}</span></td>
            <td class="muted" style="font-size:11px">{{ $recipe->updated_at?->format('M j, Y g:i A') }}</td>
            <td><div class="actions"><a class="btn btn-light btn-sm" href="{{ route('admin.recipes.edit',$recipe) }}">Edit</a></div></td>
        </tr>
    @empty<tr><td colspan="6" class="table-empty">No recipes yet. Create your first recipe to populate this dashboard.</td></tr>@endforelse
    </tbody></table></div>
</section>
@endsection
