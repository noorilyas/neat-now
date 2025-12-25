# SHA-1 Fingerprint Nikaalne Ka Guide (Windows)

## ✅ Package Name (Already Found)
**Package Name:** `com.example.neat_now`

Yehi package name Google Console mein Android Client ID banate waqt use karna hai.

---

## 🔐 SHA-1 Fingerprint Kaise Nikalein (Windows PowerShell)

### Method 1: Using gradlew.bat (Recommended)

**Step 1:** Terminal/Command Prompt open karein

**Step 2:** Flutter project ke root folder mein jao (jahan `pubspec.yaml` file ho)
```powershell
cd C:\Users\S\OneDrive\Documents\GitHub\neat-now\flutter
```

**Step 3:** Android folder mein jao
```powershell
cd android
```

**Step 4:** SHA-1 nikalne ke liye yeh command run karein
```powershell
.\gradlew.bat signingReport
```

**Step 5:** Output mein yeh dhoondo:
```
Variant: debug
Config: debug
Store: ...
Alias: ...
SHA1: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
```

➡️ **Is SHA1 ko copy kar lo** (colon `:` ke saath)

---

### Method 2: Using keytool (Alternative - Java Install Ke Bina Bhi Kaam Karega)

**Note:** Agar Java install nahi hai, to pehle Java install karein (Method 3 dekhein)

**Step 1:** Debug keystore ka path find karein
```powershell
cd $env:USERPROFILE\.android
```

**Step 2:** SHA-1 nikalne ke liye:
```powershell
keytool -list -v -keystore debug.keystore -alias androiddebugkey -storepass android -keypass android
```

**Step 3:** Output mein "SHA1:" ke neeche value copy karein

**Agar keytool nahi mil raha:**
- Java ka full path use karein: `"C:\Program Files\Java\jdk-XX\bin\keytool.exe"`

---

### Method 3: Java Install Karein (Required for Android)

**Option A: Oracle JDK (Recommended)**
1. Download: https://www.oracle.com/java/technologies/downloads/
2. Java 17 ya 21 download karein (Windows x64 Installer)
3. Install karein (default location: `C:\Program Files\Java\jdk-XX`)
4. Environment Variables set karein:
   - **Windows Key + R** → type `sysdm.cpl` → Enter
   - **Advanced** tab → **Environment Variables**
   - **System variables** mein **New** click karein:
     - Variable name: `JAVA_HOME`
     - Variable value: `C:\Program Files\Java\jdk-XX` (XX = version number)
   - **Path** variable mein **Edit** click karein → **New** → `%JAVA_HOME%\bin` add karein
5. Terminal restart karein
6. Verify: `java -version`

**Option B: OpenJDK (Lightweight)**
1. Download: https://adoptium.net/ (Eclipse Temurin)
2. Java 17 LTS download karein
3. Install karein
4. Environment Variables same as Option A

**Option C: Android Studio Se Java (Easiest)**
1. Android Studio install karein: https://developer.android.com/studio
2. Android Studio automatically Java install karta hai
3. Path usually: `C:\Program Files\Android\Android Studio\jbr`
4. Environment variable set karein (same as Option A)

---

## 📋 Google Console Mein Kaise Add Karein

### Step 1: Google Cloud Console Mein Jao
1. [Google Cloud Console](https://console.cloud.google.com/) open karein
2. **APIs & Services** → **Credentials** par click karein

### Step 2: Android Client ID Banao
1. **Create Credentials** → **OAuth client ID** par click karein
2. **Application type:** `Android` select karein
3. **Name:** `NeatNow Android Client` (ya kuch bhi naam)
4. **Package name:** `com.example.neat_now` (paste karein)
5. **SHA-1 certificate fingerprint:** 
   - Jo SHA-1 aapne copy kiya hai, woh paste karein
   - Format: `XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX`
6. **Create** button par click karein

### Step 3: Client ID Copy Karein
- Client ID copy karein (format: `xxxxx-xxxxx.apps.googleusercontent.com`)
- Isko `flutter/lib/config/credentials.dart` mein add karein

---

## ✅ Quick Checklist

- [x] Package Name: `com.example.neat_now` ✅
- [ ] SHA-1 fingerprint nikalna hai
- [ ] Google Console mein Android Client ID banana hai
- [ ] Client ID ko `credentials.dart` mein add karna hai

---

## 🆘 Troubleshooting

### Problem: `JAVA_HOME is not set`
**Solution:** 
Java install nahi hai ya JAVA_HOME set nahi hai. Do options hain:

**Option 1: Java Install Karein (Recommended)**
1. Java JDK download karein: https://www.oracle.com/java/technologies/downloads/
2. Install karein
3. Environment variable set karein:
   - System Properties → Environment Variables
   - JAVA_HOME add karein: `C:\Program Files\Java\jdk-XX`
   - PATH mein add karein: `%JAVA_HOME%\bin`

**Option 2: Flutter Doctor Use Karein (Easier)**
```powershell
cd C:\Users\S\OneDrive\Documents\GitHub\neat-now\flutter
flutter doctor -v
```
Flutter automatically Java setup karega.

### Problem: `gradlew.bat` command not found
**Solution:** Make sure aap `flutter/android` folder mein hain

### Problem: SHA-1 output mein nahi mil raha
**Solution:** 
- Output scroll karein - `Variant: debug` ke neeche hona chahiye
- Ya `keytool` method try karein

### Problem: SHA-1 format wrong
**Solution:** 
- SHA-1 colon (`:`) ke saath hona chahiye
- Example: `A1:B2:C3:D4:E5:F6:...` (20 pairs)

---

## 📝 Notes

- **Debug SHA-1:** Development/testing ke liye use hota hai
- **Release SHA-1:** Production ke liye alag SHA-1 chahiye (app signing keystore se)
- Abhi ke liye Debug SHA-1 hi kaafi hai

