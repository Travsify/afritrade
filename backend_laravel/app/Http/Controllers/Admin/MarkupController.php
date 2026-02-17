<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class MarkupController extends Controller
{
    public function index()
    {
        $markups = DB::table('service_markups')->get();
        return view('admin.pricing.index', compact('markups'));
    }

    public function update(Request $request, $id)
    {
        $request->validate([
            'fee_type' => 'required|in:fixed,percentage,both',
            'fixed_fee' => 'required|numeric|min:0',
            'percentage_fee' => 'required|numeric|min:0',
            'is_active' => 'required|boolean',
        ]);

        DB::table('service_markups')->where('id', $id)->update([
            'fee_type' => $request->fee_type,
            'fixed_fee' => $request->fixed_fee,
            'percentage_fee' => $request->percentage_fee,
            'is_active' => $request->is_active,
            'updated_at' => now(),
        ]);

        return back()->with('success', 'Markup updated successfully.');
    }
}
