# Contact Search System

A command-line tool for managing contacts and making calls through Termux.

## Overview

Contact Search System is a Bash script that allows you to manage contacts and initiate phone calls directly from the Termux terminal on Android. The application provides a user-friendly interface with color-coded output for enhanced usability.

## Prerequisites

- [Termux](https://termux.com/) installed on your Android device
- The following package installed in Termux:
  - `jq` (for JSON processing)
- Termux API with telephony permissions enabled on your device

## Installation

```bash
git clone https://github.com/pejmanmorovat/Contact.git
```

1. Save the script to a file (e.g., `contact-search.sh`)
2. Make it executable:
   ```bash
   chmod +x contact-search.sh
   ```
3. The script will automatically create an empty `contacts.txt` file on first run, or you can create one with your contacts in JSON format:
   ```json
   [
     {"name": "John Doe", "number": "+1234567890"},
     {"name": "Jane Smith", "number": "9876543210"}
   ]
   ```

## Features

- **Search Contacts**: Find contacts by name (case-insensitive)
- **List All Contacts**: View all saved contacts
- **Add New Contacts**: Add contacts to your phonebook
- **Make Calls**: Call contacts directly from search results
- **Direct Calling**: Enter phone numbers directly to make calls
- **Clean Interface**: Color-coded terminal UI for better readability

## Usage

Run the script from Termux:

```bash
./contact-search.sh
```

### Main Menu Options

1. **Search contacts**: Search for contacts by name and call them
2. **List all contacts**: Display all saved contacts
3. **Add new contact**: Save a new contact to your phonebook
4. **Exit**: Quit the application

### Contact Management

The contacts are stored in a file named `contacts.txt` in JSON format. Each entry has the following structure:

```json
{"name": "Contact Name", "number": "Phone Number"}
```

### Making Calls

After searching for a contact:
- Select a contact by entering their number in the results list
- Or directly paste/type a phone number to call

## Troubleshooting

- If you see "Error: jq is not installed", run:
  ```bash
  pkg install jq
  ```

- Make sure you've granted call permissions to Termux on your Android device

- If calls aren't working, ensure Termux API is properly installed:
  ```bash
  pkg install termux-api
  ```

## Notes

- Phone numbers are automatically cleaned of non-numeric characters (except the + symbol)
- The script requires a valid JSON file for contacts
- New contacts are immediately saved to the contacts.txt file
