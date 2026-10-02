# ka-kā-ki (का-का-की)

A real-time multiplayer shape-sequence game for Android built with **Flutter** and **Firebase Realtime Database**. 2–6 players connect using short 5-character room codes to compete on a 3×3 grid.

---

## Game Rules Summary

- **Board:** 3×3 grid with 9 cells.
- **Turn Time:** 30 seconds per turn. If a player runs out of time, their turn is automatically skipped.
- **Single Action per Turn:**
  1. **Place:** Tap an empty cell to place a new **Square** (■).
  2. **Flip:** Tap an occupied cell to evolve it: **Square (■) → Pentagon (⬟) → Circle (●)**. Circles cannot be flipped further.
  3. **Move:** Swipe an existing piece orthogonally (Up/Down/Left/Right) into an adjacent empty space.
- **Full Board Rule:** When all 9 cells are occupied, movement is disabled. Only eligible flips remain legal.
- **Sequences & Scoring:** Form 3 identical shapes along any row, column, or diagonal (8 lines total). Each **newly formed** sequence scores **+1 point**. Multiple sequences created in a single move grant multiple points. Destroying a line never reduces score.
- **Game End:** Ends when no legal actions remain for any player. Player(s) with the highest score win.

---

## Architecture & Code Structure

The project strictly separates pure Dart domain rules from Flutter UI presentation and Firebase data synchronization:

```
ka_ka_ki/
├── lib/
│   ├── app/
│   │   ├── app.dart                   # Root MaterialApp with theme & routing
│   │   ├── routes.dart                # Type-safe named routes & arguments
│   │   └── theme.dart                 # Playful visual theme (colors, fonts, buttons)
│   ├── core/
│   │   ├── constants/game_constants.dart # Board dimensions, limits, timers
│   │   ├── errors/game_error.dart     # Typed domain exceptions
│   │   └── utils/room_code_generator.dart # 5-char unambiguous room code generator
│   ├── features/
│   │   ├── game/
│   │   │   ├── domain/
│   │   │   │   ├── models/            # Board, PieceShape, Position, GameAction, Player, GameState
│   │   │   │   └── services/          # Pure logic: MoveValidator, SequenceDetector, ScoreCalculator, GameEndDetector
│   │   │   └── presentation/          # GameScreen, GameProvider
│   │   ├── home/presentation/         # HomeScreen
│   │   ├── how_to_play/presentation/  # HowToPlayScreen
│   │   └── room/
│   │       ├── data/                  # FirebaseRoomService (transactions, presence, turn management)
│   │       ├── domain/models/         # RoomState
│   │       └── presentation/          # CreateRoomScreen, JoinRoomScreen, WaitingRoomScreen
│   └── shared/widgets/
│       ├── board_cell_widget.dart     # Interactive cell with tap/swipe detection
│       └── shape_painter.dart         # CustomPaint shaders for Square, Pentagon, Circle
├── test/
│   ├── game/
│   │   ├── board_test.dart            # Board state, placement, movement, boundary tests
│   │   ├── flip_test.dart             # Shape evolution & flip validation
│   │   ├── game_end_test.dart         # Detection of game completion
│   │   ├── move_validator_test.dart   # Legal action enumeration & constraints
│   │   ├── score_test.dart            # Sequence scoring & idempotency
│   │   └── sequence_test.dart         # All 8 lines across rows, cols, diagonals
│   └── widget_test.dart               # App navigation & launch smoke test
└── database.rules.json                # Firebase Realtime Database security rules
```

---

## Running Tests

All 47 unit and widget tests run offline without Firebase dependencies:

```bash
cd ka_ka_ki
flutter test
```

Static analysis verification:

```bash
flutter analyze
```

---

## Firebase Setup Instructions

1. Go to the [Firebase Console](https://console.firebase.google.com/).
2. Create a new Firebase project (or use an existing one).
3. Add an **Android app** with:
   - **Android package name:** `com.kakaki.ka_ka_ki`
4. Download your generated `google-services.json` file.
5. Place `google-services.json` into:
   ```
   ka_ka_ki/android/app/google-services.json
   ```
6. In the Firebase console, navigate to **Build > Realtime Database** and click **Create Database**.
7. In the **Rules** tab, paste the contents of `ka_ka_ki/database.rules.json` and click **Publish**.

---

## Building the Android APK

To build the release APK for Android (API 21+):

```bash
cd ka_ka_ki
flutter build apk --release
```

The APK will be generated at:
```
ka_ka_ki/build/app/outputs/flutter-apk/app-release.apk
```
