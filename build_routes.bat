@echo off
echo 🚀 Building WortSpion - Auto Route Generation
echo =============================================
echo.

echo 📦 Getting dependencies...
flutter pub get

echo.
echo 🔧 Generating auto_route files...
flutter packages pub run build_runner build --delete-conflicting-outputs

echo.
echo ✅ Build completed successfully!
echo.
echo 💡 Note: If you see any route-related errors, make sure all @RoutePage() annotations
echo    are properly added to your screen classes and imported in app_router.dart
echo.
pause
