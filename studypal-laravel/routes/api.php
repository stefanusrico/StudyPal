<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Firebase\UserController;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

Route::post('/users', [UserController::class, 'store']);
Route::get('/check-firebase-config', [UserController::class, 'checkFirebaseConfig']);