#!/bin/bash

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo -e "${RED}Error: jq is not installed. Install it with 'pkg install jq'${NC}"
    exit 1
fi

# Load contacts
load_contacts() {
    if [ ! -f "contacts.txt" ]; then
        echo "[]" > contacts.txt  # Create empty JSON array if file doesn't exist
    fi
    
    if ! jq empty contacts.txt &> /dev/null; then
        echo -e "${RED}Error: contacts.txt is not valid JSON${NC}"
        return 1
    fi
    
    contacts=$(cat contacts.txt)
    echo "$contacts"
}

# Save new contact
save_contact() {
    local name="$1"
    local number="$2"
    
    # Clean the number
    number=$(clean_phone_number "$number")
    
    # Add to contacts
    contacts=$(echo "$contacts" | jq --arg name "$name" --arg number "$number" \
        '. += [{"name": $name, "number": $number}]')
    
    # Save to file
    echo "$contacts" > contacts.txt
    echo -e "${GREEN}Contact saved successfully!${NC}"
    
    # Show the saved contact
    echo -e "\n${YELLOW}Saved Contact:${NC}"
    echo -e "${BLUE}$name: $number${NC}"
}

# Search contacts
search_contacts() {
    local query="$1"
    local results=$(echo "$contacts" | jq -c --arg query "$query" '
        [.[] | select(.name | test($query; "i"))]
    ')
    echo "$results"
}

# List all contacts
list_all_contacts() {
    local total=$(echo "$contacts" | jq length)
    echo -e "${GREEN}All Contacts (Total: $total):${NC}"
    
    echo "$contacts" | jq -r '.[] | "\(.name): \(.number)"' | nl -w 2 -s ". " | while read line; do
        echo -e "${BLUE}${line}${NC}"
    done
}

# Clean phone number
clean_phone_number() {
    echo "$1" | sed -E 's/[^0-9+]//g'
}

# Main menu
main_menu() {
    while true; do
        clear
        echo -e "${BLUE}╔════════════════════════════╗${NC}"
        echo -e "${BLUE}║    Contact Search System   ║${NC}"
        echo -e "${BLUE}║    Programmer >- Pejman    ║${NC}"
        echo -e "${BLUE}╚════════════════════════════╝${NC}"
        echo -e "${GREEN}1. Search contacts${NC}"
        echo -e "${GREEN}2. List all contacts${NC}"
        echo -e "${GREEN}3. Add new contact${NC}"
        echo -e "${GREEN}4. Exit${NC}"
        echo -e "${YELLOW}────────────────────────────${NC}"
        read -p "Enter your choice (1-4): " choice
        
        case $choice in
            1)
                echo -e "\n${YELLOW}Search Contacts${NC}"
                read -p "Enter name to search: " query
                results=$(search_contacts "$query")
                count=$(echo "$results" | jq length)
                
                if [ "$count" -eq 0 ]; then
                    echo -e "${RED}No contacts found.${NC}"
                    read -p "Press Enter to continue..."
                    continue
                fi
                
                echo -e "\n${GREEN}Search Results:${NC}"
                echo "$results" | jq -r '.[] | "\(.name): \(.number)"' | nl -w 2 -s ". " | while read line; do
                    echo -e "${BLUE}${line}${NC}"
                done
                
                while true; do
                    echo -e "${YELLOW}────────────────────────────${NC}"
                    read -p $'Enter the number (1, 2, etc.) to call,\nor paste a phone number directly (0 to cancel): ' selection
                    
                    if [ "$selection" == "0" ]; then
                        break
                    fi
                    
                    if [[ "$selection" =~ [0-9+]{5,} ]]; then
                        cleaned=$(clean_phone_number "$selection")
                        echo -e "${GREEN}Calling $cleaned...${NC}"
                        termux-telephony-call "$cleaned"
                        sleep 2
                        break
                    elif [[ "$selection" =~ ^[0-9]+$ ]]; then
                        index=$((selection - 1))
                        if [ "$index" -ge 0 ] && [ "$index" -lt "$count" ]; then
                            number=$(echo "$results" | jq -r ".[$index].number")
                            cleaned=$(clean_phone_number "$number")
                            name=$(echo "$results" | jq -r ".[$index].name")
                            echo -e "${GREEN}Calling $name ($cleaned)...${NC}"
                            termux-telephony-call "$cleaned"
                            sleep 2
                            break
                        else
                            echo -e "${RED}Invalid selection number. Please try again.${NC}"
                        fi
                    else
                        echo -e "${RED}Invalid input. Please enter a selection number or phone number.${NC}"
                    fi
                done
                ;;
            2)
                list_all_contacts
                read -p "Press Enter to continue..."
                ;;
            3)
                echo -e "\n${YELLOW}Add New Contact${NC}"
                read -p "Enter contact name: " name
                read -p "Enter phone number: " number
                
                if [[ -z "$name" || -z "$number" ]]; then
                    echo -e "${RED}Error: Name and number cannot be empty${NC}"
                    sleep 1
                else
                    save_contact "$name" "$number"
                    read -p "Press Enter to return to menu..."
                fi
                ;;
            4)
                echo -e "${GREEN}Goodbye!${NC}"
                sleep 1
                clear
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid choice${NC}"
                sleep 1
                ;;
        esac
    done
}

# Main program
clear
echo -e "${YELLOW}Loading Contact Search System...${NC}"
sleep 1
contacts=$(load_contacts) || exit 1
main_menu
