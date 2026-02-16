@extends('layouts.admin')

@section('header', 'Content Management')

@section('content')
    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        
        <!-- Banners Section -->
        <div class="bg-white rounded-lg shadow p-6">
            <h3 class="text-lg font-semibold text-gray-800 mb-4">Promotional Banners</h3>
            
            <form action="{{ route('admin.cms.banners.store') }}" method="POST" class="mb-6">
                @csrf
                <div class="mb-3">
                    <input type="url" name="image_url" placeholder="Image URL" required
                        class="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500">
                </div>
                <div class="mb-3">
                    <input type="text" name="title" placeholder="Banner Title (Optional)"
                        class="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500">
                </div>
                <button type="submit" class="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700">
                    Add Banner
                </button>
            </form>

            <div class="space-y-4">
                @foreach($banners as $banner)
                    <div class="flex items-center justify-between border p-3 rounded">
                        <div class="flex items-center space-x-3">
                            <img src="{{ $banner->image_url }}" alt="Banner" class="h-12 w-20 object-cover rounded">
                            <span class="text-sm font-medium">{{ $banner->title ?? 'No Title' }}</span>
                        </div>
                        <form action="{{ route('admin.cms.banners.delete', $banner) }}" method="POST">
                            @csrf @method('DELETE')
                            <button type="submit" class="text-red-600 hover:text-red-900 text-sm">Delete</button>
                        </form>
                    </div>
                @endforeach
            </div>
        </div>

        <!-- FAQs Section -->
        <div class="bg-white rounded-lg shadow p-6">
            <h3 class="text-lg font-semibold text-gray-800 mb-4">FAQs</h3>
            
            <form action="{{ route('admin.cms.faqs.store') }}" method="POST" class="mb-6">
                @csrf
                <div class="mb-3">
                    <input type="text" name="question" placeholder="Question" required
                        class="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500">
                </div>
                <div class="mb-3">
                    <textarea name="answer" placeholder="Answer" required rows="2"
                        class="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500"></textarea>
                </div>
                <button type="submit" class="bg-green-600 text-white px-4 py-2 rounded hover:bg-green-700">
                    Add FAQ
                </button>
            </form>

            <div class="space-y-4 max-h-96 overflow-y-auto">
                @foreach($faqs as $faq)
                    <div class="border p-3 rounded">
                        <div class="flex justify-between">
                            <p class="font-medium text-gray-800">{{ $faq->question }}</p>
                            <form action="{{ route('admin.cms.faqs.delete', $faq) }}" method="POST">
                                @csrf @method('DELETE')
                                <button type="submit" class="text-red-600 hover:text-red-900 text-sm">X</button>
                            </form>
                        </div>
                        <p class="text-sm text-gray-600 mt-1">{{ $faq->answer }}</p>
                    </div>
                @endforeach
            </div>
        </div>

    </div>
@endsection
