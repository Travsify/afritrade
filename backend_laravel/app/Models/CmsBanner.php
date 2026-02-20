<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class CmsBanner extends Model
{
    protected $fillable = [
        'title',
        'image_url',
        'link_url',
        'is_active',
    ];
}
