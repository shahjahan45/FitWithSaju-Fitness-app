<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>@yield('title', 'FitWithSaju Admin')</title>
    <style>
        :root{--bg:#f5f8fb;--surface:#fff;--text:#0b1420;--muted:#728093;--border:#dce5f0;--brand:#86c613;--brand-soft:#edf7d3;--danger:#d9534f;--shadow:0 16px 45px rgba(11,20,32,.08)}
        *{box-sizing:border-box} body{margin:0;background:var(--bg);color:var(--text);font-family:Inter,ui-sans-serif,system-ui,-apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif} a{text-decoration:none;color:inherit}
        .shell{display:grid;grid-template-columns:245px 1fr;min-height:100vh}.sidebar{background:#0d1723;color:#fff;padding:24px 18px;position:sticky;top:0;height:100vh}.brand{display:flex;gap:12px;align-items:center;font-weight:900;font-size:20px;margin-bottom:32px}.brand-mark{width:42px;height:42px;border-radius:15px;background:linear-gradient(145deg,#a5e238,#71b400);display:grid;place-items:center;color:#0d1723;font-weight:1000}.nav a{display:flex;gap:11px;align-items:center;padding:12px 14px;border-radius:14px;color:#b7c2cf;margin-bottom:6px;font-weight:700}.nav a.active,.nav a:hover{background:rgba(134,198,19,.15);color:#dff8a2}.main{padding:28px}.topbar{display:flex;justify-content:space-between;gap:16px;align-items:center;margin-bottom:24px}.title h1{margin:0;font-size:30px}.title p{margin:7px 0 0;color:var(--muted)}
        .card{background:var(--surface);border:1px solid var(--border);border-radius:22px;box-shadow:var(--shadow)}.pad{padding:20px}.grid{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:16px}.metric strong{font-size:30px;display:block}.metric span{color:var(--muted);font-weight:700}.toolbar{display:flex;gap:10px;flex-wrap:wrap;margin-bottom:16px}.input,.select,.textarea{width:100%;border:1px solid var(--border);background:#fff;border-radius:14px;padding:12px 13px;font:inherit;outline:none}.input:focus,.select:focus,.textarea:focus{border-color:var(--brand);box-shadow:0 0 0 3px rgba(134,198,19,.14)}.textarea{min-height:120px;resize:vertical}.btn{border:0;border-radius:13px;padding:11px 15px;font-weight:850;cursor:pointer;display:inline-flex;align-items:center;gap:8px}.btn-primary{background:var(--brand);color:#102000}.btn-soft{background:var(--brand-soft);color:#456800}.btn-light{background:#fff;border:1px solid var(--border)}.btn-danger{background:#fff0f0;color:#a52e2e}.table-wrap{overflow:auto}.table{width:100%;border-collapse:collapse}.table th,.table td{text-align:left;padding:14px 12px;border-bottom:1px solid #edf1f5;vertical-align:middle}.table th{font-size:12px;text-transform:uppercase;letter-spacing:.04em;color:var(--muted)}.badge{display:inline-flex;padding:6px 9px;border-radius:999px;font-size:12px;font-weight:850;background:#eef2f6;color:#536172}.badge.on{background:var(--brand-soft);color:#4b6e00}.badge.off{background:#fff0f0;color:#a52e2e}.form-grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:16px}.field label{display:block;font-size:12px;font-weight:900;margin:0 0 7px}.field.full{grid-column:1/-1}.notice{padding:12px 15px;border-radius:14px;margin-bottom:16px;background:var(--brand-soft);font-weight:750}.errors{padding:14px 16px;border-radius:14px;margin-bottom:16px;background:#fff0f0;color:#8e2929}.actions{display:flex;gap:8px;flex-wrap:wrap}.muted{color:var(--muted)}.preview{width:68px;height:68px;border-radius:16px;object-fit:cover;background:#f0f3f6;border:1px solid var(--border)}
        @media(max-width:900px){.shell{grid-template-columns:1fr}.sidebar{height:auto;position:static}.nav{display:flex;overflow:auto}.nav a{white-space:nowrap}.main{padding:18px}.grid,.form-grid{grid-template-columns:1fr}}
    </style>
</head>
<body>
<div class="shell">
    <aside class="sidebar">
        <div class="brand"><div class="brand-mark">FS</div><div>FitWithSaju<br><small style="color:#8ea0b2;font-size:11px">CONTENT ADMIN</small></div></div>
        <nav class="nav">
            <a href="{{ route('admin.dashboard') }}" class="{{ request()->routeIs('admin.dashboard') ? 'active' : '' }}">Dashboard</a>
            <a href="{{ route('admin.exercises.index') }}" class="{{ request()->routeIs('admin.exercises.*') ? 'active' : '' }}">Exercises</a>
        </nav>
    </aside>
    <main class="main">
        <div class="topbar">
            <div class="title"><h1>@yield('heading', 'FitWithSaju')</h1><p>@yield('subheading')</p></div>
            <form method="POST" action="{{ route('admin.logout') }}">@csrf<button class="btn btn-light">Sign out</button></form>
        </div>
        @if(session('success'))<div class="notice">{{ session('success') }}</div>@endif
        @if($errors->any())<div class="errors"><strong>Please fix the following:</strong><ul>@foreach($errors->all() as $error)<li>{{ $error }}</li>@endforeach</ul></div>@endif
        @yield('content')
    </main>
</div>
</body>
</html>
