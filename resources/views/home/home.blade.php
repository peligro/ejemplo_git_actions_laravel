@extends('../layouts.frontend')
@section('title','Home')
@section('content')
<div class="container">
    <div class="row">
        <div class="card">
            <div class="card-header bg-primary text-white">
                <h1>Hola mundo desde Laravel 12 con Docker y docker-compose desplegado con Pipeline CI/CD mediante GIT Actions</h1>
            </div>
            <div class="card-body">
               
<h2>Laravel {{ App::VERSION() }}</h2>
<h2>PHP {{ phpversion() }}</h2>
<h2>Docker 27.2.0</h2>
<h2>Docker compose 3.8</h2>
<h2>Pipeline CI/CD mediante GIT Actions</h2>
            </div>
        </div>
    </div>
</div>
@endsection

 