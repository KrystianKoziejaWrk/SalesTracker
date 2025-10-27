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


## How to Use!

1. Launch the app and navigate to the **Settings** tab.
2. Enter your Google Sheet URL or ID to configure the app.
3. Add the service bot here as an editor: 713043310949-compute@developer.gserviceaccount.com
4. Label the first tab of your sheet to "Sales"
5. Start logging sales, viewing customer details, and tracking performance metrics.


## Installation

1. Clone the repository: git clone https://github.com/your-repo/sales-tracker.git

2. Open the `SalesTracker.xcodeproj` file in Xcode.
3. Set up your Firebase project and add the necessary configuration files (`GoogleService-Info.plist`).
4. Run the app on a simulator or a physical device.

## Backend Setup

The app uses Firebase Cloud Functions to interact with Google Sheets. The backend is located in the `functions/` directory. To set it up:

1. Install dependencies: cd functions npm install

2. Deploy the functions: npm run deploy



## Requirements

- iOS 15.0 or later
- Xcode 14.0 or later
- Firebase account with Cloud Functions enabled
- Google Sheets API enabled

## IMPORTANT ⚠️ ⚠️ ⚠️ Security "Concerns"
- Looking at the codebase for more than 3 seconds, you WILL see the secret
  this isn't a problem because the main authentication is through the google sheet link itself, something that is intentionally sent
  to a sales team member. Any api call requires this link and should not be an issue.


## License

This project is licensed under the MIT License. See the LICENSE file for details.


