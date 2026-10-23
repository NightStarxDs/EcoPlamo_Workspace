<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

Route::get('/dlh', function () {
    $path = public_path('dlh/index.html');
    if (file_exists($path)) {
        return response()->file($path, ['Content-Type' => 'text/html']);
    }
    abort(404, 'Web Portal DLH belum tersedia.');
});
