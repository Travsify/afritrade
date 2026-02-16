<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\CmsBanner;
use App\Models\CmsFaq;
use Illuminate\Http\Request;

class CmsController extends Controller
{
    public function index()
    {
        $banners = CmsBanner::latest()->get();
        $faqs = CmsFaq::orderBy('ordering')->get();
        return view('admin.cms.index', compact('banners', 'faqs'));
    }

    public function storeBanner(Request $request)
    {
        $request->validate([
            'image_url' => 'required|url',
            'title' => 'nullable|string|max:100',
        ]);

        CmsBanner::create($request->all());
        return back()->with('success', 'Banner added successfully.');
    }

    public function deleteBanner(CmsBanner $banner)
    {
        $banner->delete();
        return back()->with('success', 'Banner deleted successfully.');
    }

    public function storeFaq(Request $request)
    {
        $request->validate([
            'question' => 'required',
            'answer' => 'required',
        ]);

        CmsFaq::create($request->all());
        return back()->with('success', 'FAQ added successfully.');
    }

    public function deleteFaq(CmsFaq $faq)
    {
        $faq->delete();
        return back()->with('success', 'FAQ deleted successfully.');
    }
}
