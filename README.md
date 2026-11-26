# 🇧🇪 Belgique

<p align="center">
  <strong>DÉCOUVREZ LA BELGIQUE, VILLE APRÈS VILLE.</strong><br>
  Des places historiques aux ruelles médiévales, explorez cinq villes et leurs lieux incontournables.
</p>

<p align="center">
  <a href="https://coco921609.github.io/Belgique/"><strong>Découvrir l’application Web</strong></a>
  &nbsp;·&nbsp;
  <a href="https://github.com/Coco921609/Belgique"><strong>Code source</strong></a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-Dart-5B8DEF?style=flat-square&logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Langues-FR%20%7C%20EN-9B835B?style=flat-square" alt="Français et anglais">
  <img src="https://img.shields.io/badge/Découverte-5%20villes-263238?style=flat-square" alt="Cinq villes">
</p>

---

## ✦ L’esprit Belgique

**Belgique** est une application Flutter consacrée à la découverte de cinq villes belges : Bruxelles, Gand, Bruges, Anvers et Liège.

L’écran d’ouverture propose de choisir entre le français et l’anglais. L’application mène ensuite vers une interface immersive qui présente les villes, leurs quartiers et leurs lieux de découverte.

## ✦ Cinq villes à découvrir

| VILLE | UNIVERS |
|:--|:--|
| 🏛️ **Bruxelles** | La capitale, ses quartiers et son patrimoine |
| 🏰 **Gand** | Une ville historique et ses monuments |
| 🚲 **Bruges** | Les canaux, le centre médiéval et les lieux emblématiques |
| 💎 **Anvers** | Le patrimoine, l’architecture et les lieux incontournables |
| 🌿 **Liège** | La Cité ardente, ses quartiers et ses monuments |

## ✦ Le parcours de l’application

<p align="center">
  <strong>8 CAPTURES · FORMAT MOBILE · FRANÇAIS & ENGLISH</strong><br>
  <em>Du choix de la langue aux pages des cinq villes.</em>
</p>

<p align="center"><em>Captures réalisées depuis les écrans Flutter · 430 × 932 px</em></p>

<table>
<tr><td align="center"><strong>01 — Choix de la langue</strong><br><a href="docs/screenshots/01-choix-langue.png"><img src="docs/screenshots/01-choix-langue.png" alt="01 — Choix de la langue" width="220"></a></td><td align="center"><strong>02 — Accueil français</strong><br><a href="docs/screenshots/02-accueil-francais.png"><img src="docs/screenshots/02-accueil-francais.png" alt="02 — Accueil français" width="220"></a></td></tr>
<tr><td align="center"><strong>03 — Home English</strong><br><a href="docs/screenshots/03-home-english.png"><img src="docs/screenshots/03-home-english.png" alt="03 — Home English" width="220"></a></td><td align="center"><strong>04 — Bruxelles</strong><br><a href="docs/screenshots/04-bruxelles.png"><img src="docs/screenshots/04-bruxelles.png" alt="04 — Bruxelles" width="220"></a></td></tr>
<tr><td align="center"><strong>05 — Gand</strong><br><a href="docs/screenshots/05-gand.png"><img src="docs/screenshots/05-gand.png" alt="05 — Gand" width="220"></a></td><td align="center"><strong>06 — Bruges</strong><br><a href="docs/screenshots/06-bruges.png"><img src="docs/screenshots/06-bruges.png" alt="06 — Bruges" width="220"></a></td></tr>
<tr><td align="center"><strong>07 — Anvers</strong><br><a href="docs/screenshots/07-anvers.png"><img src="docs/screenshots/07-anvers.png" alt="07 — Anvers" width="220"></a></td><td align="center"><strong>08 — Liège</strong><br><a href="docs/screenshots/08-liege.png"><img src="docs/screenshots/08-liege.png" alt="08 — Liège" width="220"></a></td></tr>
</table>

<sub>Cliquez sur une image pour consulter la capture originale. Les deux écrans d’accueil montrent les versions française et anglaise.</sub>

## ✦ Fonctionnalités

- Choix de la langue : français ou anglais.
- Accueil présentant cinq villes belges.
- Pages détaillées consacrées à Bruxelles, Gand, Bruges, Anvers et Liège.
- Gestion des favoris.
- Outils de découverte et de sélection aléatoire de ville.
- Navigation dans les quartiers et les lieux présentés.

## ✦ Technologies

| TECHNOLOGIE | UTILISATION |
|:--|:--|
| **Flutter / Dart** | Application multiplateforme |
| **Google Fonts** | Typographie |
| **Shared Preferences** | Préférences et favoris |
| **URL Launcher** | Ouverture de liens externes |
| **GitHub Actions** | Déploiement Web et captures automatisées |
| **Playwright / Chromium** | Captures des écrans Flutter |

## ✦ Mise à jour automatique des captures

Le workflow GitHub Actions utilise `tool/screenshot_harness.dart` pour ouvrir les widgets Flutter dans Chromium et capturer les écrans au format mobile **430 × 932 px**. Il vérifie la présence des huit captures et contrôle qu’elles sont distinctes avant de les enregistrer dans `docs/screenshots/`.

Le workflow se lance sur les mises à jour de la branche `main` ou manuellement depuis l’onglet **Actions**. Les captures montrent le rendu Web mobile de l’application Flutter.

