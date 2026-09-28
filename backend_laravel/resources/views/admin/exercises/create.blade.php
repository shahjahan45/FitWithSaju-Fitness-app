@extends('layouts.admin')
@section('title','New Exercise · FitWithSaju Admin')
@section('heading','New exercise')
@section('subheading','Add a movement to the public mobile exercise catalog.')
@section('content')
<form class="card pad" method="POST" action="{{ route('admin.exercises.store') }}" enctype="multipart/form-data">@csrf @include('admin.exercises._form')</form>
@endsection
