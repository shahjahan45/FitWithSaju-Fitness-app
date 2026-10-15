# FitWithSaju v29.1 — Android Splash Build Hotfix

## Fixed

Android 12+ launch themes referenced `@drawable/splash_logo`, while the image was stored only in `res/drawable-nodpi/`. The splash image has been re-encoded as a standard PNG and moved to:

`android/app/src/main/res/drawable/splash_logo.png`

Both day and night API-31 launch themes continue to reference:

`@drawable/splash_logo`

This guarantees that AAPT creates the exact unqualified drawable resource required by `windowSplashScreenAnimatedIcon`.

A regression test (`test/android_splash_resource_test.dart`) now verifies that the drawable exists and that both API-31 themes reference it.

## Windows Gradle `last-build.bin` access denied

This is a local Gradle cache lock/permission problem and is separate from the Android resource-linking issue. From the project root in PowerShell:

```powershell
cd android
.\gradlew --stop
cd ..
Remove-Item -Recurse -Force .\android\.gradle -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force .\build -ErrorAction SilentlyContinue
flutter clean
flutter pub get
flutter run
```

If Windows still refuses to delete `android\.gradle`, close Android Studio and any terminals using the project, then end only the Java/Gradle process associated with this build and repeat the commands. Avoid deleting the source `android/app/src/main/res` folder.