## ✦ Installer le projet

Prérequis : Flutter installé et configuré.

```bash
git clone https://github.com/Coco921609/Belgique.git
cd Belgique
flutter pub get
flutter run
```

Pour générer la version Web :

```bash
flutter build web --release --base-href "/Belgique/"
```

## ✦ Retrouver Belgique

- **Application Web :** [Ouvrir Belgique](https://coco921609.github.io/Belgique/)
- **Dépôt GitHub :** [Coco921609/Belgique](https://github.com/Coco921609/Belgique)
- **Documentation Flutter :** [docs.flutter.dev](https://docs.flutter.dev/)

---

<p align="center">
  <strong>BELGIQUE</strong><br>
  <em>Cinq villes, mille découvertes.</em>
</p>



## ✦ Ouvrir ce projet Flutter dans Android Studio — Windows, macOS et Linux

Ce guide explique comment récupérer **Belgique**, installer les dépendances et lancer l’application depuis Android Studio.

### 1. Installer les outils nécessaires

Installez les outils correspondant à votre système :

- **Flutter SDK :** [Installation officielle de Flutter](https://docs.flutter.dev/get-started/install)
- **Android Studio :** [Télécharger Android Studio](https://developer.android.com/studio)
- **Git :** [Télécharger Git](https://git-scm.com/downloads)

Dans Android Studio, ouvrez **Settings / Preferences → Plugins** et vérifiez que les plugins **Flutter** et **Dart** sont installés. Suivez les instructions du plugin Flutter si Android Studio vous demande d’installer le SDK Flutter.

### 2. Télécharger le projet

Ouvrez un terminal (PowerShell sous Windows, Terminal sous macOS ou Linux), puis exécutez :

```bash
git clone https://github.com/Coco921609/Belgique.git
cd Belgique
```

Le dossier `Belgique` contient le fichier `pubspec.yaml` : c’est ce dossier qu’il faudra ouvrir dans Android Studio.

### 3. Configuration sous Windows

1. Installez Flutter et Git avec les liens ci-dessus.
2. Ajoutez le dossier `flutter/bin` au **PATH** de Windows si l’installateur ne l’a pas fait.
3. Installez Android Studio, puis ouvrez **SDK Manager** pour installer le SDK Android et les outils de plateforme nécessaires.
4. Ouvrez **PowerShell** et vérifiez l’installation :

```powershell
flutter doctor
```

5. Dans Android Studio, cliquez sur **Open**, sélectionnez le dossier `Belgique`, puis validez.
6. Ouvrez le terminal intégré d’Android Studio et exécutez :

```bash
flutter pub get
flutter devices
flutter run
```

### 4. Configuration sous macOS (Android et iOS)

1. Installez Flutter, Git et Android Studio.
2. Pour compiler ou lancer l’application sur iPhone/iPad, installez **Xcode** depuis le Mac App Store.
3. Initialisez les outils Xcode dans Terminal :

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

4. Vérifiez la configuration :

```bash
flutter doctor
```

5. Clonez le dépôt (étape 2), puis ouvrez le projet dans Android Studio :

```bash
open -a "Android Studio" .
```

6. Dans le terminal d’Android Studio, récupérez les dépendances et lancez l’application :

```bash
flutter pub get
flutter devices
flutter run
```

Pour iOS, sélectionnez un simulateur iPhone dans Xcode ou connectez un iPhone configuré pour le développement. Acceptez les éventuelles demandes de confiance et de signature de Xcode.

### 5. Configuration sous Linux

1. Installez Git et Flutter en suivant le [guide Flutter pour Linux](https://docs.flutter.dev/get-started/install/linux).
2. Installez Android Studio et les outils Android SDK depuis **SDK Manager**.
3. Vérifiez la configuration dans un terminal :

```bash
flutter doctor
```

4. Clonez le dépôt (étape 2), puis ouvrez le dossier du projet dans Android Studio. Si la commande est disponible :

```bash
studio .
```

Sinon, lancez Android Studio depuis le menu des applications, cliquez sur **Open** et choisissez le dossier `Belgique`.

5. Dans le terminal intégré, exécutez :

```bash
flutter pub get
flutter devices
flutter run
```

### 6. Vérifier et lancer le projet

Dans Android Studio :

1. Attendez la fin de l’indexation du projet.
2. Vérifiez que le fichier `pubspec.yaml` est bien à la racine du projet ouvert.
3. Sélectionnez un émulateur ou un appareil connecté dans la liste des appareils.
4. Cliquez sur **Run ▶** ou lancez `flutter run` dans le terminal.

Si Flutter signale un problème de configuration, relancez `flutter doctor` et suivez les indications affichées.

> **Important pour iOS :** la compilation et l’exécution sur simulateur ou appareil iOS nécessitent un Mac avec Xcode. Elles ne peuvent pas être réalisées directement depuis Windows ou Linux.

### 7. Liens de l’application

- **Android :** [Télécharger Belgique sur Google Play](https://play.google.com/store/apps/details?id=com.belgique.belgique)
- **iOS / Web :** [Ouvrir Belgique](https://coco921609.github.io/Belgique/)
- **Code source :** [Coco921609/Belgique](https://github.com/Coco921609/Belgique)
- **Documentation Flutter :** [docs.flutter.dev](https://docs.flutter.dev/)
