@extends('layouts.admin')
@section('title','New Meal Template · FitWithSaju Admin')
@section('heading','New meal plan template')
@section('subheading','Build a reusable weekly plan from published recipe IDs.')
@section('content')<form class="card pad" method="POST" action="{{ route('admin.meal-templates.store') }}">@csrf @include('admin.meal-templates._form')</form>@endsection
