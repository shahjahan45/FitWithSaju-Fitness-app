<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <meta name="theme-color" content="#0b1420">
    <title>@yield('title', 'FitWithSaju Admin')</title>
    <style>
        :root{
            --canvas:#f6f8fb;--surface:#ffffff;--surface-2:#f9fbfd;--surface-3:#f1f5f9;
            --ink:#0b1420;--muted:#66758a;--muted-2:#91a0b2;--line:#e3e9f1;
            --brand:#8bd10f;--brand-strong:#70b800;--brand-soft:#eff8d8;--brand-ink:#355c00;
            --nav:#0c1725;--nav-2:#132338;--nav-text:#c6d1df;--danger:#d94747;--warning:#bd7600;
            --shadow-sm:0 8px 24px rgba(16,32,51,.06);--shadow:0 18px 48px rgba(16,32,51,.09);
            --sidebar-w:264px;--sidebar-collapsed:86px;--topbar-h:68px;--radius:18px;
        }
        *{box-sizing:border-box}
        html{scroll-behavior:smooth;background:var(--canvas)}
        body{margin:0;background:var(--canvas);color:var(--ink);font-family:Inter,ui-sans-serif,system-ui,-apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif;-webkit-font-smoothing:antialiased}
        a{text-decoration:none;color:inherit} button,input,select,textarea{font:inherit} button,a{ -webkit-tap-highlight-color:transparent }
        :focus-visible{outline:3px solid rgba(139,209,15,.25);outline-offset:2px}

        .admin-shell{min-height:100vh}
        .sidebar{position:fixed;inset:0 auto 0 0;width:var(--sidebar-w);background:linear-gradient(180deg,#0b1522 0%,#102036 100%);color:#fff;z-index:60;display:flex;flex-direction:column;transition:width .28s cubic-bezier(.2,.8,.2,1),transform .28s cubic-bezier(.2,.8,.2,1);box-shadow:12px 0 36px rgba(8,19,33,.12);overflow:hidden}
        .sidebar::after{content:"";position:absolute;inset:auto -120px -120px auto;width:280px;height:280px;border-radius:50%;background:radial-gradient(circle,rgba(139,209,15,.13),transparent 65%);pointer-events:none}
        .brand{height:var(--topbar-h);display:flex;align-items:center;gap:12px;padding:0 18px;border-bottom:1px solid rgba(255,255,255,.07);flex:0 0 auto}
        .brand-mark{width:40px;height:40px;border-radius:13px;background:linear-gradient(145deg,#a8e32e,#74bd00);display:grid;place-items:center;color:#0c1725;font-weight:950;font-size:16px;letter-spacing:-.04em;box-shadow:0 9px 24px rgba(139,209,15,.22);flex:none}
        .brand-copy{min-width:0;transition:opacity .18s ease,transform .18s ease;white-space:nowrap}.brand-name{font-size:18px;font-weight:900;letter-spacing:-.03em}.brand-name b{color:#a6df31}.brand-sub{font-size:10px;color:#8fa2b7;font-weight:800;letter-spacing:.07em;margin-top:2px}
        .collapse-btn{margin-left:auto;width:34px;height:34px;border:0;border-radius:10px;background:rgba(255,255,255,.06);color:#d7e0ea;cursor:pointer;display:grid;place-items:center;transition:.18s}.collapse-btn:hover{background:rgba(255,255,255,.11);color:#fff}.collapse-btn svg{width:18px;height:18px;transition:transform .25s ease}
        .nav-wrap{padding:18px 12px;overflow:auto;scrollbar-width:none;flex:1}.nav-wrap::-webkit-scrollbar{display:none}.nav-section{font-size:10px;color:#667b92;font-weight:900;letter-spacing:.12em;padding:10px 12px 7px;text-transform:uppercase;white-space:nowrap}
        .nav{display:flex;flex-direction:column;gap:5px}.nav-link{position:relative;display:flex;align-items:center;gap:12px;min-height:46px;padding:0 12px;border-radius:13px;color:var(--nav-text);font-size:14px;font-weight:750;transition:background .18s ease,color .18s ease,transform .18s ease;white-space:nowrap}.nav-link:hover{background:rgba(255,255,255,.07);color:#fff;transform:translateX(2px)}.nav-link.active{background:linear-gradient(90deg,rgba(139,209,15,.19),rgba(139,209,15,.10));color:#fff}.nav-link.active::before{content:"";position:absolute;left:0;top:10px;bottom:10px;width:3px;border-radius:3px;background:var(--brand)}
        .nav-icon{width:22px;height:22px;display:grid;place-items:center;flex:none;color:#b5c5d7}.nav-link.active .nav-icon{color:var(--brand)}.nav-icon svg{width:20px;height:20px}.nav-label{overflow:hidden;text-overflow:ellipsis;transition:opacity .18s ease,width .2s ease}
        .sidebar-footer{padding:14px 12px 18px;position:relative;z-index:1}.profile-card{display:flex;align-items:center;gap:11px;padding:11px;border:1px solid rgba(255,255,255,.08);background:rgba(2,10,20,.28);border-radius:15px;min-height:64px}.avatar{width:38px;height:38px;border-radius:50%;background:linear-gradient(145deg,#9ddd20,#68b600);color:#102000;display:grid;place-items:center;font-weight:950;flex:none;box-shadow:0 0 0 3px rgba(139,209,15,.09)}.profile-copy{min-width:0;flex:1}.profile-copy strong{display:block;font-size:13px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}.profile-copy span{font-size:11px;color:#8fa2b7;display:block;margin-top:2px}.profile-chevron{color:#90a2b5;width:16px;height:16px;flex:none}

        .workspace{min-height:100vh;margin-left:var(--sidebar-w);transition:margin-left .28s cubic-bezier(.2,.8,.2,1)}
        .topbar{height:var(--topbar-h);position:sticky;top:0;z-index:40;background:rgba(255,255,255,.88);backdrop-filter:blur(18px);border-bottom:1px solid rgba(221,229,239,.92);display:flex;align-items:center;padding:0 28px;gap:18px}
        .mobile-menu{display:none;border:0;background:transparent;width:38px;height:38px;border-radius:10px;place-items:center;cursor:pointer;color:#263548}.mobile-menu:hover{background:var(--surface-3)}
        .crumb{display:flex;align-items:center;gap:9px;color:#77869a;font-size:13px;min-width:0}.crumb svg{width:17px;height:17px}.crumb strong{color:#243246;font-weight:750;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}.crumb-sep{color:#b2bdc9}
        .topbar-spacer{flex:1}.global-search{position:relative;width:min(320px,30vw)}.global-search input{height:40px;width:100%;border:1px solid var(--line);border-radius:12px;background:#fbfcfe;padding:0 42px 0 38px;color:var(--ink);outline:0;transition:.18s}.global-search input:focus{background:#fff;border-color:#bddf72;box-shadow:0 0 0 4px rgba(139,209,15,.10)}.global-search .search-icon{position:absolute;left:13px;top:50%;transform:translateY(-50%);width:17px;height:17px;color:#7f8da0}.kbd{position:absolute;right:10px;top:50%;transform:translateY(-50%);font-size:10px;color:#95a1b0;border:1px solid #e2e7ee;background:#fff;border-radius:6px;padding:2px 5px;font-weight:700}
        .top-action{width:40px;height:40px;border:1px solid var(--line);background:#fff;border-radius:12px;display:grid;place-items:center;color:#425268;cursor:pointer;transition:.18s}.top-action:hover{border-color:#cfdae6;background:#f8fafc;transform:translateY(-1px)}.top-action svg{width:18px;height:18px}
        .account{position:relative}.account-btn{border:0;background:transparent;display:flex;align-items:center;gap:9px;padding:3px 5px 3px 3px;border-radius:12px;cursor:pointer}.account-btn:hover{background:#f2f5f8}.account-btn .avatar{width:36px;height:36px}.account-name{font-size:12px;font-weight:800;max-width:110px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}.account-menu{position:absolute;right:0;top:48px;width:210px;background:#fff;border:1px solid var(--line);border-radius:15px;box-shadow:var(--shadow);padding:8px;opacity:0;visibility:hidden;transform:translateY(-6px) scale(.98);transform-origin:top right;transition:.16s;z-index:80}.account.open .account-menu{opacity:1;visibility:visible;transform:none}.account-menu .menu-head{padding:9px 10px 10px;border-bottom:1px solid #edf1f5;margin-bottom:5px}.account-menu .menu-head strong{display:block;font-size:13px}.account-menu .menu-head span{display:block;font-size:11px;color:var(--muted);margin-top:2px}.menu-item{width:100%;border:0;background:transparent;border-radius:9px;padding:9px 10px;display:flex;align-items:center;gap:9px;text-align:left;color:#35455a;font-weight:700;cursor:pointer}.menu-item:hover{background:#f5f7fa}.menu-item.danger{color:#ac3434}.menu-item svg{width:17px;height:17px}

        .content{padding:26px 28px 42px;max-width:1580px;margin:0 auto}.page-head{display:flex;align-items:flex-start;justify-content:space-between;gap:20px;margin-bottom:22px}.title h1{margin:0;font-size:27px;line-height:1.12;letter-spacing:-.035em}.title p{margin:7px 0 0;color:var(--muted);font-size:13px;line-height:1.5;max-width:760px}.page-actions{display:flex;align-items:center;gap:9px;flex-wrap:wrap}
        .muted{color:var(--muted)}
        .notice,.errors{display:flex;gap:10px;align-items:flex-start;padding:13px 15px;border-radius:14px;margin-bottom:18px;border:1px solid}.notice{background:#f2f9df;border-color:#d9eca9;color:#466b04}.errors{background:#fff3f3;border-color:#ffd7d7;color:#9d3434}.errors ul{margin:5px 0 0;padding-left:18px}

        .card{background:var(--surface);border:1px solid var(--line);border-radius:var(--radius);box-shadow:var(--shadow-sm)}.card-hover{transition:transform .2s ease,box-shadow .2s ease,border-color .2s ease}.card-hover:hover{transform:translateY(-2px);box-shadow:var(--shadow);border-color:#d8e1ec}.pad{padding:19px}.grid{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:16px}.grid-2{display:grid;grid-template-columns:minmax(0,1.4fr) minmax(320px,.8fr);gap:16px}
        .metric{position:relative;overflow:hidden;min-height:120px;display:flex;flex-direction:column;justify-content:space-between}.metric-top{display:flex;justify-content:space-between;gap:12px;align-items:flex-start}.metric-icon{width:42px;height:42px;border-radius:50%;background:var(--brand-soft);color:#5a8e00;display:grid;place-items:center}.metric-icon svg{width:21px;height:21px}.metric strong{font-size:28px;letter-spacing:-.04em;line-height:1}.metric-label{color:#637286;font-size:12px;font-weight:700;margin-top:6px}.metric-note{color:#8794a5;font-size:11px;margin-top:9px}.metric-trend{font-size:11px;font-weight:850;color:#5f9700;display:inline-flex;align-items:center;gap:4px}.metric-trend.neutral{color:#718095}
        .panel-head{display:flex;align-items:center;justify-content:space-between;gap:16px;margin-bottom:16px}.panel-title{font-weight:850;font-size:15px;letter-spacing:-.015em}.panel-sub{font-size:12px;color:var(--muted);margin-top:3px}.panel-actions{display:flex;align-items:center;gap:8px}
        .health-list{display:grid;gap:18px}.health-row{display:grid;grid-template-columns:1fr auto;gap:8px}.health-label{font-size:12px;font-weight:800}.health-value{font-size:12px;color:var(--muted);font-weight:800}.progress{grid-column:1/-1;height:7px;background:#edf1f5;border-radius:999px;overflow:hidden}.progress span{display:block;height:100%;border-radius:inherit;background:linear-gradient(90deg,#77bd00,#a7e52a);transition:width .7s cubic-bezier(.2,.8,.2,1)}
        .donut-row{display:flex;align-items:center;gap:24px;min-height:190px}.donut{--exercise-end:50%;--recipe-end:80%;width:154px;height:154px;border-radius:50%;position:relative;background:conic-gradient(var(--brand) 0 var(--exercise-end),#516279 var(--exercise-end) var(--recipe-end),#dce3eb var(--recipe-end) 100%);flex:none}.donut::after{content:"";position:absolute;inset:34px;border-radius:50%;background:#fff}.donut-center{position:absolute;inset:0;display:grid;place-items:center;z-index:1;text-align:center}.donut-center strong{font-size:24px;display:block}.donut-center span{display:block;font-size:10px;color:var(--muted);font-weight:800;margin-top:2px}.legend{display:grid;gap:12px;flex:1}.legend-item{display:grid;grid-template-columns:auto 1fr auto;gap:8px;align-items:center;font-size:12px}.dot{width:9px;height:9px;border-radius:50%}.dot.green{background:var(--brand)}.dot.blue{background:#516279}.dot.gray{background:#dce3eb}.legend-item strong{font-size:12px}.legend-item span{color:var(--muted)}

        .toolbar-card{background:#fff;border:1px solid var(--line);border-radius:16px;padding:12px;margin-bottom:14px;box-shadow:0 5px 18px rgba(16,32,51,.035)}.toolbar{display:flex;align-items:center;gap:10px;flex-wrap:wrap}.filter-form{display:flex;align-items:center;gap:9px;flex:1;flex-wrap:wrap}.filter-grow{flex:1;min-width:220px;max-width:390px}.input,.select,.textarea{width:100%;border:1px solid #dfe6ee;background:#fff;border-radius:11px;padding:10px 12px;color:var(--ink);outline:none;transition:.18s}.input,.select{min-height:41px}.input::placeholder,.textarea::placeholder{color:#a0acba}.input:focus,.select:focus,.textarea:focus{border-color:#acd35e;box-shadow:0 0 0 4px rgba(139,209,15,.10)}.textarea{min-height:120px;resize:vertical;line-height:1.55}
        .btn{border:1px solid transparent;border-radius:10px;min-height:40px;padding:9px 13px;font-weight:800;font-size:12px;cursor:pointer;display:inline-flex;align-items:center;justify-content:center;gap:7px;transition:transform .16s ease,box-shadow .16s ease,background .16s ease,border-color .16s ease;white-space:nowrap}.btn:hover{transform:translateY(-1px)}.btn:active{transform:translateY(0) scale(.985)}.btn svg{width:16px;height:16px}.btn-primary{background:linear-gradient(180deg,#91d716,#78bf00);color:#173200;box-shadow:0 7px 16px rgba(117,186,0,.18)}.btn-primary:hover{box-shadow:0 10px 22px rgba(117,186,0,.24)}.btn-soft{background:var(--brand-soft);border-color:#e1efbd;color:#4e7604}.btn-light{background:#fff;border-color:#dde5ee;color:#34445a}.btn-light:hover{background:#f8fafc;border-color:#ccd7e3}.btn-danger{background:#fff4f4;border-color:#ffdada;color:#a93636}.btn-icon{width:39px;padding:0}.btn-sm{min-height:34px;padding:7px 10px}
        .table-card{overflow:hidden}.table-wrap{overflow:auto;max-width:100%;scrollbar-color:#cdd6e1 transparent}.table{width:100%;border-collapse:separate;border-spacing:0;min-width:820px}.table th,.table td{text-align:left;padding:13px 15px;border-bottom:1px solid #edf1f5;vertical-align:middle}.table th{font-size:10px;text-transform:uppercase;letter-spacing:.055em;color:#7d8a9b;background:#fbfcfd;font-weight:850;white-space:nowrap}.table tbody tr{transition:background .15s ease}.table tbody tr:hover{background:#fbfdf7}.table tbody tr:last-child td{border-bottom:0}.entity{display:flex;align-items:center;gap:11px;min-width:180px}.preview{width:48px;height:48px;border-radius:12px;object-fit:cover;background:#f0f3f6;border:1px solid #e0e7ef;flex:none}.entity-title{font-size:13px;font-weight:850;line-height:1.25}.entity-meta{font-size:10.5px;color:var(--muted);margin-top:4px;line-height:1.35}.actions{display:flex;align-items:center;gap:6px;flex-wrap:wrap}.badge{display:inline-flex;align-items:center;gap:5px;padding:5px 8px;border-radius:999px;font-size:10.5px;font-weight:850;background:#f1f4f7;color:#59687b;text-transform:capitalize;white-space:nowrap}.badge::before{content:"";width:5px;height:5px;border-radius:50%;background:currentColor;opacity:.7}.badge.on{background:#eef8db;color:#568200}.badge.off{background:#fff0f0;color:#b03c3c}.badge.warn{background:#fff7df;color:#9d6a00}.badge.neutral{background:#f1f4f7;color:#66758a}.chip{display:inline-flex;padding:5px 8px;border-radius:8px;font-size:10px;font-weight:750;background:#f4f6f8;color:#59687b;margin:2px 3px 2px 0}
        .table-empty{text-align:center!important;padding:44px 20px!important;color:var(--muted)}

        .pagination-row{display:flex;align-items:center;justify-content:space-between;gap:14px;margin-top:14px;padding:0 2px}.pagination-meta{font-size:11px;color:var(--muted)}.pagination{display:flex;align-items:center;gap:5px}.page-link{min-width:34px;height:34px;padding:0 9px;border:1px solid #dfe6ee;border-radius:9px;background:#fff;display:grid;place-items:center;font-size:11px;font-weight:800;color:#4d5e73;transition:.15s}.page-link:hover:not(.disabled){border-color:#b8db72;background:#f7fbe9;color:#456b00}.page-link.current{background:var(--brand-soft);border-color:#a9d557;color:#456b00}.page-link.disabled{opacity:.45;cursor:not-allowed}.page-link svg{width:15px;height:15px}

        .form-card{padding:22px}.form-grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:17px}.field label{display:flex;align-items:center;gap:6px;font-size:11px;font-weight:850;color:#3b4b60;margin:0 0 7px}.field.full{grid-column:1/-1}.field-help{font-size:10.5px;color:var(--muted);line-height:1.45;margin-top:6px}.form-section{grid-column:1/-1;border-top:1px solid #edf1f5;padding-top:18px;margin-top:4px}.form-section-title{font-size:12px;font-weight:900;margin-bottom:4px}.form-section-sub{font-size:10.5px;color:var(--muted)}.check-row{display:flex;align-items:center;gap:9px;min-height:42px}.check-row input{accent-color:var(--brand-strong);width:17px;height:17px}.form-actions{display:flex;gap:9px;align-items:center;flex-wrap:wrap;margin-top:20px;padding-top:18px;border-top:1px solid #edf1f5}
        input[type=file]::file-selector-button{border:0;background:#eef3f7;color:#39495d;border-radius:8px;padding:7px 10px;margin-right:10px;font-weight:750;cursor:pointer}
        .danger-card{border-color:#f3d8d8;background:linear-gradient(180deg,#fff,#fffafa)}.danger-card strong{color:#9e3434}.danger-card p{font-size:12px;line-height:1.5;margin:7px 0 13px}.code-input{font-family:ui-monospace,SFMono-Regular,Consolas,monospace;font-size:12px}

        .search-results{display:grid;gap:16px}.result-group .group-head{display:flex;align-items:center;justify-content:space-between;margin-bottom:10px}.result-group h2{font-size:15px;margin:0}.result-list{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:10px}.result-item{padding:14px;border:1px solid var(--line);border-radius:13px;background:#fff;display:flex;justify-content:space-between;align-items:center;gap:12px;transition:.16s}.result-item:hover{border-color:#bddd78;background:#fbfdf6;transform:translateY(-1px)}.result-item strong{font-size:12px}.result-item span{font-size:10.5px;color:var(--muted);display:block;margin-top:3px}

        .sidebar-overlay{display:none;position:fixed;inset:0;background:rgba(4,12,23,.5);backdrop-filter:blur(2px);z-index:55;opacity:0;transition:opacity .2s}
        body.sidebar-collapsed .sidebar{width:var(--sidebar-collapsed)}body.sidebar-collapsed .workspace{margin-left:var(--sidebar-collapsed)}body.sidebar-collapsed .brand-copy,body.sidebar-collapsed .nav-label,body.sidebar-collapsed .nav-section,body.sidebar-collapsed .profile-copy,body.sidebar-collapsed .profile-chevron{opacity:0;pointer-events:none;width:0;overflow:hidden}body.sidebar-collapsed .brand{padding-left:23px}body.sidebar-collapsed .collapse-btn{position:absolute;right:8px;top:16px;width:28px;height:34px;background:rgba(0,0,0,.18)}body.sidebar-collapsed .collapse-btn svg{transform:rotate(180deg)}body.sidebar-collapsed .nav-link{justify-content:center;padding:0}body.sidebar-collapsed .nav-link:hover{transform:none}body.sidebar-collapsed .profile-card{justify-content:center;padding:9px}

        @media(max-width:1180px){.grid-2{grid-template-columns:1fr}.global-search{width:250px}.grid{grid-template-columns:repeat(2,minmax(0,1fr))}}
        @media(max-width:900px){.sidebar{transform:translateX(-102%);width:min(310px,86vw)}.workspace,.sidebar-collapsed .workspace{margin-left:0!important}.topbar{padding:0 16px}.mobile-menu{display:grid}.global-search{display:none}.account-name{display:none}.content{padding:20px 16px 34px}.sidebar-overlay{display:block;pointer-events:none}.sidebar-open .sidebar{transform:none}.sidebar-open .sidebar-overlay{opacity:1;pointer-events:auto}.collapse-btn{display:none}.page-head{align-items:center}.grid{grid-template-columns:repeat(2,minmax(0,1fr))}}
        @media(max-width:640px){.topbar{gap:9px}.crumb .crumb-home,.crumb-sep{display:none}.content{padding:17px 12px 28px}.page-head{align-items:flex-start;flex-direction:column}.page-actions{width:100%}.page-actions .btn{flex:1}.title h1{font-size:24px}.grid{grid-template-columns:1fr}.grid-2{gap:12px}.card{border-radius:15px}.pad,.form-card{padding:15px}.metric{min-height:106px}.toolbar-card{padding:10px}.filter-form>*{flex:1 1 100%;max-width:none!important}.toolbar>.btn-primary{width:100%}.table{min-width:720px}.table th,.table td{padding:11px 12px}.pagination-row{align-items:flex-start;flex-direction:column}.pagination{width:100%;justify-content:flex-end;overflow:auto}.form-grid{grid-template-columns:1fr;gap:14px}.field.full,.form-section{grid-column:auto}.result-list{grid-template-columns:1fr}.donut-row{flex-direction:column;align-items:flex-start}.legend{width:100%}}
        @media(prefers-reduced-motion:reduce){*,*::before,*::after{scroll-behavior:auto!important;transition:none!important;animation:none!important}}
    </style>
    @stack('styles')
</head>
<body>
<div class="admin-shell">
    <div class="sidebar-overlay" id="sidebarOverlay"></div>
    <aside class="sidebar" id="sidebar" aria-label="Administration navigation">
        <div class="brand">
            <div class="brand-mark">FS</div>
            <div class="brand-copy"><div class="brand-name">FitWith<b>Saju</b></div><div class="brand-sub">CONTENT ADMIN</div></div>
            <button class="collapse-btn" id="collapseSidebar" type="button" aria-label="Collapse sidebar">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="m15 18-6-6 6-6"/></svg>
            </button>
        </div>
        <div class="nav-wrap">
            <div class="nav-section">Workspace</div>
            <nav class="nav">
                <a href="{{ route('admin.dashboard') }}" class="nav-link {{ request()->routeIs('admin.dashboard') ? 'active' : '' }}"><span class="nav-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M3 11.5 12 4l9 7.5"/><path d="M5.5 10.5V20h13v-9.5"/><path d="M9.5 20v-6h5v6"/></svg></span><span class="nav-label">Dashboard</span></a>
                <a href="{{ route('admin.exercises.index') }}" class="nav-link {{ request()->routeIs('admin.exercises.*') ? 'active' : '' }}"><span class="nav-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M6 8v8M18 8v8M3.5 10v4M20.5 10v4M8.5 12h7"/><rect x="4.5" y="6" width="3" height="12" rx="1"/><rect x="16.5" y="6" width="3" height="12" rx="1"/></svg></span><span class="nav-label">Exercises</span></a>
                <a href="{{ route('admin.recipes.index') }}" class="nav-link {{ request()->routeIs('admin.recipes.*') ? 'active' : '' }}"><span class="nav-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M4 10h16l-1 8a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2l-1-8Z"/><path d="M7 10a5 5 0 0 1 10 0M12 5V3"/></svg></span><span class="nav-label">Recipes</span></a>
                <a href="{{ route('admin.ingredients.index') }}" class="nav-link {{ request()->routeIs('admin.ingredients.*') ? 'active' : '' }}"><span class="nav-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M20 4c-8 0-14 4-14 10 0 3 2 5 5 5 6 0 9-7 9-15Z"/><path d="M4 20c3-6 7-9 13-12"/></svg></span><span class="nav-label">Ingredients</span></a>
                <a href="{{ route('admin.meal-templates.index') }}" class="nav-link {{ request()->routeIs('admin.meal-templates.*') ? 'active' : '' }}"><span class="nav-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><rect x="4" y="5" width="16" height="15" rx="2"/><path d="M8 3v4M16 3v4M4 10h16"/></svg></span><span class="nav-label">Meal Plans</span></a>
            </nav>
        </div>
        <div class="sidebar-footer">
            <div class="profile-card">
                <div class="avatar">{{ strtoupper(substr(auth()->user()->name ?? 'S', 0, 1)) }}</div>
                <div class="profile-copy"><strong>{{ auth()->user()->name ?? 'Admin' }}</strong><span>Content Admin</span></div>
                <svg class="profile-chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="m9 18 6-6-6-6"/></svg>
            </div>
        </div>
    </aside>

    <div class="workspace">
        <header class="topbar">
            <button class="mobile-menu" id="mobileMenu" type="button" aria-label="Open navigation"><svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 7h16M4 12h16M4 17h16"/></svg></button>
            <div class="crumb"><svg class="crumb-home" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M3 11.5 12 4l9 7.5"/><path d="M5.5 10.5V20h13v-9.5"/></svg><span class="crumb-sep">›</span><strong>@yield('heading', 'Dashboard')</strong></div>
            <div class="topbar-spacer"></div>
            <form class="global-search" method="GET" action="{{ route('admin.search') }}">
                <svg class="search-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="7"/><path d="m20 20-3.5-3.5"/></svg>
                <input id="globalSearch" name="q" value="{{ request()->routeIs('admin.search') ? request('q') : '' }}" placeholder="Search content..." autocomplete="off">
                <span class="kbd">/</span>
            </form>
            <a class="top-action" href="{{ route('admin.recipes.create') }}" title="New recipe" aria-label="Create recipe"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 5v14M5 12h14"/></svg></a>
            <div class="account" id="accountMenu">
                <button class="account-btn" id="accountButton" type="button" aria-expanded="false"><span class="avatar">{{ strtoupper(substr(auth()->user()->name ?? 'S',0,1)) }}</span><span class="account-name">{{ auth()->user()->name ?? 'Admin' }}</span><svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="m6 9 6 6 6-6"/></svg></button>
                <div class="account-menu">
                    <div class="menu-head"><strong>{{ auth()->user()->name ?? 'Admin' }}</strong><span>{{ auth()->user()->email ?? '' }}</span></div>
                    <form method="POST" action="{{ route('admin.logout') }}">@csrf<button class="menu-item danger" type="submit"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M10 17l5-5-5-5M15 12H3M14 3h5a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2h-5"/></svg>Sign out</button></form>
                </div>
            </div>
        </header>

        <main class="content">
            <div class="page-head">
                <div class="title"><h1>@yield('heading', 'FitWithSaju')</h1><p>@yield('subheading')</p></div>
                <div class="page-actions">@yield('page_actions')</div>
            </div>
            @if(session('success'))<div class="notice"><strong>✓</strong><div>{{ session('success') }}</div></div>@endif
            @if($errors->any())<div class="errors"><strong>!</strong><div><strong>Please fix the following:</strong><ul>@foreach($errors->all() as $error)<li>{{ $error }}</li>@endforeach</ul></div></div>@endif
            @yield('content')
        </main>
    </div>
</div>
<script>
(() => {
    const body = document.body;
    const collapse = document.getElementById('collapseSidebar');
    const mobileMenu = document.getElementById('mobileMenu');
    const overlay = document.getElementById('sidebarOverlay');
    const account = document.getElementById('accountMenu');
    const accountButton = document.getElementById('accountButton');
    const search = document.getElementById('globalSearch');
    const collapsed = localStorage.getItem('fws-admin-sidebar') === 'collapsed';
    if (collapsed && window.innerWidth > 900) body.classList.add('sidebar-collapsed');
    collapse?.addEventListener('click', () => {
        body.classList.toggle('sidebar-collapsed');
        localStorage.setItem('fws-admin-sidebar', body.classList.contains('sidebar-collapsed') ? 'collapsed' : 'open');
    });
    const closeMobile = () => body.classList.remove('sidebar-open');
    mobileMenu?.addEventListener('click', () => body.classList.toggle('sidebar-open'));
    overlay?.addEventListener('click', closeMobile);
    document.querySelectorAll('.nav-link').forEach(link => link.addEventListener('click', closeMobile));
    accountButton?.addEventListener('click', e => { e.stopPropagation(); account.classList.toggle('open'); accountButton.setAttribute('aria-expanded', account.classList.contains('open')); });
    document.addEventListener('click', () => account?.classList.remove('open'));
    document.addEventListener('keydown', e => {
        if (e.key === '/' && !['INPUT','TEXTAREA','SELECT'].includes(document.activeElement?.tagName)) { e.preventDefault(); search?.focus(); }
        if (e.key === 'Escape') { closeMobile(); account?.classList.remove('open'); }
    });
    window.addEventListener('resize', () => { if (window.innerWidth > 900) closeMobile(); });
})();
</script>
@stack('scripts')
</body>
</html>
