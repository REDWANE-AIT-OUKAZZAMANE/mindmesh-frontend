# MindMesh Frontend

This is the frontend application for MindMesh, built with Flutter.

## Features

- Modern and responsive user interface
- Real-time chat functionality
- User authentication and authorization
- Profile management
- Interactive mind mapping visualization
- Cross-platform support (iOS and Android)

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Android Studio / Xcode (for platform-specific development)
- Git

### Installation

1. Clone the repository:
```bash
git clone https://github.com/REDWANE-AIT-OUKAZZAMANE/mindmesh-frontend.git
```

2. Install dependencies:
```bash
flutter pub get
```

3. Create a `.env` file in the root directory and add the following environment variables:
```
API_URL=http://localhost:8080
```

4. Run the application:
```bash
flutter run
```

The application will be available on your connected device or emulator.

## Project Structure

- `/lib` - Main application code
  - `/services` - API and service classes
  - `/screens` - UI screens
  - `/widgets` - Reusable widgets
  - `/models` - Data models
  - `/utils` - Utility functions
- `/android` - Android-specific code
- `/ios` - iOS-specific code
- `/assets` - Images, fonts, and other static assets

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
