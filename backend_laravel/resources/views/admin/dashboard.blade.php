@extends('layouts.admin')
@section('title','Dashboard · FitWithSaju Admin')
@section('heading','Dashboard')
@section('subheading','Manage FitWithSaju exercise and nutrition content from one place.')
@section('content')
<div class="grid">
    <div class="card pad metric"><strong>{{ $activeExerciseCount }}</strong><span>Visible exercises</span></div>
    <div class="card pad metric"><strong>{{ $publishedRecipeCount }}</strong><span>Published recipes</span></div>
    <div class="card pad metric"><strong>{{ $ingredientCount }}</strong><span>Ingredients</span></div>
</div>
<div style="height:16px"></div>
<div class="grid">
    <div class="card pad metric"><strong>{{ $exerciseCount }}</strong><span>Total exercises</span></div>
    <div class="card pad metric"><strong>{{ $recipeCount }}</strong><span>Total recipes</span></div>
    <div class="card pad metric"><strong>{{ $templateCount }}</strong><span>Meal plan templates</span></div>
</div>
<div style="height:18px"></div>
<div class="card pad"><div style="display:flex;justify-content:space-between;align-items:center;gap:12px;margin-bottom:10px"><div><strong style="font-size:18px">Recently updated recipes</strong><div class="muted" style="margin-top:4px">Latest nutrition content changes</div></div><a class="btn btn-primary" href="{{ route('admin.recipes.create') }}">+ New recipe</a></div><div class="table-wrap"><table class="table"><thead><tr><th>Name</th><th>Meal</th><th>Review</th><th>Status</th></tr></thead><tbody>@forelse($recentRecipes as $recipe)<tr><td><a href="{{ route('admin.recipes.edit',$recipe) }}"><strong>{{ $recipe->name }}</strong></a></td><td>{{ $recipe->slot }}</td><td>{{ str_replace('_',' ',$recipe->review_status) }}</td><td><span class="badge {{ $recipe->status==='published'?'on':'off' }}">{{ ucfirst($recipe->status) }}</span></td></tr>@empty<tr><td colspan="4" class="muted">No recipes yet.</td></tr>@endforelse</tbody></table></div></div>
@endsection
