@extends('layouts.admin')
@section('title','Exercises · FitWithSaju Admin')
@section('heading','Exercises')
@section('subheading','Search, edit, activate, and manage exercise demonstration media.')
@section('content')
<div class="toolbar">
<form style="display:flex;gap:10px;flex:1;flex-wrap:wrap" method="GET">
<input class="input" style="max-width:340px" name="search" value="{{ request('search') }}" placeholder="Search name or exercise ID">
<select class="select" style="max-width:180px" name="status"><option value="">All statuses</option><option value="active" @selected(request('status')==='active')>Active</option><option value="hidden" @selected(request('status')==='hidden')>Hidden</option></select>
<button class="btn btn-light">Filter</button></form>
<a class="btn btn-primary" href="{{ route('admin.exercises.create') }}">+ New exercise</a>
</div>
<div class="card table-wrap"><table class="table"><thead><tr><th>Exercise</th><th>Muscles</th><th>Equipment</th><th>Status</th><th>Actions</th></tr></thead><tbody>
@forelse($exercises as $exercise)
<tr>
<td><div style="display:flex;align-items:center;gap:10px">@if($exercise->thumbnail_path)<img class="preview" src="{{ asset('storage/'.$exercise->thumbnail_path) }}" alt="">@else<div class="preview" style="display:grid;place-items:center;color:#86c613;font-weight:900">FS</div>@endif<div><strong>{{ $exercise->name }}</strong><div class="muted" style="font-size:12px;margin-top:3px">{{ $exercise->source_id }}</div></div></div></td>
<td>{{ implode(', ', $exercise->target_muscles ?? []) }}</td><td>{{ implode(', ', $exercise->equipments ?? []) }}</td><td><span class="badge {{ $exercise->is_active ? 'on':'off' }}">{{ $exercise->is_active ? 'Active':'Hidden' }}</span></td>
<td><div class="actions"><a class="btn btn-light" href="{{ route('admin.exercises.edit',$exercise) }}">Edit</a><form method="POST" action="{{ route('admin.exercises.toggle',$exercise) }}">@csrf @method('PATCH')<button class="btn btn-soft">{{ $exercise->is_active ? 'Hide':'Activate' }}</button></form></div></td>
</tr>
@empty<tr><td colspan="5" class="muted">No matching exercises.</td></tr>@endforelse
</tbody></table></div>
<div style="margin-top:16px">{{ $exercises->links() }}</div>
@endsection
