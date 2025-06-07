# Icon Replacement Guide for Multi Tools

## App Icons

### Android App Icons
Replace the following placeholder files with actual PNG icons:

- `android/app/src/main/res/mipmap-mdpi/ic_launcher_todo.png` (48x48 px)
- `android/app/src/main/res/mipmap-hdpi/ic_launcher_todo.png` (72x72 px)  
- `android/app/src/main/res/mipmap-xhdpi/ic_launcher_todo.png` (96x96 px)
- `android/app/src/main/res/mipmap-xxhdpi/ic_launcher_todo.png` (144x144 px)
- `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_todo.png` (192x192 px)

After replacing, rename files to `ic_launcher.png` in each folder.

### Windows App Icon
Replace the following placeholder file:
- `windows/runner/resources/app_icon_todo.ico` (ICO format with multiple sizes: 16x16, 32x32, 48x48, 256x256)

After replacing, rename to `app.ico` and update the Runner.rc file reference.

## Quick Actions Icons (Android only)

Replace the following placeholder files with actual XML vector drawables:
- `android/app/src/main/res/drawable/ic_shortcut_text_template_todo.xml`
- `android/app/src/main/res/drawable/ic_random_generator_todo.xml`

After replacing, rename files by removing `_todo` suffix.

## Icon Requirements

### Design Guidelines
- Use consistent design language
- Ensure good contrast and visibility
- Follow Material Design principles for Android
- Use simple, recognizable symbols

### File Formats
- Android: PNG for app icons, XML vector drawables for shortcuts
- Windows: ICO format with multiple resolutions

## Notes
- All placeholder files are marked with `_todo` suffix
- Remove `_todo` from filenames after replacement
- Test icons on different screen densities and themes
