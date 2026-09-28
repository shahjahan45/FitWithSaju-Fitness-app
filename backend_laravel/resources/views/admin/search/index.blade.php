@extends('layouts.admin')
@section('title','Search · FitWithSaju Admin')
@section('heading','Search')
@section('subheading',$query !== '' ? 'Results across exercises, recipes, ingredients and meal plans.' : 'Search all managed content from one place.')
@section('content')
@if($query === '')
<div class="card pad" style="max-width:720px"><div class="panel-title">Search content</div><div class="panel-sub" style="margin-bottom:14px">Try an exercise name, recipe ID, cuisine, ingredient, goal or template.</div><form method="GET" action="{{ route('admin.search') }}" class="toolbar"><input class="input" style="flex:1;min-width:240px" name="q" autofocus placeholder="e.g. squat, salmon, protein"><button class="btn btn-primary">Search</button></form></div>
@else
@php $total = $exercises->count()+$recipes->count()+$ingredients->count()+$templates->count(); @endphp
<div class="toolbar-card"><div class="toolbar"><form method="GET" action="{{ route('admin.search') }}" class="filter-form"><div class="filter-grow"><input class="input" name="q" value="{{ $query }}" autofocus></div><button class="btn btn-primary">Search</button></form><span class="badge neutral">{{ $total }} matches</span></div></div>
<div class="search-results">
    <section class="result-group"><div class="group-head"><h2>Exercises</h2><span class="badge neutral">{{ $exercises->count() }}</span></div><div class="result-list">@forelse($exercises as $item)<a class="result-item" href="{{ route('admin.exercises.edit',$item) }}"><div><strong>{{ $item->name }}</strong><span>{{ $item->source_id }} · {{ implode(', ',array_slice($item->target_muscles ?? [],0,2)) }}</span></div><span>›</span></a>@empty<div class="muted" style="font-size:12px">No exercise matches.</div>@endforelse</div></section>
    <section class="result-group"><div class="group-head"><h2>Recipes</h2><span class="badge neutral">{{ $recipes->count() }}</span></div><div class="result-list">@forelse($recipes as $item)<a class="result-item" href="{{ route('admin.recipes.edit',$item) }}"><div><strong>{{ $item->name }}</strong><span>{{ $item->source_id }} · {{ $item->slot }} · {{ $item->cuisine }}</span></div><span>›</span></a>@empty<div class="muted" style="font-size:12px">No recipe matches.</div>@endforelse</div></section>
    <section class="result-group"><div class="group-head"><h2>Ingredients</h2><span class="badge neutral">{{ $ingredients->count() }}</span></div><div class="result-list">@forelse($ingredients as $item)<a class="result-item" href="{{ route('admin.ingredients.edit',$item) }}"><div><strong>{{ $item->name }}</strong><span>{{ $item->category }} · {{ $item->default_unit ?: 'No default unit' }}</span></div><span>›</span></a>@empty<div class="muted" style="font-size:12px">No ingredient matches.</div>@endforelse</div></section>
    <section class="result-group"><div class="group-head"><h2>Meal plans</h2><span class="badge neutral">{{ $templates->count() }}</span></div><div class="result-list">@forelse($templates as $item)<a class="result-item" href="{{ route('admin.meal-templates.edit',$item) }}"><div><strong>{{ $item->name }}</strong><span>{{ $item->goal }} · {{ $item->status }}</span></div><span>›</span></a>@empty<div class="muted" style="font-size:12px">No meal plan matches.</div>@endforelse</div></section>
</div>
@endif
@endsection
