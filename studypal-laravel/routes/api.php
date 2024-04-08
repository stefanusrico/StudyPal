<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Firebase\AuthController;
use App\Http\Controllers\Firebase\UserController;

Route::post('/register', [AuthController::class, 'registrasi']);
Route::post('/login', [AuthController::class, 'login']);
Route::post('/check-token', [AuthController::class, 'checkToken']);
Route::post('/signout', [AuthController::class, 'logout']);

Route::middleware('auth:sanctum')->group(function () {
    Route::get("/test", function () {
        return "test berhasil";
    });
    // Route::post('/logout', [AuthController::class, 'logout']);
    Route::post('/refresh', [AuthController::class, 'refresh']);
});

Route::get('/check-firebase-config', [UserController::class, 'checkFirebaseConfig']);