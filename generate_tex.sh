#!/bin/bash
# Generate LaTeX file from CSV address data
# CSVから宛名データを読み込んでLaTeXファイルを生成するスクリプト
# 出力は常にatena.texに上書きされます
#
# Usage:
#   generate_tex.sh [CSV_FILE] [SENDER_FILE]
#   or use environment variables: CSV_FILE, SENDER_FILE

set -e

# Output file is always atena.tex (will be overwritten)
TEX_FILE='atena.tex'

# Show usage if help is requested (check before argument parsing)
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "Usage: $0 [CSV_FILE] [SENDER_FILE]"
    echo ""
    echo "Arguments:"
    echo "  CSV_FILE       CSV file with addresses (default: data/addresses.csv)"
    echo "  SENDER_FILE    File with sender information (default: data/sender.txt)"
    echo ""
    echo "Environment variables:"
    echo "  CSV_FILE       Override CSV file path"
    echo "  SENDER_FILE    Override sender file path"
    echo ""
    echo "Note: Output is always written to atena.tex (will be overwritten)"
    echo ""
    echo "Examples:"
    echo "  $0 data/addresses.csv data/sender.txt"
    echo "  CSV_FILE=data/addresses2.csv SENDER_FILE=data/sender2.txt $0"
    exit 0
fi

# Parse command line arguments or use environment variables
if [ $# -ge 1 ]; then
    CSV_FILE="${1:-data/addresses.csv}"
else
    CSV_FILE="${CSV_FILE:-data/addresses.csv}"
fi

if [ $# -ge 2 ]; then
    SENDER_FILE="${2:-data/sender.txt}"
else
    SENDER_FILE="${SENDER_FILE:-data/sender.txt}"
fi

# Read sender information from sender.txt or use defaults
read_sender_info() {
    if [ -f "$SENDER_FILE" ]; then
        # Read lines, removing empty lines and trimming whitespace
        sendername=$(sed -n '1p' "$SENDER_FILE" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        senderaddressa=$(sed -n '2p' "$SENDER_FILE" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        senderaddressb=$(sed -n '3p' "$SENDER_FILE" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        senderpostcode=$(sed -n '4p' "$SENDER_FILE" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    fi
    
    # Use defaults if empty
    sendername=${sendername:-'山田 太郎'}
    senderaddressa=${senderaddressa:-'東京都千代田区1-2-3'}
    senderaddressb=${senderaddressb:-'山田マンション 101'}
    senderpostcode=${senderpostcode:-'1000001'}
}

# Escape LaTeX special characters
# Note: Braces must be escaped before backslashes to avoid corrupting \textbackslash{}
escape_latex() {
    echo "$1" | sed 's/{/\\{/g; s/}/\\}/g; s/\\/\\textbackslash{}/g; s/\$/\\\$/g; s/&/\\\&/g; s/#/\\#/g; s/\^/\\\^{}/g; s/_/\\_/g; s/%/\\%/g'
}

# Generate LaTeX file
generate_tex() {
    # Escape sender info
    sendername_escaped=$(escape_latex "$sendername")
    senderaddressa_escaped=$(escape_latex "$senderaddressa")
    senderaddressb_escaped=$(escape_latex "$senderaddressb")
    senderpostcode_escaped=$(escape_latex "$senderpostcode")
    
    # Write header
    cat > "$TEX_FILE" <<EOF
\\documentclass{jletteraddress}

% Sender's information (差出人情報)
\\sendername{${sendername_escaped}}
\\senderaddressa{${senderaddressa_escaped}}
\\senderaddressb{${senderaddressb_escaped}}
\\senderpostcode{${senderpostcode_escaped}}

\\begin{document}
EOF

    # Check if CSV file exists
    if [ ! -f "$CSV_FILE" ]; then
        echo "Error: $CSV_FILE not found" >&2
        exit 1
    fi
    
    # Read CSV and generate addresses
    # Skip header line and empty lines
    address_count=0
    while IFS=',' read -r name honorific postcode address1 address2 || [ -n "$name" ]; do
        # Skip header line
        if [ "$name" = "name" ] || [ -z "$name" ]; then
            continue
        fi
        
        # Trim whitespace
        name=$(echo "$name" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        honorific=$(echo "$honorific" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        postcode=$(echo "$postcode" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        address1=$(echo "$address1" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        address2=$(echo "$address2" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        
        # Skip empty rows
        if [ -z "$name" ]; then
            continue
        fi
        
        # Use default honorific if empty
        honorific=${honorific:-'様'}
        
        # Escape LaTeX special characters
        name_escaped=$(escape_latex "$name")
        honorific_escaped=$(escape_latex "$honorific")
        postcode_escaped=$(escape_latex "$postcode")
        address1_escaped=$(escape_latex "$address1")
        address2_escaped=$(escape_latex "$address2")
        
        # Append address to file
        cat >> "$TEX_FILE" <<EOF
  % Recipient: ${name_escaped}
  \\addaddress
      {${name_escaped}}
      {${honorific_escaped}}
      {${postcode_escaped}}
      {${address1_escaped}}
      {${address2_escaped}}

EOF
        address_count=$((address_count + 1))
    done < "$CSV_FILE"
    
    # Close document
    echo "\\end{document}" >> "$TEX_FILE"
    
    if [ $address_count -eq 0 ]; then
        echo "Warning: No addresses found in $CSV_FILE" >&2
    else
        echo "Generated $TEX_FILE with $address_count address(es)"
    fi
}

# Main execution
read_sender_info
generate_tex

