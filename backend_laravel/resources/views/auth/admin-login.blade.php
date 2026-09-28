<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>FitWithSaju Admin Login</title>
<style>
body{margin:0;min-height:100vh;display:grid;place-items:center;background:linear-gradient(135deg,#f6f9fb,#edf7d6);font-family:Inter,system-ui,sans-serif;color:#0b1420}.card{width:min(430px,calc(100% - 32px));background:#fff;border:1px solid #dce5f0;border-radius:28px;padding:30px;box-shadow:0 24px 65px rgba(11,20,32,.12)}.logo{width:62px;height:62px;border-radius:20px;background:#86c613;display:grid;place-items:center;font-weight:1000;font-size:20px;margin-bottom:22px}h1{margin:0;font-size:28px}p{color:#728093;line-height:1.5}.field{margin-top:16px}label{display:block;font-size:12px;font-weight:900;margin-bottom:7px}input[type=email],input[type=password]{width:100%;box-sizing:border-box;border:1px solid #dce5f0;border-radius:14px;padding:13px;font:inherit}.remember{display:flex;gap:8px;align-items:center;margin:16px 0;color:#5f6b78}.btn{width:100%;border:0;border-radius:14px;padding:14px;background:#86c613;font-weight:900;font-size:15px;cursor:pointer}.error{background:#fff0f0;color:#972e2e;border-radius:13px;padding:11px 13px;margin-top:14px}
</style>
</head>
<body>
<form class="card" method="POST" action="{{ route('admin.login.store') }}">
@csrf
<div class="logo">FS</div><h1>FitWithSaju Admin</h1><p>Manage the public exercise library and media used by the mobile app.</p>
@if($errors->any())<div class="error">{{ $errors->first() }}</div>@endif
<div class="field"><label>Email</label><input type="email" name="email" value="{{ old('email') }}" required autofocus></div>
<div class="field"><label>Password</label><input type="password" name="password" required></div>
<label class="remember"><input type="checkbox" name="remember" value="1"> Keep me signed in</label>
<button class="btn" type="submit">Sign in</button>
</form>
</body>
</html>
