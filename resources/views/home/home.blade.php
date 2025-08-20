@extends('../layouts.frontend')
@section('title','Home')
@section('content')
<div class="container">
    <div class="row">
        <div class="card">
            <div class="card-header">
                <h1>Hola mundo desde Laravel 11 con Docker y docker-compose sin Sail</h1>
            </div>
            <div class="card-body">
               
<h2>Laravel {{ App::VERSION() }}</h2>
<h2>PHP {{ phpversion() }}</h2>
<h2>Docker 27.2.0</h2>
<h2>Docker compose 3.8</h2>
<h2>Python 3.12</h2>
<h2>Integración directa con Supervisor desde el contenedor (Para Qeues y Reverb)</h2>
<h3>Todo preparado para implementar un CD/CI bajo algún servidor de integración continua como Jenkins por ejemplo</h3>
            </div>
        </div>
    </div>
</div>
@endsection

 