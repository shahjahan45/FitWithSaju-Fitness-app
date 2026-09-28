@extends('layouts.admin')
@section('title','Edit Meal Template · FitWithSaju Admin')
@section('heading','Edit meal plan template')
@section('subheading',$template->name)
@section('content')<form class="card form-card" method="POST" action="{{ route('admin.meal-templates.update',$template) }}">@csrf @method('PUT') @include('admin.meal-templates._form')</form><div style="height:14px"></div><div class="card pad danger-card"><strong>Danger zone</strong><p class="muted">Deleting removes this template from the administration workspace and public content API.</p><form method="POST" action="{{ route('admin.meal-templates.destroy',$template) }}" onsubmit="return confirm('Delete this template?')">@csrf @method('DELETE')<button class="btn btn-danger">Delete template</button></form></div>@endsection
