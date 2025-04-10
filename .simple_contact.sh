#!/bin/bash

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "Error: jq is not installed. Install it with 'pkg install jq'"
    exit 1
fi

# Load contacts
load_contacts() {
    if [ ! -f "contacts.txt" ]; then
        echo "[]" > contacts.txt
    fi
    
    if ! jq empty contacts.txt &> /dev/null; then
        echo "Error: contacts.txt is not valid JSON"
        return 1
    fi
    
    contacts=$(cat contacts.txt)
    echo "$contacts"
}

# Search contacts
search_contacts() {
    local query="$1"
    local results=$(echo "$contacts" | jq -c --arg query "$query" '
        [.[] | select(.name | test($query; "i"))]
    ')
    echo "$results"
}

# Clean phone number
clean_phone_number() {
    echo "$1" | sed -E 's/[^0-9+]//g'
}

# Main function
main() {
    contacts=$(load_contacts) || exit 1
    
    read -p "Enter name to search: " query
    results=$(search_contacts "$query")
    count=$(echo "$results" | jq length)
    
    if [ "$count" -eq 0 ]; then
        echo "No contacts found."
        exit 0
    fi
    
    echo ""
    echo "$results" | jq -r '.[] | "\(.name): \(.number)"' | nl -w 2 -s ". "
    
    while true; do
        echo ""
        read -p "Enter number (1, 2, etc.) to call, or phone number directly (0 to cancel): " selection
        
        if [ "$selection" == "0" ]; then
            exit 0
        fi
        
        if [[ "$selection" =~ [0-9+]{5,} ]]; then
            cleaned=$(clean_phone_number "$selection")
            echo "Calling $cleaned..."
            termux-telephony-call "$cleaned"
            sleep 2
            exit 0
        elif [[ "$selection" =~ ^[0-9]+$ ]]; then
            index=$((selection - 1))
            if [ "$index" -ge 0 ] && [ "$index" -lt "$count" ]; then
                number=$(echo "$results" | jq -r ".[$index].number")
                cleaned=$(clean_phone_number "$number")
                name=$(echo "$results" | jq -r ".[$index].name")
                echo "Calling $name ($cleaned)..."
                termux-telephony-call "$cleaned"
                sleep 2
                exit 0
            else
                echo "Invalid selection number."
            fi
        else
            echo "Invalid input."
        fi
    done
}

# Run the program
main
