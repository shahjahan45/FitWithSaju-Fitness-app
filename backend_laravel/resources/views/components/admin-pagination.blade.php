@php
    $current = $paginator->currentPage();
    $last = $paginator->lastPage();
    $start = max(1, $current - 2);
    $end = min($last, $current + 2);
@endphp
@if ($paginator->total() > 0)
<div class="pagination-row">
    <div class="pagination-meta">Showing {{ $paginator->firstItem() }}–{{ $paginator->lastItem() }} of {{ $paginator->total() }} results</div>
    @if ($last > 1)
    <nav class="pagination" aria-label="Pagination">
        @if ($paginator->onFirstPage())
            <span class="page-link disabled" aria-disabled="true"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="m15 18-6-6 6-6"/></svg></span>
        @else
            <a class="page-link" href="{{ $paginator->previousPageUrl() }}" rel="prev" aria-label="Previous"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="m15 18-6-6 6-6"/></svg></a>
        @endif
        @if ($start > 1)
            <a class="page-link" href="{{ $paginator->url(1) }}">1</a>
            @if ($start > 2)<span class="page-link disabled">…</span>@endif
        @endif
        @for ($page = $start; $page <= $end; $page++)
            @if ($page === $current)<span class="page-link current" aria-current="page">{{ $page }}</span>@else<a class="page-link" href="{{ $paginator->url($page) }}">{{ $page }}</a>@endif
        @endfor
        @if ($end < $last)
            @if ($end < $last - 1)<span class="page-link disabled">…</span>@endif
            <a class="page-link" href="{{ $paginator->url($last) }}">{{ $last }}</a>
        @endif
        @if ($paginator->hasMorePages())
            <a class="page-link" href="{{ $paginator->nextPageUrl() }}" rel="next" aria-label="Next"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="m9 18 6-6-6-6"/></svg></a>
        @else
            <span class="page-link disabled" aria-disabled="true"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="m9 18 6-6-6-6"/></svg></span>
        @endif
    </nav>
    @endif
</div>
@endif
