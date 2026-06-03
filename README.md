# Momentum — Guide d'Architecture du Projet

Bienvenue dans le code source de Momentum ! Ce fichier explique comment le projet est structuré et à quoi sert chaque fichier, afin que tu puisses t'y retrouver facilement.

L'application suit une architecture **MVVM** (Model-View-ViewModel) et utilise **SwiftData** pour sauvegarder les données localement sur le téléphone.

---

## 🏗️ Structure Globale

```
momentum/
├── momentumApp.swift          ← Le point d'entrée de l'application
├── Models/                    ← Les données de l'application (SwiftData)
├── ViewModels/                ← La logique métier ("le cerveau" des écrans)
├── Views/                     ← L'interface utilisateur (les écrans SwiftUI)
├── Services/                  ← Les outils externes (ex: Notifications)
└── Extensions/                ← Les raccourcis et thèmes (Couleurs)
```

---

## 🗂️ Détail des Dossiers et Fichiers

### 1. Point d'entrée
- **`momentumApp.swift`** : C'est le tout premier fichier exécuté par l'app. Il configure la base de données (`ModelContainer`) et charge l'écran principal (`MainTabView`).

### 2. Dossier `Models/` (Les données)
Ce dossier contient la structure des données qui sont sauvegardées dans la base de données locale (via SwiftData).
- **`Goal.swift`** : Le modèle principal. Il représente un objectif (titre, description, date limite, progression, streak).
- **`GoalStep.swift`** : Représente une étape (sous-tâche) d'un objectif. Un objectif (`Goal`) peut avoir plusieurs étapes (`GoalStep`).
- **`GoalHistory.swift`** : Sauvegarde un historique chaque fois que l'utilisateur complète un objectif pour un jour donné. Cela permet de calculer les "streaks" (séries de jours).
- **`GoalRepetition.swift`** : Définit si l'objectif se répète (aucun, tous les jours, toutes les semaines).
- **`GoalStatus.swift`** : Définit l'état de l'objectif (actif, terminé, archivé).

### 3. Dossier `ViewModels/` (La logique)
Les ViewModels s'occupent de toute la "réflexion" derrière l'affichage. Ils traitent les données avant de les donner aux vues (écrans).
- **`GoalListViewModel.swift`** : S'occupe de filtrer et trier la liste des objectifs sur l'écran d'accueil (ex: cacher les archives, gérer la barre de recherche).
- **`GoalDetailViewModel.swift`** : S'occupe de cocher/décocher une étape, et de marquer un objectif comme "Fait aujourd'hui".
- **`GoalFormViewModel.swift`** : S'occupe de la validation du formulaire quand tu crées ou modifies un objectif (vérifier que le titre n'est pas vide, ajouter ou supprimer des étapes).
- **`StatsViewModel.swift`** : Calcule les statistiques (combien d'actifs, le meilleur streak, le pourcentage global) pour le dashboard.
- **`SettingsViewModel.swift`** : Gère les préférences de notifications et les sauvegarde dans les réglages du téléphone (`UserDefaults`).

### 4. Dossier `Views/` (L'interface graphique)
Ce sont tous les écrans SwiftUI que l'utilisateur voit et touche.
- **`MainTabView.swift`** : La barre de navigation en bas de l'écran avec les 3 onglets (Accueil, Stats, Réglages).
- **Home (Accueil)**
  - `HomeView.swift` : L'écran d'accueil avec la liste de tous les objectifs.
  - `GoalRowView.swift` : Le design d'une seule "ligne" dans la liste d'accueil (avec la petite barre de progression et la flamme de streak).
- **Detail (Détails de l'objectif)**
  - `GoalDetailView.swift` : L'écran quand on clique sur un objectif (grand cercle de progression, bouton "Fait aujourd'hui").
  - `StepRowView.swift` : La ligne d'une étape (la checkbox que l'on peut cocher).
- **Form (Création / Édition)**
  - `GoalFormView.swift` : Le formulaire pour créer ou modifier un objectif (nom, date, étapes).
- **Stats (Statistiques)**
  - `StatsView.swift` : Le dashboard des statistiques globales.
  - `StatCardView.swift` : Le design d'une "carte" de stat (les carrés avec les chiffres au centre).
- **Settings (Réglages)**
  - `SettingsView.swift` : L'écran des paramètres (Activer/Désactiver le rappel quotidien et choisir l'heure).

### 5. Dossier `Services/` (Les outils)
- **`NotificationService.swift`** : Ce fichier est le seul qui "parle" avec le système iOS pour les notifications. Il demande la permission, planifie les notifications locales quotidiennes, et change le message de la notification en fonction des "streaks" de l'utilisateur.

### 6. Dossier `Extensions/`
- **`Color+Theme.swift`** : Définit toutes les couleurs personnalisées de l'application (ex: `Color.accentGreen`). Cela permet de changer facilement le thème de l'application depuis un seul endroit.

---

## 💡 Comment ça fonctionne ensemble ? (MVVM)
1. **Model** : SwiftData sauvegarde un `Goal` (Objectif).
2. **ViewModel** : Le `GoalListViewModel` lit le `Goal` dans SwiftData et décide s'il doit être affiché selon les filtres.
3. **View** : La vue `HomeView` demande au ViewModel "donne-moi la liste", et la dessine sur l'écran pour l'utilisateur en utilisant le design des couleurs définies dans `Extensions`.
