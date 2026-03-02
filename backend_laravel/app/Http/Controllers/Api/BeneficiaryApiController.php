<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;

class BeneficiaryApiController extends Controller
{
    public function index()
    {
        $beneficiaries = DB::table('beneficiaries')
            ->where('user_id', Auth::id())
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'status' => 'success',
            'data' => $beneficiaries,
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'bank_name' => 'required|string|max:255',
            'account_number' => 'required|string|max:20',
            'currency' => 'nullable|string|max:5',
        ]);

        $id = DB::table('beneficiaries')->insertGetId([
            'user_id' => Auth::id(),
            'name' => $request->name,
            'bank_name' => $request->bank_name,
            'account_number' => $request->account_number,
            'currency' => $request->currency ?? 'NGN',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $beneficiary = DB::table('beneficiaries')->find($id);

        return response()->json([
            'status' => 'success',
            'message' => 'Beneficiary saved.',
            'data' => $beneficiary,
        ]);
    }

    public function destroy($id)
    {
        DB::table('beneficiaries')
            ->where('id', $id)
            ->where('user_id', Auth::id())
            ->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'Beneficiary removed.',
        ]);
    }
}
