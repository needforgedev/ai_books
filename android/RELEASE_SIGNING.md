# Android Release Signing

This document explains how to generate the release keystore that signs Speedread builds before they go to Google Play.

> **Critical:** once you publish on Play, every future update must be signed with the **same** keystore (or with Play App Signing's upload key). If you lose the keystore + passwords, you can't update the app on the same listing — you'd have to start over with a new package name. Back up `upload-keystore.jks` and the passwords somewhere safe (1Password / iCloud Keychain / encrypted vault).

---

## One-time setup

### 1. Generate the keystore

Run this from the project root. Fill in the prompts when asked. Use a strong password (and the same password for both `storePassword` and `keyPassword` to keep things simple).

```bash
keytool -genkey -v \
  -keystore android/app/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload \
  -dname "CN=Speedread, O=Speedread, L=, S=, C=US"
```

When prompted for the password, enter your chosen password twice. (The `-dname` flag pre-fills the certificate fields so you don't have to type them interactively.)

The file `android/app/upload-keystore.jks` is gitignored.

### 2. Create `android/key.properties`

Copy the template and fill in the real values:

```bash
cp android/key.properties.template android/key.properties
```

Then edit `android/key.properties`:

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=upload-keystore.jks
```

`android/key.properties` is gitignored.

### 3. Verify the release build is signed

```bash
flutter build appbundle --release
```

If `android/key.properties` is missing, the build falls back to debug signing (so local dev still works) but Google Play will reject the upload. With `key.properties` present, the AAB is signed with your release keystore.

You can verify the signing certificate of the generated AAB:

```bash
jarsigner -verify -verbose -certs build/app/outputs/bundle/release/app-release.aab
```

You should see your CN (`Speedread`) in the certificate output.

---

## Backing up the keystore

After generating, save **three** things in a password manager or encrypted vault:

1. `upload-keystore.jks` (the binary file — store the file itself, base64-encoded if your vault prefers text)
2. The keystore password (`storePassword`)
3. The key password (`keyPassword`) — if you used the same value as `storePassword`, just note that

Without all three, you cannot publish updates.

---

## Uploading to Play Console

1. In Play Console → your app → **Setup → App signing**, enroll in **Play App Signing**. Google will hold the actual app signing key; your `upload-keystore.jks` becomes the upload key.
2. Build a release AAB:
   ```bash
   flutter build appbundle --release
   ```
3. Upload `build/app/outputs/bundle/release/app-release.aab` to Play Console (Internal testing → Create new release).

---

## Bumping the version

Edit `pubspec.yaml`:

```yaml
version: 1.0.0+1
#       ^^^^^^ versionName    ^ versionCode
```

- `versionName` (the part before `+`) is the user-visible version, e.g. `1.0.0`, `1.0.1`, `1.1.0`.
- `versionCode` (the part after `+`) **must increase every upload to Play** (Google rejects same-or-lower version codes). Bump by 1 each release.

Then rebuild. iOS picks these up automatically too (`CFBundleShortVersionString` and `CFBundleVersion`).

---

## If you need to rotate the keystore

You can't change the upload key on an existing Play listing without going through Google support to "reset" the upload key. If you suspect the keystore is compromised, contact Play support — don't try to publish with a new keystore, the upload will be rejected.
