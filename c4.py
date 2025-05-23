import subprocess
import sys

def open_dialer(number):
    """                                                           Opens the dialer with the number pre-filled using multiple methods.
    User must manually press call button.

    Args:
        number (str): Phone number in international format (e.g., "+1234567890")

    Returns:
        bool: True if successful, False otherwise
    """
    # Validate number format
    if not number.startswith("+"):
        print("⚠️ Warning: For best results, use international format (+countrycode...)")

    methods = [
        # Preferred method - termux-open-url
        {
            "command": ["termux-open-url", f"tel:{number}"],
            "error": "Termux URL opener failed"
        },
        # Fallback method - Android activity manager
        {
            "command": ["am", "start", "-a", "android.intent.action.DIAL", "-d", f"tel:{number}"],
            "error": "Android activity manager failed"
        },
        # Alternative method - xdg-open (for some Linux environments)
        {
            "command": ["xdg-open", f"tel:{number}"],
            "error": "xdg-open failed"
        }
    ]

    for method in methods:
        try:
            result = subprocess.run(
                method["command"],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                check=True
            )
            print(f"✅ Successfully opened dialer with number: {number}")
            return True
        except subprocess.CalledProcessError as e:
            print(f"⚠️ {method['error']}: {e.stderr.strip()}")
        except FileNotFoundError:
            print(f"⚠️ Command not found: {method['command'][0]}")
        except Exception as e:
            print(f"❌ Unexpected error with {method['command'][0]}: {str(e)}")

    print("❌ All methods failed to open dialer")
    return False

if __name__ == "__main__":
    if len(sys.argv) > 1:
        number = sys.argv[1]
    else:
        number = input("Enter phone number (e.g., +1234567890): ").strip()

    open_dialer(number)
