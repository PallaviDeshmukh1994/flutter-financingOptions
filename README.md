# Flutter Financing Option Application

This simple single-page web application was built using the Flutter framework and Dart. The app fetches configuration details from a remote API and dynamically updates the UI components based on the configuration. Users can interact with the UI elements such as text fields, dropdowns, and sliders to simulate and see the results of their loan application. It also demonstrates using a `DataTable` widget with dynamic row addition and deletion. 

## Features

- Fetches configuration from an external API: Loan Application Config API
- Displays UI components (text fields, dropdowns, sliders) based on the configuration returned from the API.
- Allows users to interact with the components and see the results of their loan application in real-time.
- Displays a list of rows in a `DataTable`.
- Allows deletion of rows dynamically.

## Prerequisites

Before running the project, ensure you have the following installed:
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (Version 3.0.0 or higher)
- [Dart SDK](https://dart.dev/get-dart)
- An editor such as [Visual Studio Code](https://code.visualstudio.com/) or [Android Studio](https://developer.android.com/studio).


## Dependencies

This project uses the following dependencies:
- **Flutter** (core framework)
- **http: ^1.0.0**
- **intl: ^0.18.0**

To install all required dependencies, run:
```bash
flutter pub get

To run the applications
Press the F5 button and select Chrome to run the web page.
