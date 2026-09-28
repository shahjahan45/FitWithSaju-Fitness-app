@extends('layouts.admin')
@section('title','Recipes · FitWithSaju Admin')
@section('heading','Recipes')
@section('subheading','Manage meal content, nutrition estimates, allergens, ingredients and publication status.')
@section('page_actions')<a class="btn btn-primary" href="{{ route('admin.recipes.create') }}"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 5v14M5 12h14"/></svg>New recipe</a>@endsection
@section('content')
<div class="toolbar-card"><div class="toolbar"><form class="filter-form" method="GET">
<div class="filter-grow"><input class="input" name="search" value="{{ request('search') }}" placeholder="Search recipe, ID or cuisine"></div>
<select class="select" style="max-width:145px" name="slot"><option value="">All meals</option>@foreach(['Breakfast','Lunch','Dinner','Snack'] as $slot)<option value="{{ $slot }}" @selected(request('slot')===$slot)>{{ $slot }}</option>@endforeach</select>
<select class="select" style="max-width:145px" name="status"><option value="">All statuses</option>@foreach(['draft','published','inactive'] as $status)<option value="{{ $status }}" @selected(request('status')===$status)>{{ ucfirst($status) }}</option>@endforeach</select>
<select class="select" style="max-width:165px" name="review"><option value="">All reviews</option>@foreach(['unreviewed','reviewed','needs_review'] as $review)<option value="{{ $review }}" @selected(request('review')===$review)>{{ str_replace('_',' ',ucfirst($review)) }}</option>@endforeach</select>
<button class="btn btn-light" type="submit"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 5h16M7 12h10M10 19h4"/></svg>Filter</button>
@if(request()->hasAny(['search','slot','status','review']))<a class="btn btn-light" href="{{ route('admin.recipes.index') }}">Reset</a>@endif
</form></div></div>
<div class="card table-card"><div class="table-wrap"><table class="table"><thead><tr><th>Recipe</th><th>Meal</th><th>Nutrition / serving</th><th>Review</th><th>Status</th><th>Actions</th></tr></thead><tbody>
@forelse($recipes as $recipe)
<tr>
<td><div class="entity">@if($recipe->image_path)<img class="preview" src="{{ asset('storage/'.$recipe->image_path) }}" alt="{{ $recipe->name }}">@else<div class="preview" style="display:grid;place-items:center;font-size:23px">{{ $recipe->artwork ?: '🍽️' }}</div>@endif<div><div class="entity-title">{{ $recipe->name }}</div><div class="entity-meta">{{ $recipe->source_id }} · {{ $recipe->cuisine }}</div></div></div></td>
<td><span class="chip">{{ $recipe->slot }}</span></td>
<td><div class="entity-title">{{ round($recipe->calories) }} kcal</div><div class="entity-meta">P {{ round($recipe->protein) }}g · C {{ round($recipe->carbs) }}g · F {{ round($recipe->fat) }}g</div></td>
<td><span class="badge {{ $recipe->review_status === 'reviewed' ? 'on':($recipe->review_status === 'needs_review' ? 'warn':'neutral') }}">{{ str_replace('_',' ',$recipe->review_status) }}</span></td>
<td><span class="badge {{ $recipe->status === 'published' ? 'on':($recipe->status === 'draft' ? 'neutral':'off') }}">{{ ucfirst($recipe->status) }}</span></td>
<td><div class="actions"><a class="btn btn-light btn-sm" href="{{ route('admin.recipes.edit',$recipe) }}">Edit</a><form method="POST" action="{{ route('admin.recipes.publish',$recipe) }}">@csrf @method('PATCH')<button class="btn btn-soft btn-sm">{{ $recipe->status === 'published' ? 'Unpublish':'Publish' }}</button></form></div></td>
</tr>
@empty<tr><td colspan="6" class="table-empty">No matching recipes found.</td></tr>@endforelse
</tbody></table></div></div>
@include('components.admin-pagination',['paginator'=>$recipes])
@endsection
