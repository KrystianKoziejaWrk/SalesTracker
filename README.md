# SalesTracker

SalesTracker is an iOS application designed to help sales teams efficiently track their sales, manage customer information, and monitor performance metrics. The app integrates with Google Sheets for seamless data storage and retrieval.

## Features

- **Home Dashboard**: View total revenue and track key performance metrics like "Knocked," "Answered," and "Sold."
- **Sales List**: Browse a list of all sales, with detailed information for each entry.
- **Log Sales**: Add new sales with details like customer name, cost, tip, address, and more.
- **Edit Sales**: Update existing sales entries directly from the app.
- **Settings**: Configure the Google Sheet ID for data synchronization.
- **Location Integration**: Automatically grab customer addresses using device location.
- **Google Sheets Integration**: Sync sales data with a Google Sheet for centralized storage.

## Installation

1. Clone the repository: git clone https://github.com/your-repo/sales-tracker.git

2. Open the `SalesTracker.xcodeproj` file in Xcode.
3. Set up your Firebase project and add the necessary configuration files (`GoogleService-Info.plist`).
4. Run the app on a simulator or a physical device.

## Backend Setup

The app uses Firebase Cloud Functions to interact with Google Sheets. The backend is located in the `functions/` directory. To set it up:

1. Install dependencies: cd functions npm install

2. Deploy the functions: npm run deploy


## Usage

1. Launch the app and navigate to the **Settings** tab.
2. Enter your Google Sheet URL or ID to configure the app.
3. Start logging sales, viewing customer details, and tracking performance metrics.

## Requirements

- iOS 15.0 or later
- Xcode 14.0 or later
- Firebase account with Cloud Functions enabled
- Google Sheets API enabled

## License

This project is licensed under the MIT License. See the LICENSE file for details.
