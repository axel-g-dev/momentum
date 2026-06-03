# Momentum

**Application iOS de productivité et de motivation personnelle.**

Momentum te permet de créer des objectifs, suivre leur progression, maintenir des séries de jours consécutifs (streaks) et recevoir des rappels quotidiens pour rester discipliné. L'app est conçue avec un design minimaliste inspiré des applications Apple.

---

## Fonctionnalités

### Gestion des objectifs
- **Créer** un objectif avec un titre, une description (optionnelle), une date limite (optionnelle avec heure) et un type de répétition (aucun, quotidien, hebdomadaire).
- **Modifier** un objectif existant — titre, description, date limite, répétition, et étapes.
- **Supprimer** un objectif avec confirmation (action irréversible).
- **Archiver** un objectif pour le retirer de la vue active sans le supprimer.
- **Restaurer** un objectif archivé vers l'état actif.

### Étapes (checklist)
- Chaque objectif peut contenir des **sous-étapes** (checklist).
- On peut cocher/décocher une étape pour marquer sa progression.
- La **progression est calculée automatiquement** en pourcentage à partir des étapes cochées.
- Les étapes sont ajoutables et supprimables dynamiquement dans le formulaire de création/édition.

### Streaks (séries)
- Un **streak** compte le nombre de jours consécutifs où un objectif a été marqué comme "fait".
- Le streak est calculé automatiquement à partir de l'historique de complétion quotidienne.
- Un badge flamme s'affiche à côté des objectifs ayant un streak actif.
- Si un jour est manqué, le streak repart à zéro.

### Progression globale
- Le **pourcentage de progression** est affiché sous forme de barre horizontale dans la liste et de cercle dans la page de détail.
- Des **animations visuelles** accompagnent les changements de progression (spring animations).

### Statistiques (Dashboard)
Le tableau de bord affiche 4 indicateurs clés :
- **Objectifs actifs** : nombre d'objectifs en cours.
- **Objectifs terminés** : nombre d'objectifs complétés.
- **Meilleure série** : le plus long streak parmi tous les objectifs.
- **Progression globale** : moyenne de progression de tous les objectifs actifs.
- Une liste des objectifs actifs avec un **mini-cercle de progression** pour chacun.

### Notifications locales
- Rappels quotidiens configurables depuis l'écran des Réglages.
- Choix de l'heure du rappel.
- Messages contextuels :
  - Message neutre si pas de streak : _"Tu avais prévu d'avancer sur tes objectifs aujourd'hui."_
  - Message motivant si streak actif : _"Continue comme ça, tu es sur une belle série !"_
- Utilise `UNUserNotificationCenter` (notifications 100% locales, aucun serveur).

