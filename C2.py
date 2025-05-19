import subprocess
import json
from datetime import datetime

# Terminal color codes
GREEN = '\033[92m'
YELLOW = '\033[93m'
CYAN = '\033[96m'
RED = '\033[91m'
BOLD = '\033[1m'
RESET = '\033[0m'

def get_call_log():
    result = subprocess.run(["termux-call-log"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    if result.returncode != 0:
        print(RED + "Error getting call log:" + RESET, result.stderr.decode())
        return []
    try:
        logs = json.loads(result.stdout.decode())
        valid_logs = [log for log in logs if log.get("phone_number")]
        return valid_logs[:10]
    except json.JSONDecodeError:
        print(RED + "Failed to parse call log." + RESET)
        return []

def display_logs(logs):
    print(BOLD + "\nRecent Call Logs" + RESET)
    print("=" * 60)
    print(f"{BOLD} No.  Type      Name                     Number            Date{RESET}")
    print("-" * 60)
    for i, log in enumerate(logs, start=1):
        name = log.get("name", "").strip() or "Unknown"
        name = name[:23].ljust(23)
        number = log.get("phone_number", "Unknown")
        type_ = log.get("type", "unknown").capitalize().ljust(9)
        date = log.get("date", "N/A")
        print(f" {str(i).rjust(2)}   {type_}  {YELLOW}{name}{RESET}  {CYAN}{number:<16}{RESET}  {date}")
    print("=" * 60)

def call_number(number):
    print(GREEN + f"\nCalling {number}..." + RESET)
    subprocess.run(["termux-telephony-call", str(number)])

def main():
    logs = get_call_log()
    if not logs:
        print(RED + "No valid call logs with numbers available." + RESET)
        return

    display_logs(logs)

    try:
        choice = int(input(BOLD + "Enter the number of the contact to call (1-10): " + RESET))
        if 1 <= choice <= len(logs):
            number = logs[choice - 1].get("phone_number")
            call_number(number)
        else:
            print(RED + "Invalid choice. Please choose a number from the list." + RESET)
    except ValueError:
        print(RED + "Please enter a valid number." + RESET)

if __name__ == "__main__":
    main()
