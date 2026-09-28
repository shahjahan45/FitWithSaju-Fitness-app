@extends('layouts.admin')
@section('title','Edit Ingredient · FitWithSaju Admin')
@section('heading','Edit ingredient')
@section('subheading',$ingredient->name)
@section('content')<form class="card form-card" method="POST" action="{{ route('admin.ingredients.update',$ingredient) }}">@csrf @method('PUT') @include('admin.ingredients._form')</form><div style="height:14px"></div><div class="card pad danger-card"><strong>Usage protection</strong><p class="muted">Ingredients used by recipes cannot be deleted until those recipe relationships are removed.</p><form method="POST" action="{{ route('admin.ingredients.destroy',$ingredient) }}" onsubmit="return confirm('Delete this ingredient?')">@csrf @method('DELETE')<button class="btn btn-danger">Delete ingredient</button></form></div>@endsection
