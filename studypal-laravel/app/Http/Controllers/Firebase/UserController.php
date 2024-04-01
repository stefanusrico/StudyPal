<?php

namespace App\Http\Controllers\Firebase;

use App\Http\Controllers\Controller;
use Kreait\Firebase\Contract\Database;
use Kreait\Firebase\Factory;
use Illuminate\Http\Request;

class UserController extends Controller
{
    public function __construct(Database $database)
    {
        $this->database = $database;
        $this->tablename = 'user';
    }

    public function store(Request $request)
    {
        try {
            $request->validate([
                'first_name' => 'required|string',
                'last_name' => 'required|string',
                'email' => 'required|email',
            ]);

            $postData = [
                'fname' => $request->input('first_name'),
                'lname' => $request->input('last_name'),
                'email' => $request->input('email'),
            ];
            
            $newPost = $this->database->getReference($this->tablename)->push($postData);

            return response()->json(['success' => true, 'message' => 'Data added to Firebase']);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()]);
        }
    }
}