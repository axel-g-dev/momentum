# Momentum

**Application iOS de productivité et de motivation personnelle.**

Momentum te permet de créer des objectifs, suivre leur progression, maintenir des séries de jours consécutifs (streaks) et recevoir des rappels quotidiens pour rester discipliné. L'app est conçue avec un design minimaliste inspiré des applications natives Apple.

---

## Fonctionnalités

### Gestion des objectifs
- **Créer** un objectif avec un titre, une description (optionnelle), une date limite, une date de rappel spécifique, et un type de répétition (aucun, quotidien, hebdomadaire).
- **Date & Heure** : Choix simplifié et modulaire façon application Rappels d'Apple (sélection de l'heure optionnelle).
- **Modifier** un objectif existant — titre, description, dates, répétition, et étapes.
- **Archiver / Désarchiver** : Gardez l'historique de vos objectifs sans encombrer la vue principale.
- **Supprimer** un objectif avec confirmation (action irréversible).

### Étapes (checklist)
- Chaque objectif peut contenir des **sous-étapes** dynamiques.
- La **progression est calculée automatiquement** en pourcentage à partir des étapes cochées.
- Animations fluides des barres et cercles de progression.

### Streaks (séries)
- Un **streak** compte le nombre de jours consécutifs où un objectif a été marqué comme "fait".
- Un badge flamme s'affiche à côté des objectifs ayant un streak actif.
- Si un jour est manqué, le streak repart à zéro.

### Statistiques (Dashboard)
Le tableau de bord affiche 4 indicateurs clés colorés distinctement (Orange, Vert, Jaune, Bleu) :
- **Objectifs actifs**, **Objectifs terminés**, **Meilleure série**, et **Progression globale**.
- Liste des objectifs actifs cliquables avec un **mini-cercle de progression** pour chacun.

### Notifications locales
- Rappels quotidiens configurables et rappels spécifiques par objectif.
- Messages contextuels motivants basés sur vos streaks.
- Utilise `UNUserNotificationCenter` (100% locales, aucun serveur).

### Localisation
- L'application est **entièrement traduite en français et en anglais**.

---

## Écrans de l'application

| # | Écran | Description |
|---|-------|-------------|
| 1 | **Statistiques** | Dashboard avec 4 cartes de stats colorées et liste détaillée des objectifs actifs. |
| 2 | **Accueil** | Liste de tous les objectifs avec filtre segmenté (Actifs / Terminés / Archivés) et barre de recherche. |
| 3 | **Détail objectif** | Vue complète d'un objectif, sa progression, son historique et la checklist d'étapes. |
| 4 | **Formulaire** | Interface fluide de création ou édition, avec options de temps façon Apple natives. |
| 5 | **Réglages** | Préférences utilisateur, horaires de notifications. |

La navigation se fait via une **barre d'onglets (Tab Bar)** avec l'onglet "Accueil" au centre, encadré par "Stats" et "Réglages".

---

## Architecture technique

### Stack
- **SwiftUI** — Interface utilisateur déclarative
- **SwiftData** — Stockage local persistant (optimisé O(1) rendering)
- **MVVM** — Architecture Model-View-ViewModel
- **iOS 17+** — Deployment target

### Structure du projet
```
momentum/
├── momentumApp.swift              ← Point d'entrée de l'app (SwiftData Container Model)
├── Localizable.xcstrings          ← Traductions FR / EN
├── Models/
│   └── Goal, GoalStep, GoalHistory, etc.
├── ViewModels/
│   └── Listes, Détails, Formulaires, Stats et Réglages
├── Views/
│   ├── MainTabView.swift          ← Barre d'onglets
│   └── (Sous-dossiers Home, Detail, Form, Stats, Settings)
├── Services/
│   └── NotificationService.swift  ← Notifications locales iOS
└── Extensions/
    └── Color+Theme.swift          ← Couleurs natives (Apple System Blue)
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
| Export de données | Non implémenté |
| Gamification avancée | Limité aux Streaks et pourcentages |

---

## Prérequis et Installation

- **Xcode 15+**
- **iOS 17+** (iPhone ou simulateur)

1. Cloner le dépôt : `git clone https://github.com/axel-g-dev/momentum.git`
2. Ouvrir `momentum.xcodeproj` dans Xcode.
3. Sélectionner la **Development Team** dans Signing & Capabilities.
4. Appuyer sur **⌘R** pour lancer l'application.

---

## Version

- **Version actuelle** : 1.0.4
- **Deployment target** : iOS 17.0
- **Langues** : Anglais, Français
