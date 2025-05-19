#!/data/data/com.termux/files/usr/bin/bash

# Get full call log and sort by date descending
last_log=$(termux-call-log | jq 'sort_by(.date) | reverse | .[0]')

# Extract the correct field: phone_number
number=$(echo "$last_log" | jq -r '.phone_number')

# Print the log for confirmation
echo "Last call log:"
echo "$last_log" | jq

# Call the number if it's valid
if [[ -n "$number" && "$number" != "null" ]]; then
    echo "Calling: $number"
    termux-telephony-call "$number"
else
    echo "No valid phone number found in last log entry."
fi
