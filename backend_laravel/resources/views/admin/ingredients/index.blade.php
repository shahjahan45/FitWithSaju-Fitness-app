@extends('layouts.admin')
@section('title','Ingredients · FitWithSaju Admin')
@section('heading','Ingredients')
@section('subheading','Manage reusable ingredient names, categories and default measurement units.')
@section('page_actions')<a class="btn btn-primary" href="{{ route('admin.ingredients.create') }}"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 5v14M5 12h14"/></svg>New ingredient</a>@endsection
@section('content')
<div class="toolbar-card"><div class="toolbar"><form class="filter-form" method="GET"><div class="filter-grow"><input class="input" name="search" value="{{ request('search') }}" placeholder="Search ingredient"></div><select class="select" style="max-width:190px" name="category"><option value="">All categories</option>@foreach($categories as $category)<option value="{{ $category }}" @selected(request('category')===$category)>{{ $category }}</option>@endforeach</select><button class="btn btn-light" type="submit">Filter</button>@if(request()->hasAny(['search','category']))<a class="btn btn-light" href="{{ route('admin.ingredients.index') }}">Reset</a>@endif</form></div></div>
<div class="card table-card"><div class="table-wrap"><table class="table"><thead><tr><th>Name</th><th>Category</th><th>Default unit</th><th>Recipes</th><th>Status</th><th>Actions</th></tr></thead><tbody>
@forelse($ingredients as $ingredient)<tr><td><div class="entity-title">{{ $ingredient->name }}</div></td><td><span class="chip">{{ $ingredient->category }}</span></td><td>{{ $ingredient->default_unit ?: '—' }}</td><td>{{ $ingredient->recipes_count }}</td><td><span class="badge {{ $ingredient->is_active ? 'on':'off' }}">{{ $ingredient->is_active ? 'Active':'Hidden' }}</span></td><td><a class="btn btn-light btn-sm" href="{{ route('admin.ingredients.edit',$ingredient) }}">Edit</a></td></tr>@empty<tr><td colspan="6" class="table-empty">No ingredients found.</td></tr>@endforelse
</tbody></table></div></div>
@include('components.admin-pagination',['paginator'=>$ingredients])
@endsection
