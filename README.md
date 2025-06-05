# TrongAJTT's Multi Tools

A multi-platform Flutter application providing a collection of useful everyday tools.  
Supports both mobile and desktop/tablet layouts with responsive UI.

## Features

### 1. Text Template Generator
- Create and manage reusable text templates with dynamic fields.
- Features:
  - List, add, edit, and delete templates.
  - Templates support fields: text, large text, number, date, time, datetime.
  - Insert data fields and data loops (repeatable sections) into templates.
  - Preview and fill templates to generate custom documents.
  - Export/import templates as JSON.

### 3. Random Generator Suite
A collection of randomization tools:
- **Password Generator:** Customizable length, includes options for lowercase, uppercase, numbers, and special characters.
- **Number Generator:** Generate random integers or floating-point numbers, with min/max limits and duplicate control.
- **Yes/No Generator:** Simple yes/no randomizer.
- **Coin Flip:** Simulate flipping a coin (heads/tails).
- **Rock-Paper-Scissors:** Randomly select rock, paper, or scissors.
- **Dice Roll:** Roll multiple dice with customizable sides (3, 4, 5, 6, 7, 8, 10, 12, 14, 16, 20, 24, 30, 48, 50, 100).
- **Color Generator:** Generate random colors (HEX6, HEX8).
- **Latin Letter Generator:** Generate random Latin letters of specified length.
- **Playing Card Generator:** Draw random cards from a standard 52-card deck.
- **Date Generator:** Generate random dates within a range, with duplicate control.
- **Time Generator:** Generate random times within a range, with duplicate control.
- **Date & Time Generator:** Generate random date-time values within specified ranges.

## Screenshots

<!-- Add screenshots here if available -->

## Getting Started

1. **Clone the repository:**
   ```sh
   git clone https://github.com/yourusername/my_multi_tools.git
   cd my_multi_tools
   ```

2. **Install dependencies:**
   ```sh
   flutter pub get
   ```

3. **Run the app:**
   ```sh
   flutter run
   ```

## Localization

- Supports English and Vietnamese.
- Easily switch language in the app settings.

## Tech Stack

- Flutter (Material 3)
- State management: setState (simple, local)
- Local storage: shared_preferences
- Video analysis: ffmpeg_kit_flutter, media_info, video_thumbnail

## Contributing

Contributions are welcome! Please open issues or submit pull requests for new features, bug fixes, or improvements.

## License

MIT