# تشغيل تَدَبُّر على GitHub Codespaces

## 1) رفع الكود إلى المستودع

من جهازك أو من الطرفية:

```bash
git clone https://github.com/TEaG3/Tadapor.git
cd Tadapor

# انسخ محتويات مجلد tadapor إلى جذر المستودع
# أو ارفع الملفات مباشرة عبر GitHub Upload

git add .
git commit -m "إضافة مشروع Flutter تَدَبُّر - مواقيت وأذان وأذكار"
git push origin main
```

## 2) فتح Codespace

1. ادخل إلى: https://github.com/TEaG3/Tadapor
2. اضغط **Code** ← تبويب **Codespaces** ← **Create codespace on main**
3. انتظر حتى يكتمل بناء الـ Dev Container (يحتوي Flutter جاهزاً)

## 3) داخل Codespace

```bash
# تثبيت الحزم
flutter pub get

# تشغيل على الويب (الأسهل داخل Codespaces)
flutter run -d web-server --web-port=8080 --web-hostname=0.0.0.0
```

ثم افتح المنفذ **8080** من قائمة Ports في VS Code.

### ملاحظات مهمة

- **الموقع (GPS)** و**البوصلة** و**الإشعارات** تعمل بشكل كامل فقط على جهاز حقيقي (Android/iOS)، وليس على الويب.
- لاختبار الأذان والإشعارات: ابنِ APK لاحقاً أو استخدم جهازك عبر `flutter run`.
- ضع ملف `adhan.mp3` في `assets/audio/` قبل الاختبار الصوتي.

## 4) بناء APK من Codespaces (اختياري)

```bash
flutter build apk --release
# الملف يظهر في: build/app/outputs/flutter-apk/app-release.apk
```

ثم حمّله من مستكشف الملفات في Codespace.
