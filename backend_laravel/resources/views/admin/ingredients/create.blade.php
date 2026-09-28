@extends('layouts.admin')
@section('title','New Ingredient · FitWithSaju Admin')
@section('heading','New ingredient')
@section('subheading','Create a reusable ingredient for meal recipes.')
@section('content')<form class="card form-card" method="POST" action="{{ route('admin.ingredients.store') }}">@csrf @include('admin.ingredients._form')</form>@endsection
