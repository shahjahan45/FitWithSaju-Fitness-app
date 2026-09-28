@extends('layouts.admin')
@section('title','Edit Exercise · FitWithSaju Admin')
@section('heading','Edit exercise')
@section('subheading',$exercise->name.' · '.$exercise->source_id)
@section('content')
<form class="card pad" method="POST" action="{{ route('admin.exercises.update',$exercise) }}" enctype="multipart/form-data">@csrf @method('PUT') @include('admin.exercises._form')</form>
<div style="height:14px"></div><div class="card pad"><strong>Danger zone</strong><p class="muted">Deleting moves the exercise to Laravel soft-delete trash and removes it from the public API.</p><form method="POST" action="{{ route('admin.exercises.destroy',$exercise) }}" onsubmit="return confirm('Delete this exercise?')">@csrf @method('DELETE')<button class="btn btn-danger">Delete exercise</button></form></div>
@endsection
