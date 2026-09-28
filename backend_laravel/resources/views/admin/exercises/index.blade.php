@extends('layouts.admin')
@section('title','Exercises · FitWithSaju Admin')
@section('heading','Exercises')
@section('subheading','Search, edit, publish and manage demonstration media for the mobile exercise catalog.')
@section('page_actions')<a class="btn btn-primary" href="{{ route('admin.exercises.create') }}"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 5v14M5 12h14"/></svg>New exercise</a>@endsection
@section('content')
<div class="toolbar-card"><div class="toolbar">
<form class="filter-form" method="GET">
<div class="filter-grow"><input class="input" name="search" value="{{ request('search') }}" placeholder="Search name or exercise ID"></div>
<select class="select" style="max-width:180px" name="status"><option value="">All statuses</option><option value="active" @selected(request('status')==='active')>Active</option><option value="hidden" @selected(request('status')==='hidden')>Hidden</option></select>
<button class="btn btn-light" type="submit"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 5h16M7 12h10M10 19h4"/></svg>Filter</button>
@if(request()->hasAny(['search','status']))<a class="btn btn-light" href="{{ route('admin.exercises.index') }}">Reset</a>@endif
</form>
</div></div>
<div class="card table-card"><div class="table-wrap"><table class="table"><thead><tr><th>Exercise</th><th>Muscles</th><th>Equipment</th><th>Status</th><th>Actions</th></tr></thead><tbody>
@forelse($exercises as $exercise)
<tr>
<td><div class="entity">@if($exercise->thumbnail_path)<img class="preview" src="{{ asset('storage/'.$exercise->thumbnail_path) }}" alt="{{ $exercise->name }}">@else<div class="preview" style="display:grid;place-items:center;color:#70b800;font-weight:900">FS</div>@endif<div><div class="entity-title">{{ $exercise->name }}</div><div class="entity-meta">{{ $exercise->source_id }}</div></div></div></td>
<td>@forelse(array_slice($exercise->target_muscles ?? [],0,2) as $muscle)<span class="chip">{{ $muscle }}</span>@empty<span class="muted">—</span>@endforelse</td>
<td>@forelse(array_slice($exercise->equipments ?? [],0,2) as $equipment)<span class="chip">{{ $equipment }}</span>@empty<span class="muted">—</span>@endforelse</td>
<td><span class="badge {{ $exercise->is_active ? 'on':'off' }}">{{ $exercise->is_active ? 'Active':'Hidden' }}</span></td>
<td><div class="actions"><a class="btn btn-light btn-sm" href="{{ route('admin.exercises.edit',$exercise) }}">Edit</a><form method="POST" action="{{ route('admin.exercises.toggle',$exercise) }}">@csrf @method('PATCH')<button class="btn btn-soft btn-sm">{{ $exercise->is_active ? 'Hide':'Activate' }}</button></form></div></td>
</tr>
@empty<tr><td colspan="5" class="table-empty">No matching exercises found.</td></tr>@endforelse
</tbody></table></div></div>
@include('components.admin-pagination',['paginator'=>$exercises])
@endsection
