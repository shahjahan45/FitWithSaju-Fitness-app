@extends('layouts.admin')
@section('title','Dashboard · FitWithSaju Admin')
@section('heading','Dashboard')
@section('subheading','Manage the FitWithSaju public exercise catalog.')
@section('content')
<div class="grid">
    <div class="card pad metric"><strong>{{ $exerciseCount }}</strong><span>Total exercises</span></div>
    <div class="card pad metric"><strong>{{ $activeExerciseCount }}</strong><span>Visible in app</span></div>
    <div class="card pad metric"><strong>{{ $mediaCount }}</strong><span>With demonstration media</span></div>
</div>
<div style="height:18px"></div>
<div class="card pad">
    <div style="display:flex;justify-content:space-between;align-items:center;gap:12px;margin-bottom:10px"><div><strong style="font-size:18px">Recently updated</strong><div class="muted" style="margin-top:4px">Latest exercise content changes</div></div><a class="btn btn-primary" href="{{ route('admin.exercises.create') }}">+ New exercise</a></div>
    <div class="table-wrap"><table class="table"><thead><tr><th>Name</th><th>ID</th><th>Status</th><th>Updated</th></tr></thead><tbody>
    @forelse($recentExercises as $exercise)<tr><td><a href="{{ route('admin.exercises.edit',$exercise) }}"><strong>{{ $exercise->name }}</strong></a></td><td>{{ $exercise->source_id }}</td><td><span class="badge {{ $exercise->is_active ? 'on':'off' }}">{{ $exercise->is_active ? 'Active':'Hidden' }}</span></td><td>{{ $exercise->updated_at?->diffForHumans() }}</td></tr>@empty<tr><td colspan="4" class="muted">No exercises yet.</td></tr>@endforelse
    </tbody></table></div>
</div>
@endsection
