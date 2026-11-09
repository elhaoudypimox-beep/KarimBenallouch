#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
bash scripts/setup-android.sh >/dev/null
KS=barrages-release.keystore
PASS="${BARRAGES_KS_PASS:?Définissez BARRAGES_KS_PASS (mot de passe du keystore)}"
[ -f $KS ] || keytool -genkeypair -v -keystore $KS -alias barrages -keyalg RSA -keysize 2048 \
  -validity 10000 -storepass "$PASS" -keypass "$PASS" -dname "CN=Barrages, O=Karim Benallouch, C=MA"
cd android && ./gradlew assembleRelease
SDK="${ANDROID_HOME:-$ANDROID_SDK_ROOT}"; BT=$(ls -d $SDK/build-tools/* | sort -V | tail -1)
IN=app/build/outputs/apk/release/app-release-unsigned.apk; OUT=app/build/outputs/apk/release/barrages-release.apk
$BT/zipalign -f -p 4 $IN aligned.apk
$BT/apksigner sign --ks ../$KS --ks-pass pass:"$PASS" --out $OUT aligned.apk
echo "APK signé: $(pwd)/$OUT"
