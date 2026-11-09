COMMENT CONSTRUIRE L'APK (gratuit, avec Claude Code)
======================================================

1. Télécharger Claude Code (desktop) si pas déjà fait :
   https://claude.com/download

2. Ouvrir ce dossier (barrages-capacitor) dans Claude Code.

3. Dans Claude Code, coller ce message tel quel :

   "Installe les dépendances (npm install), ajoute la plateforme
   Android (npx cap add android), synchronise (npx cap sync android),
   puis compile un APK debug (cd android && ./gradlew assembleDebug).
   Si l'Android SDK ou un JDK ne sont pas installés sur ma machine,
   guide-moi pour les installer (gratuit). Donne-moi le chemin final
   du fichier .apk généré."

4. Claude Code va exécuter tout ça pour toi. L'APK final se trouve
   normalement dans :
   android/app/build/outputs/apk/debug/app-debug.apk

5. Copie ce .apk sur ton téléphone et installe-le (autorise
   "Installer des apps inconnues" si Android le demande).

POURQUOI CAPACITOR ET PAS UN "HTML TO APK" EN LIGNE ?
========================================================
- C'est un vrai projet Android natif (gratuit, open-source, fait par
  Google/Ionic), pas un wrapper générique.
- Le sélecteur de fichiers (<input type=file>, photos, pièces jointes)
  fonctionne nativement, sans configuration supplémentaire.
- Firebase fonctionne nativement (l'app tourne sur https://localhost,
  pas sur file://, ce qui évite les erreurs vues précédemment).
- On peut plus tard ajouter facilement les vraies notifications push
  (@capacitor/push-notifications) si besoin.

CE QUI EST DÉJÀ PRÉPARÉ DANS CE DOSSIER
=========================================
- www/index.html   -> l'application (dernière version, avec Firebase)
- www/icon.png      -> le logo KB (512x512)
- capacitor.config.json -> nom de l'app "Barrages", id
  com.karimbenallouch.barrages
- package.json      -> dépendances Capacitor

Si tu veux changer le nom affiché sous l'icône plus tard, c'est le
champ "appName" dans capacitor.config.json. Si tu veux changer l'icône
de l'app (pas juste celle dans le chat), remplace www/icon.png puis
redemande à Claude Code de régénérer les icônes Android
(npx capacitor-assets generate).
