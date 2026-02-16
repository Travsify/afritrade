<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\CmsBanner;
use Illuminate\Http\Request;

class GeneralApiController extends Controller
{
    public function banners()
    {
        $banners = CmsBanner::where('is_active', true) // Legacy used status='active', migration uses boolean is_active
            ->latest()
            ->get()
            ->map(function ($banner) {
                return [
                    'id' => $banner->id,
                    'image_url' => $banner->image_url, // Assuming full URL stored or handled
                    'action' => $banner->link_url ?? null
                ];
            });

        return response()->json([
            'status' => 'success', 
            'data' => $banners
        ]);
    }
}
