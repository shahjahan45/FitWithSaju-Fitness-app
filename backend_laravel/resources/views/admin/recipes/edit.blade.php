@extends('layouts.admin')
@section('title','Edit Recipe · FitWithSaju Admin')
@section('heading','Edit recipe')
@section('subheading',$recipe->name.' · '.$recipe->source_id)
@section('content')
<form class="card pad" method="POST" action="{{ route('admin.recipes.update',$recipe) }}" enctype="multipart/form-data">@csrf @method('PUT') @include('admin.recipes._form')</form>
<div style="height:14px"></div><div class="card pad"><strong>Danger zone</strong><p class="muted">Deleting soft-deletes this recipe and removes it from the public API. Historical mobile food logs keep their nutrition snapshot.</p><form method="POST" action="{{ route('admin.recipes.destroy',$recipe) }}" onsubmit="return confirm('Delete this recipe?')">@csrf @method('DELETE')<button class="btn btn-danger">Delete recipe</button></form></div>
@endsection
