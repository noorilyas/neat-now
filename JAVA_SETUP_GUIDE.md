# Java Setup Guide for Windows (SHA-1 Nikaalne Ke Liye)

## ⚠️ Important
Flutter doctor Java automatically setup **nahi** karta. Aapko manually Java install aur configure karna hoga.

---

## 🚀 Quick Setup (Easiest Method)

### Method 1: Android Studio Install Karein (Recommended)
Android Studio install karega to automatically Java bhi install ho jayega:

1. **Download Android Studio:**
   - Link: https://developer.android.com/studio
   - Install karein

2. **Java Path Find Karein:**
   Android Studio install hone ke baad, Java usually yahan hota hai:
   ```
   C:\Program Files\Android\Android Studio\jbr
   ```

3. **Environment Variable Set Karein:**
   - **Windows Key + R** → type `sysdm.cpl` → Enter
   - **Advanced** tab → **Environment Variables**
   - **System variables** mein:
     - **New** click karein:
       - Variable name: `JAVA_HOME`
       - Variable value: `C:\Program Files\Android\Android Studio\jbr`
     - **Path** variable mein **Edit** → **New** → `%JAVA_HOME%\bin` add karein

4. **Terminal Restart Karein**

5. **Verify:**
   ```powershell
   java -version
   ```
   Output mein Java version dikhni chahiye.

---

## 🔧 Method 2: Direct Java Install (Without Android Studio)

### Step 1: Java Download
1. Go to: https://adoptium.net/ (Eclipse Temurin - Free & Open Source)
2. **Java 17 LTS** select karein (Windows x64)
3. Download `.msi` installer

### Step 2: Install Java
1. Downloaded `.msi` file run karein
2. Default settings se install karein
3. Installation path note karein (usually: `C:\Program Files\Eclipse Adoptium\jdk-17.x.x-hotspot`)

### Step 3: Environment Variables Set Karein

**Method A: GUI (Easiest)**
1. **Windows Key + R** → type `sysdm.cpl` → Enter
2. **Advanced** tab → **Environment Variables** button
3. **System variables** section mein:
   - **New** button click karein:
     - **Variable name:** `JAVA_HOME`
     - **Variable value:** `C:\Program Files\Eclipse Adoptium\jdk-17.x.x-hotspot`
     - (Ya jo path aapke installation ka hai)
     - **OK** click karein
   - **Path** variable select karein → **Edit** click karein
   - **New** click karein → `%JAVA_HOME%\bin` type karein
   - **OK** click karein (sab jagah)

**Method B: PowerShell (Advanced)**
```powershell
# Run PowerShell as Administrator
[System.Environment]::SetEnvironmentVariable("JAVA_HOME", "C:\Program Files\Eclipse Adoptium\jdk-17.x.x-hotspot", "Machine")
[System.Environment]::SetEnvironmentVariable("Path", $env:Path + ";%JAVA_HOME%\bin", "Machine")
```

### Step 4: Verify Installation
1. **Terminal/PowerShell restart karein** (important!)
2. Run:
   ```powershell
   java -version
   ```
   Output:
   ```
   openjdk version "17.x.x" ...
   ```

3. Verify JAVA_HOME:
   ```powershell
   $env:JAVA_HOME
   ```
   Ya:
   ```powershell
   echo %JAVA_HOME%
   ```

---

## ✅ SHA-1 Nikaalne Ke Liye Ab Ready

Java setup hone ke baad:

```powershell
cd C:\Users\S\OneDrive\Documents\GitHub\neat-now\flutter\android
.\gradlew.bat signingReport
```

Output mein SHA-1 mil jayega!

---

## 🆘 Troubleshooting

### Problem: `java -version` command not found
**Solution:**
- Environment variables properly set nahi hain
- Terminal restart karein
- Ya Java install hi nahi hua

### Problem: JAVA_HOME set nahi ho raha
**Solution:**
1. System variables mein set karein (User variables nahi)
2. Terminal restart karein
3. Verify: `$env:JAVA_HOME`

### Problem: Path mein JAVA_HOME/bin add nahi ho raha
**Solution:**
- `%JAVA_HOME%\bin` directly add karein
- Ya full path: `C:\Program Files\Eclipse Adoptium\jdk-17.x.x-hotspot\bin`

---

## 📝 Quick Checklist

- [ ] Java download kiya
- [ ] Java install kiya
- [ ] JAVA_HOME environment variable set kiya
- [ ] Path mein `%JAVA_HOME%\bin` add kiya
- [ ] Terminal restart kiya
- [ ] `java -version` verify kiya
- [ ] SHA-1 nikalne ke liye ready ✅

---

## 💡 Alternative: Flutter Web Pe Test Karein (Java Ke Bina)

Agar abhi Android ke liye Java setup nahi karna, to:

1. **Web Client ID se pehle test karein:**
   - Web Client ID already hai
   - `credentials.dart` mein add karein
   - `flutter run -d chrome` se web pe test karein
   - Google Sign-In web pe kaam karega

2. **Android ke liye baad mein:**
   - Java setup karein
   - SHA-1 nikalenge
   - Android Client ID banayenge

---

## 🔗 Useful Links

- **Android Studio:** https://developer.android.com/studio
- **Eclipse Temurin (Java):** https://adoptium.net/
- **Oracle JDK:** https://www.oracle.com/java/technologies/downloads/

