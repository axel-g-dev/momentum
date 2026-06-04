# momentum

**Application iOS de productivité et de motivation personnelle.**

momentum te permet de créer des objectifs, suivre leur progression, maintenir des séries de jours consécutifs (streaks) et recevoir des rappels pour rester discipliné. L'app est conçue avec un design minimaliste et premium inspiré des applications natives Apple.

---

## Fonctionnalités

### Gestion des objectifs
- **Créer** un objectif avec un titre, une description (optionnelle), une date limite, une date de rappel spécifique, et un type de répétition (aucun, quotidien, hebdomadaire).
- **Date & Heure** : Choix simplifié et modulaire façon application Rappels d'Apple (sélection de l'heure optionnelle).
- **Modifier** un objectif existant — titre, description, dates, répétition, et étapes.
- **Archiver / Désarchiver** : Gardez l'historique de vos objectifs sans encombrer la vue principale.
- **Supprimer** un objectif avec confirmation (action irréversible).

### Swipe Actions (Gestes de glissement)
- Glissez vers la **droite** (leading) pour marquer instantanément un objectif comme **"fait aujourd'hui"** ou annuler la complétion du jour (avec vibration haptique).
- Glissez vers la **gauche** (trailing) pour **archiver** ou **supprimer** rapidement un objectif.

### Catégories et Tags
- Classez vos objectifs par catégorie : **Sport 🏃, Travail 💼, Santé 🧘, Perso 🎯** avec des couleurs et icônes SF Symbols dédiées.
- Filtrez instantanément vos objectifs sur la page d'accueil à l'aide d'une **barre de filtres horizontaux** fluide (pills).

### Priorités et Tri Automatique
- Définissez un niveau de priorité (**Haute / Moyenne / Basse**).
- Affichage d'indicateurs de priorité Apple-like (`!`, `!!`, `!!!`) colorés à côté du titre.
- **Tri automatique intelligent** : Les objectifs de haute priorité s'affichent automatiquement en premier sur l'écran d'accueil.

### Templates d'objectifs (Onboarding)
- Lancez-vous instantanément grâce à des modèles pré-remplis populaires ("Lire 30 min/jour", "Méditer", "Faire du sport 3x/semaine", "Deep Work") affichés de façon interactive dans l'état vide et disponibles à la création d'objectifs.

### Sous-objectifs (Structure hiérarchique)
- Créez des **sous-objectifs récursifs** au lieu de simples étapes textuelles.
- Chaque objectif peut avoir ses propres sous-objectifs, ouvrant un lien de navigation vers leur propre fiche de détail.
- **Calcul de progression intelligent** : La progression du parent est la moyenne combinée de ses étapes et de la progression de ses sous-objectifs.

### Étapes (checklist)
- Chaque objectif ou sous-objectif peut contenir des **sous-étapes** dynamiques.
- Animations fluides des barres et cercles de progression.

### Streaks (séries)
- Un **streak** compte le nombre de jours consécutifs où un objectif a été marqué comme "fait".
- Un badge flamme s'affiche à côté des objectifs ayant un streak actif.
- Si un jour est manqué, le streak repart à zéro.

### Statistiques (Dashboard)
Le tableau de bord affiche 4 indicateurs clés colorés distinctement (Orange, Vert, Jaune, Bleu) :
- **Objectifs actifs**, **Objectifs terminés**, **Meilleure série**, et **Progression globale** (basés uniquement sur les objectifs de premier niveau).
- Liste des objectifs actifs cliquables avec un **mini-cercle de progression** pour chacun.

### Notifications locales et Temps Réel
- Rappels quotidiens configurables et rappels spécifiques par objectif.
- Messages contextuels motivants basés sur vos streaks.
- **Notifications au premier plan** : Conformation à `UNUserNotificationCenterDelegate` pour afficher des bannières de notifications animées avec son même si l'application est activement ouverte.
- Utilise `UNUserNotificationCenter` (100% locales, aucun serveur).

### Localisation
- L'application est **entièrement traduite en français et en anglais**.

### Design & Expérience (UX)
- **Vibrations Haptiques** : Retours tangibles et premium (succès, sélection, suppression) via `HapticManager`.
- **Typographie & Couleurs** : Utilisation exclusive du System Blue d'Apple et police San Francisco pour une intégration parfaite.

---

## Écrans de l'application

| # | Écran | Description |
|---|-------|-------------|
| 1 | **Statistiques** | Dashboard avec 4 cartes de stats colorées et liste détaillée des objectifs actifs. |
| 2 | **Accueil** | Liste de tous les objectifs filtrables par statut (Actifs / Terminés / Archivés) et catégorie, avec swipe actions et barre de recherche. |
| 3 | **Détail objectif** | Vue complète d'un objectif, badges de détails, progression, sous-objectifs reliés, et checklist d'étapes. |
| 4 | **Formulaire** | Interface fluide de création ou édition, sélecteurs de catégorie, priorité et dates. |
| 5 | **Réglages** | Préférences utilisateur, horaires de notifications. |

La navigation se fait via une **barre d'onglets (Tab Bar)** avec l'onglet "Accueil" au centre, encadré par "Stats" et "Réglages".

---

## Architecture technique

### Stack
- **SwiftUI** — Interface utilisateur déclarative
- **SwiftData** — Stockage local persistant (optimisé O(1) rendering)
- **MVVM** — Architecture Model-View-ViewModel
- **iOS 18+** — Deployment target

### Structure du projet
```
momentum/
├── momentumApp.swift              ← Point d'entrée de l'app (SwiftData Container Model et Notification Delegate)
├── Localizable.xcstrings          ← Traductions FR / EN
├── Models/
│   ├── Goal.swift                 ← Modèle principal avec relations sous-objectifs
│   ├── GoalStep.swift
│   ├── GoalHistory.swift
│   ├── GoalCategory.swift         ← Nouveau : Sport, Travail, Santé, Perso
│   ├── GoalPriority.swift         ← Nouveau : Basse, Moyenne, Haute
│   └── GoalTemplate.swift         ← Nouveau : Modèles pré-remplis
├── ViewModels/
│   └── Listes, Détails, Formulaires, Stats et Réglages
├── Views/
│   ├── MainTabView.swift          ← Barre d'onglets
│   └── (Sous-dossiers Home, Detail, Form, Stats, Settings)
├── Services/
│   └── NotificationService.swift  ← Notifications locales iOS (Bannières foreground)
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
- **iOS 18+** (iPhone ou simulateur)

1. Cloner le dépôt : `git clone https://github.com/axel-g-dev/momentum.git`
2. Ouvrir `momentum.xcodeproj` dans Xcode.
3. Sélectionner la **Development Team** dans Signing & Capabilities.
4. Appuyer sur **⌘R** pour lancer l'application.

---

## Version

- **Version actuelle** : 1.0.4
- **Deployment target** : iOS 18.0
- **Développeur** : axel'
- **Langues** : Anglais, Français
