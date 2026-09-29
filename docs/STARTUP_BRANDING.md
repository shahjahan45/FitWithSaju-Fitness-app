# FitWithSaju startup branding

Version 1.12.0 separates three launch responsibilities:

1. **Android 12+ system splash** uses `drawable-nodpi/splash_logo.png` with generous transparent padding so the complete FitWithSaju lockup stays inside Android's circular splash mask.
2. **Launcher icon** uses a separately padded adaptive foreground plus legacy density icons. This prevents OEM circle/squircle masks from trimming the logo.
3. **Flutter splash** renders the original transparent `assets/images/fitwithsaju_logo.png` with `BoxFit.contain` and responsive width.

Startup content/cache initialization now begins before `runApp` but is not awaited by `main()`. This lets Android hand off to Flutter quickly. `AppRoot` waits for the same initialization future before entering onboarding/main, so cached content and saved preferences are still ready before the user reaches the app.
