# 🛠️ SETPocket

A cross-platform productivity suite providing essential everyday tools in one application. Built with Flutter to deliver consistent user experience across Windows, Android, and other platforms.

## ✨ Features

### 📝 Text Template Generator
- Create and manage reusable text templates with dynamic fields
- Support for variables, conditional logic, and loops
- Template import/export functionality
- Draft auto-save and recovery

### 🔄 Unit Converter Suite
- **💱 Currency Converter**: Real-time exchange rates for 170+ currencies
- **📏 Length**: Metric and imperial units (meters, feet, kilometers, miles, etc.)
- **⚖️ Weight & Mass**: Various units including kilograms, pounds, tons
- **📐 Area**: Square meters, acres, hectares, square feet
- **🥤 Volume**: Liters, gallons, cups, fluid ounces
- **🌡️ Temperature**: Celsius, Fahrenheit, Kelvin
- **⏱️ Time**: Seconds to years conversion
- **🏃 Speed**: km/h, mph, m/s, knots
- **💾 Data Storage**: Bytes to terabytes
- **🔢 Number Systems**: Binary, decimal, hexadecimal, octal

### 🎲 Random Generator Tools
- Password generator with customizable complexity
- Number generators (integers, decimals, ranges)
- Date and time randomization
- Decision makers and gaming tools (dice, cards)
- Color and text generators

### 🧮 Calculator Suite
- Scientific calculator with advanced functions
- Graphing calculator with function plotting
- BMI and health calculators
- Financial calculators (loans, interest)
- Date calculations and discount tools

## 🔧 Tech Stack

### 🏗️ Core Framework
- **Flutter 3.x**: Cross-platform UI framework
- **Dart**: Primary programming language

### 💾 Database & Storage
- **Isar Database**: High-performance local database for data persistence
- **SharedPreferences**: Settings and user preferences storage

### 📚 Key Dependencies
- **fl_chart**: Interactive charts and graphs for data visualization
- **math_expressions**: Mathematical expression parsing and evaluation
- **http**: API communication for currency exchange rates
- **crypto**: Cryptographic functions for password generation
- **intl**: Internationalization and localization support

### 🛠️ Development Tools
- **build_runner**: Code generation for Isar schemas
- **flutter_gen**: Asset and localization code generation
- **flutter_lints**: Code quality and style enforcement

## 💻 Supported Platforms

### 🖥️ Windows
- **Minimum**: Windows 10 (1903) or higher
- **Recommended**: Windows 11
- **Architecture**: x64 (64-bit)
- **RAM**: 4GB minimum, 8GB+ recommended
- **Storage**: 100MB available space

### 📱 Android
- **Minimum**: Android 7.0 (API level 24) or higher
- **Recommended**: Android 10+ for optimal performance
- **Architecture**: ARM64, ARMv7, x86_64
- **RAM**: 2GB minimum, 4GB+ recommended
- **Storage**: 50MB available space

### 🚧 Planned Support
- **🍎 macOS**: macOS 10.14 (Mojave) or higher
- **🐧 Linux**: Ubuntu 18.04+ / Debian 10+ / Fedora 28+
- **📱 iOS**: iOS 12.0 or higher

*Note: Hardware requirements are estimates based on Flutter framework requirements and app functionality. Actual performance may vary depending on device specifications and usage patterns.*

## 🌍 Localization

- 🇺🇸 English
- 🇻🇳 Tiếng Việt

## 🚀 Installation

### 📋 Prerequisites
- Flutter SDK 3.0.0 or higher
- Dart SDK 3.0.0 or higher

### 👨‍💻 Development Setup

1. Clone the repository:
```bash
git clone https://github.com/your-username/setpocket.git
cd setpocket
```

2. Install dependencies:
```bash
flutter pub get
```

3. Generate code:
```bash
dart run build_runner build
```

4. Run the application:
```bash
flutter run
```

### 📦 Building for Production

#### 📱 Android APK
```bash
flutter build apk --release
```

#### 🖥️ Windows
```bash
flutter build windows --release
```

## 📁 Project Structure

```
lib/
├── main.dart                 # Application entry point
├── models/                   # Data models and Isar schemas
├── services/                 # Business logic and data services
├── screens/                  # UI screens and pages
├── widgets/                  # Reusable UI components
├── controllers/              # State management
├── utils/                    # Utility functions and helpers
└── l10n/                     # Localization files
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- All open-source library contributors
- Community feedback and suggestions