@extends('layouts.admin')
@section('title','New Recipe · FitWithSaju Admin')
@section('heading','New recipe')
@section('subheading','Add a meal with nutrition, ingredients, allergens, and preparation instructions.')
@section('content')
<form class="card form-card" method="POST" action="{{ route('admin.recipes.store') }}" enctype="multipart/form-data">@csrf @include('admin.recipes._form')</form>
@endsection
