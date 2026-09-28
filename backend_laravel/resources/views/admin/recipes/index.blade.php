@extends('layouts.admin')
@section('title','Recipes · FitWithSaju Admin')
@section('heading','Recipes')
@section('subheading','Manage published meal content, nutrition estimates, allergens, ingredients, and review status.')
@section('content')
<div class="toolbar">
<form style="display:flex;gap:10px;flex:1;flex-wrap:wrap" method="GET">
<input class="input" style="max-width:280px" name="search" value="{{ request('search') }}" placeholder="Search recipe, ID, cuisine">
<select class="select" style="max-width:150px" name="slot"><option value="">All meals</option>@foreach(['Breakfast','Lunch','Dinner','Snack'] as $slot)<option value="{{ $slot }}" @selected(request('slot')===$slot)>{{ $slot }}</option>@endforeach</select>
<select class="select" style="max-width:150px" name="status"><option value="">All statuses</option>@foreach(['draft','published','inactive'] as $status)<option value="{{ $status }}" @selected(request('status')===$status)>{{ ucfirst($status) }}</option>@endforeach</select>
<select class="select" style="max-width:165px" name="review"><option value="">All reviews</option>@foreach(['unreviewed','reviewed','needs_review'] as $review)<option value="{{ $review }}" @selected(request('review')===$review)>{{ str_replace('_',' ',ucfirst($review)) }}</option>@endforeach</select>
<button class="btn btn-light">Filter</button></form>
<a class="btn btn-primary" href="{{ route('admin.recipes.create') }}">+ New recipe</a>
</div>
<div class="card table-wrap"><table class="table"><thead><tr><th>Recipe</th><th>Meal</th><th>Nutrition / serving</th><th>Review</th><th>Status</th><th>Actions</th></tr></thead><tbody>
@forelse($recipes as $recipe)
<tr><td><div style="display:flex;align-items:center;gap:10px">@if($recipe->image_path)<img class="preview" src="{{ asset('storage/'.$recipe->image_path) }}" alt="">@else<div class="preview" style="display:grid;place-items:center;font-size:28px">{{ $recipe->artwork ?: '🍽️' }}</div>@endif<div><strong>{{ $recipe->name }}</strong><div class="muted" style="font-size:12px;margin-top:3px">{{ $recipe->source_id }} · {{ $recipe->cuisine }}</div></div></div></td>
<td>{{ $recipe->slot }}</td><td>{{ round($recipe->calories) }} kcal · P {{ round($recipe->protein) }}g · C {{ round($recipe->carbs) }}g · F {{ round($recipe->fat) }}g</td>
<td><span class="badge {{ $recipe->review_status === 'reviewed' ? 'on':'off' }}">{{ str_replace('_',' ',$recipe->review_status) }}</span></td>
<td><span class="badge {{ $recipe->status === 'published' ? 'on':'off' }}">{{ ucfirst($recipe->status) }}</span></td>
<td><div class="actions"><a class="btn btn-light" href="{{ route('admin.recipes.edit',$recipe) }}">Edit</a><form method="POST" action="{{ route('admin.recipes.publish',$recipe) }}">@csrf @method('PATCH')<button class="btn btn-soft">{{ $recipe->status === 'published' ? 'Unpublish':'Publish' }}</button></form></div></td></tr>
@empty<tr><td colspan="6" class="muted">No matching recipes.</td></tr>@endforelse
</tbody></table></div><div style="margin-top:16px">{{ $recipes->links() }}</div>
@endsection
