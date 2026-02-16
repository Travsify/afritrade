<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\KycDocument;
use Illuminate\Http\Request;

class KycController extends Controller
{
    public function index()
    {
        $documents = KycDocument::with('user')->where('status', 'pending')->latest()->paginate(10);
        return view('admin.kyc.index', compact('documents'));
    }

    public function show(KycDocument $kyc)
    {
        return view('admin.kyc.show', compact('kyc'));
    }

    public function update(Request $request, KycDocument $kyc)
    {
        $request->validate([
            'status' => 'required|in:approved,rejected',
            'rejection_reason' => 'required_if:status,rejected',
        ]);

        $kyc->update([
            'status' => $request->status,
            'rejection_reason' => $request->rejection_reason,
        ]);

        if ($request->status === 'approved' && $kyc->user) {
            // Added is_kyc_verified migration in previous step
            $kyc->user->forceFill(['is_kyc_verified' => true])->save();
        } elseif ($request->status === 'rejected' && $kyc->user) {
             $kyc->user->forceFill(['is_kyc_verified' => false])->save();
        }

        return redirect()->route('admin.kyc.index')->with('success', 'KYC status updated successfully.');
    }
}