### Localisation (FR / EN)
- L'application est **entièrement traduite en français et en anglais**.
- Le choix de la langue se fait **dans l'app** via Réglages > Préférences > Langue.
- Trois options : Système (suit la langue de l'iPhone), English, Français.
- Le changement est instantané, sans redémarrage de l'app.

---

## Écrans de l'application

| # | Écran | Description |
|---|-------|-------------|
| 1 | **Accueil** | Liste de tous les objectifs avec filtre segmenté (Actifs / Terminés / Archivés), barre de recherche, et bouton "+" pour créer un nouvel objectif. |
| 2 | **Détail objectif** | Affiche le titre, la description, la date limite, le type de répétition, un cercle de progression animé, le streak, la checklist d'étapes cochables, et un bouton "Fait aujourd'hui" pour les objectifs récurrents. |
| 3 | **Formulaire** | Création ou édition d'un objectif : nom, description, toggle de date limite avec sélection de date et heure, choix de répétition, et gestion dynamique des étapes. |
| 4 | **Statistiques** | Dashboard avec 4 cartes de stats (objectifs actifs, terminés, meilleur streak, progression) et liste détaillée des objectifs actifs avec mini-anneaux de progression. |
| 5 | **Réglages** | Choix de la langue, activation/désactivation des notifications, sélection de l'heure du rappel, version de l'app. |

La navigation se fait via une **barre d'onglets (Tab Bar)** en bas de l'écran avec 3 onglets : Accueil, Stats, Réglages.

---

## Architecture technique

### Stack
- **SwiftUI** — Interface utilisateur déclarative
- **SwiftData** — Stockage local persistant (basé sur CoreData)
- **MVVM** — Architecture Model-View-ViewModel
- **UserNotifications** — Notifications locales iOS
- **iOS 17+** — Deployment target

### Structure du projet
```
momentum/
├── momentumApp.swift              ← Point d'entrée de l'app
├── Localizable.xcstrings          ← Traductions FR / EN
├── Models/
│   ├── Goal.swift                 ← Modèle principal (objectif)
│   ├── GoalStep.swift             ← Sous-étape d'un objectif
│   ├── GoalHistory.swift          ← Historique de complétion quotidienne
│   ├── GoalRepetition.swift       ← Enum : aucun / quotidien / hebdomadaire
│   └── GoalStatus.swift           ← Enum : actif / terminé / archivé
├── ViewModels/
│   ├── GoalListViewModel.swift    ← Logique de la liste d'accueil
│   ├── GoalDetailViewModel.swift  ← Logique du détail d'un objectif
│   ├── GoalFormViewModel.swift    ← Logique du formulaire
│   ├── StatsViewModel.swift       ← Calcul des statistiques
│   └── SettingsViewModel.swift    ← Préférences de notifications
├── Views/
│   ├── MainTabView.swift          ← Barre d'onglets
│   ├── Home/
│   │   ├── HomeView.swift         ← Écran d'accueil
│   │   └── GoalRowView.swift      ← Ligne d'un objectif dans la liste
│   ├── Detail/
│   │   ├── GoalDetailView.swift   ← Écran de détail
│   │   └── StepRowView.swift      ← Ligne d'une étape
│   ├── Form/
│   │   └── GoalFormView.swift     ← Formulaire de création/édition
│   ├── Stats/
│   │   ├── StatsView.swift        ← Dashboard des statistiques
│   │   └── StatCardView.swift     ← Carte de statistique
│   └── Settings/
│       └── SettingsView.swift     ← Écran des réglages
├── Services/
│   └── NotificationService.swift  ← Service de notifications locales
└── Extensions/
    └── Color+Theme.swift          ← Palette de couleurs de l'app
```

### Modèles de données (SwiftData)
```
Goal (Objectif)
├── title: String
├── goalDescription: String
├── createdAt: Date
├── deadline: Date? (optionnel, avec heure)
├── repetitionRaw: String → GoalRepetition enum
├── statusRaw: String → GoalStatus enum
├── steps: [GoalStep] (relation cascade)
├── history: [GoalHistory] (relation cascade)
├── progress: Double (calculé automatiquement)
├── currentStreak: Int (calculé automatiquement)
└── isCompletedToday: Bool (calculé automatiquement)

GoalStep (Étape)
├── title: String
├── isCompleted: Bool
└── order: Int

GoalHistory (Historique)
├── date: Date (normalisée au début du jour)
└── completed: Bool
```

---

## Ce que l'app NE fait PAS (hors du scope du MVP)

| Fonctionnalité | Statut |
|---------------|--------|
| Synchronisation iCloud | Préparé dans l'architecture mais **non implémenté** |
| Backend / API | Aucun — tout est local |
| Authentification | Aucune |
| Widgets iOS | Non implémenté |
| Apple Watch | Non implémenté |
| Dark mode personnalisé | Fonctionne via les couleurs système iOS (automatic) |
| Répétition custom (jours spécifiques) | Limité à aucun / quotidien / hebdomadaire |
| Export de données | Non implémenté |
| Gamification avancée (badges, niveaux, XP) | Non — uniquement les streaks |
| Haptic feedback | Non implémenté |
| Onboarding / tutoriel | Non implémenté |
| iPad layout optimisé | Fonctionne mais pas optimisé avec split view |

---

## Prérequis

- **Xcode 15+** (Xcode 26 recommandé)
- **iOS 17+** (iPhone ou simulateur)
- Un compte Apple Developer (gratuit) pour le code signing

## Installation

1. Cloner le dépôt :
   ```bash
   git clone https://github.com/axel-g-dev/momentum.git
   ```
2. Ouvrir `momentum.xcodeproj` dans Xcode.
3. Sélectionner ta **Development Team** dans Signing & Capabilities.
4. Choisir un simulateur iPhone ou un appareil physique.
5. Appuyer sur **⌘R** pour lancer l'application.

---

## Version

- **Version actuelle** : 1.0.1
- **Deployment target** : iOS 17.0
- **Langues** : Anglais, Français
