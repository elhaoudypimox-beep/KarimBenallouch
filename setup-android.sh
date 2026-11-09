#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
npm install
[ -d android ] || npx cap add android
PKG=com.karimbenallouch.barrages
MAN=android/app/src/main/AndroidManifest.xml
python3 - "$MAN" <<'PY'
import sys,re
p=sys.argv[1]; s=open(p,encoding='utf-8').read()
perms=['INTERNET','ACCESS_NETWORK_STATE','CAMERA','RECORD_AUDIO','MODIFY_AUDIO_SETTINGS',
 'READ_MEDIA_IMAGES','READ_MEDIA_VIDEO','READ_MEDIA_AUDIO']
lines=''.join(f'    <uses-permission android:name="android.permission.{x}" />\n' for x in perms
  if f'android.permission.{x}"' not in s)
lines+='    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32" />\n' if 'READ_EXTERNAL_STORAGE' not in s else ''
feat=''.join(f'    <uses-feature android:name="{x}" android:required="false" />\n' for x in
  ['android.hardware.camera','android.hardware.camera.autofocus','android.hardware.microphone'] if x not in s)
s=s.replace('</manifest>',lines+feat+'</manifest>')
act=re.search(r'<activity[^>]*>',s).group(0)
new=act
for k,v in [('android:windowSoftInputMode','adjustResize'),('android:screenOrientation','fullUser'),
            ('android:resizeableActivity','true')]:
    if k not in new: new=new[:-1]+f' {k}="{v}">'
s=s.replace(act,new)
open(p,'w',encoding='utf-8').write(s)
PY
# immersive + cutout MainActivity
DIR=android/app/src/main/java/${PKG//.//}
mkdir -p "$DIR"
cat > "$DIR/MainActivity.java" <<JAVA
package $PKG;

import android.os.Build;
import android.os.Bundle;
import android.view.WindowManager;
import androidx.core.view.WindowCompat;
import androidx.core.view.WindowInsetsControllerCompat;
import androidx.core.view.WindowInsetsCompat;
import com.getcapacitor.BridgeActivity;

public class MainActivity extends BridgeActivity {
  @Override
  public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    if (Build.VERSION.SDK_INT >= 28) {
      getWindow().getAttributes().layoutInDisplayCutoutMode =
        WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES;
    }
    hideSystemBars();
  }
  @Override
  public void onWindowFocusChanged(boolean hasFocus) {
    super.onWindowFocusChanged(hasFocus);
    if (hasFocus) hideSystemBars(); // re-hide after bars were swiped in / dialogs
  }
  private void hideSystemBars() {
    WindowInsetsControllerCompat c =
      WindowCompat.getInsetsController(getWindow(), getWindow().getDecorView());
    c.setSystemBarsBehavior(WindowInsetsControllerCompat.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE);
    c.hide(WindowInsetsCompat.Type.systemBars());
  }
}
JAVA
npx cap sync android
cd android && chmod +x gradlew && ./gradlew assembleDebug
echo "APK: $(pwd)/app/build/outputs/apk/debug/app-debug.apk"
