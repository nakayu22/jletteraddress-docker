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
        # Read lines, skipping comments (lines starting with #) and empty lines
        # Find first non-comment, non-empty line for name
        line_num=1
        while IFS= read -r line || [ -n "$line" ]; do
            # Trim whitespace
            line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
            # Skip empty lines and comments
            if [ -z "$line" ] || [ "${line#\#}" != "$line" ]; then
                line_num=$((line_num + 1))
                continue
            fi
            sendername="$line"
            break
        done < "$SENDER_FILE"
        
        # Find second non-comment, non-empty line for address1
        line_num=1
        found_first=false
        while IFS= read -r line || [ -n "$line" ]; do
            # Trim whitespace
            line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
            # Skip empty lines and comments
            if [ -z "$line" ] || [ "${line#\#}" != "$line" ]; then
                line_num=$((line_num + 1))
                continue
            fi
            if [ "$found_first" = false ]; then
                found_first=true
                line_num=$((line_num + 1))
                continue
            fi
            senderaddressa="$line"
            break
        done < "$SENDER_FILE"
        
        # Find third non-comment, non-empty line for address2
        line_num=1
        found_count=0
        while IFS= read -r line || [ -n "$line" ]; do
            # Trim whitespace
            line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
            # Skip empty lines and comments
            if [ -z "$line" ] || [ "${line#\#}" != "$line" ]; then
                line_num=$((line_num + 1))
                continue
            fi
            found_count=$((found_count + 1))
            if [ $found_count -eq 3 ]; then
                senderaddressb="$line"
                break
            fi
        done < "$SENDER_FILE"
        
        # Find fourth non-comment, non-empty line for postcode
        line_num=1
        found_count=0
        while IFS= read -r line || [ -n "$line" ]; do
            # Trim whitespace
            line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
            # Skip empty lines and comments
            if [ -z "$line" ] || [ "${line#\#}" != "$line" ]; then
                line_num=$((line_num + 1))
                continue
            fi
            found_count=$((found_count + 1))
            if [ $found_count -eq 4 ]; then
                senderpostcode="$line"
                break
            fi
        done < "$SENDER_FILE"
    fi
}

# Escape LaTeX special characters
# Note: Braces must be escaped before backslashes to avoid corrupting \textbackslash{}
escape_latex() {
    echo "$1" | sed 's/{/\\{/g; s/}/\\}/g; s/\\/\\textbackslash{}/g; s/\$/\\\$/g; s/&/\\\&/g; s/#/\\#/g; s/\^/\\\^{}/g; s/_/\\_/g; s/%/\\%/g'
}

# Process renmei (multiple names) for sender
# This function processes sender name and generates renmei command if needed
process_sender_renmei() {
    local name="$1"
    local renmei_cmd=""
    
    # Check if name contains semicolon (renmei - multiple names)
    if echo "$name" | grep -q ';'; then
        # Process renmei (multiple names)
        renmei_parts=""
        first_name=""
        name_count=0
        first_surname=""
        first_given_name=""
        has_name_without_surname=false
        
        # Split by semicolon and collect all name parts
        IFS=';' read -ra NAMES <<< "$name"
        declare -a name_items_array=()
        declare -a honorific_items_array=()
        declare -a has_surname_array=()
        declare -a surname_array=()
        declare -a given_name_array=()
        
        # First pass: collect all names and honorifics, extract surname from first name
        for idx in "${!NAMES[@]}"; do
            name_part="${NAMES[$idx]}"
            # Trim whitespace
            name_part=$(echo "$name_part" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
            
            if [ -z "$name_part" ]; then
                continue
            fi
            
            # Check if name_part contains colon (name:honorific format)
            if echo "$name_part" | grep -q ':'; then
                # Split by colon
                IFS=':' read -ra NAME_HONORIFIC <<< "$name_part"
                name_item=$(echo "${NAME_HONORIFIC[0]}" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
                honorific_item=$(echo "${NAME_HONORIFIC[1]}" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
                
                # Use default honorific if empty (送り主の場合は通常不要だが、指定された場合は使用)
                honorific_item=${honorific_item:-''}
            else
                # No honorific for sender (送り主の場合は敬称なし)
                name_item="$name_part"
                honorific_item=""
            fi
            
            # Check if name has surname (contains full-width space or half-width space)
            if echo "$name_item" | grep -q '　'; then
                # Has surname - extract surname and given name (full-width space)
                surname=$(echo "$name_item" | sed 's/　.*$//')
                given_name=$(echo "$name_item" | sed 's/^.*　//')
                has_surname=true
            elif echo "$name_item" | grep -qE '[[:space:]]'; then
                # Has surname - extract surname and given name (half-width space)
                surname=$(echo "$name_item" | sed 's/[[:space:]].*$//')
                given_name=$(echo "$name_item" | sed 's/^[^[:space:]]*[[:space:]]//')
                has_surname=true
            else
                # No surname - this is given name only
                surname=""
                given_name="$name_item"
                has_surname=false
                if [ $idx -gt 0 ]; then
                    has_name_without_surname=true
                fi
            fi
            
            # Store first name's surname for later use
            if [ $idx -eq 0 ] && [ "$has_surname" = true ]; then
                first_surname="$surname"
                first_given_name="$given_name"
            fi
            
            # Escape LaTeX special characters (for parameters inside renmei command)
            name_item_escaped=$(escape_latex "$name_item")
            honorific_item_escaped=$(escape_latex "$honorific_item")
            surname_escaped=$(escape_latex "$surname")
            given_name_escaped=$(escape_latex "$given_name")
            
            # Store in arrays
            name_items_array+=("$name_item_escaped")
            honorific_items_array+=("$honorific_item_escaped")
            has_surname_array+=("$has_surname")
            surname_array+=("$surname_escaped")
            given_name_array+=("$given_name_escaped")
            name_count=$((name_count + 1))
        done
        
        # Second pass: build renmei command
        # Check if we need to use withspace commands
        if [ "$has_name_without_surname" = true ] && [ -n "$first_surname" ]; then
            # Use withspace commands when second name or later has no surname
            if [ $name_count -eq 2 ]; then
                # Find which name has no surname (in original order)
                if [ "${has_surname_array[1]}" = false ]; then
                    # Second name (idx 1) has no surname
                    # For sender, display second name on the left, first name on the right
                    renmei_cmd="\\renmeitwowithspace{${first_surname}}{${given_name_array[1]}}{${honorific_items_array[1]}}{${given_name_array[0]}}{${honorific_items_array[0]}}"
                else
                    # First name has no surname (shouldn't happen, but handle it)
                    renmei_cmd="\\renmeitwo{${surname_array[0]}}{${given_name_array[0]}}{${honorific_items_array[0]}}{${surname_array[1]}}{${given_name_array[1]}}{${honorific_items_array[1]}}"
                fi
            elif [ $name_count -eq 3 ]; then
                # Check which name has no surname
                if [ "${has_surname_array[1]}" = false ]; then
                    # Second name (idx 1) has no surname
                    # For sender, display second name on the left, first name in the middle, third name on the right
                    renmei_cmd="\\renmeithreewithspace{${first_surname}}{${given_name_array[1]}}{${honorific_items_array[1]}}{${given_name_array[0]}}{${honorific_items_array[0]}}{${given_name_array[2]}}{${honorific_items_array[2]}}"
                else
                    # Use regular command
                    renmei_cmd="\\renmeithree{${surname_array[0]}}{${given_name_array[0]}}{${honorific_items_array[0]}}{${surname_array[1]}}{${given_name_array[1]}}{${honorific_items_array[1]}}{${surname_array[2]}}{${given_name_array[2]}}{${honorific_items_array[2]}}"
                fi
            else
                # For 4 or more names, use regular command
                if [ $name_count -eq 4 ]; then
                    # Use first surname for all names (assuming they share the same surname)
                    first_surname_for_four="${surname_array[0]}"
                    if [ -z "$first_surname_for_four" ]; then
                        first_surname_for_four=""
                    fi
                    renmei_cmd="\\renmeifour{${first_surname_for_four}}{${given_name_array[0]}}{${honorific_items_array[0]}}{${given_name_array[1]}}{${honorific_items_array[1]}}{${given_name_array[2]}}{${honorific_items_array[2]}}{${given_name_array[3]}}{${honorific_items_array[3]}}"
                else
                    echo "Error: Unsupported number of names in sender renmei: $name_count" >&2
                    renmei_cmd=""
                fi
            fi
        else
            # Use regular commands with separated surname, given name, and honorific
            # Build renmei_parts in reverse order (for sender, second name on the left)
            for ((i=${#name_items_array[@]}-1; i>=0; i--)); do
                if [ -z "$renmei_parts" ]; then
                    renmei_parts="{${surname_array[i]}}{${given_name_array[i]}}{${honorific_items_array[i]}}"
                else
                    renmei_parts="${renmei_parts}{${surname_array[i]}}{${given_name_array[i]}}{${honorific_items_array[i]}}"
                fi
            done
            
            # Determine which command to use based on name count
            if [ $name_count -eq 2 ]; then
                renmei_cmd="\\renmeitwo${renmei_parts}"
            elif [ $name_count -eq 3 ]; then
                renmei_cmd="\\renmeithree${renmei_parts}"
            elif [ $name_count -eq 4 ]; then
                renmei_cmd="\\renmeifour${renmei_parts}"
            else
                echo "Error: Unsupported number of names in sender renmei: $name_count" >&2
                renmei_cmd=""
            fi
        fi
    fi
    
    echo "$renmei_cmd"
}

# Generate LaTeX file
generate_tex() {
    # Process sender name for renmei
    sender_renmei_cmd=$(process_sender_renmei "$sendername")
    
    # Escape sender info (for non-renmei case or address fields)
    if [ -z "$sender_renmei_cmd" ]; then
        # Single name - escape normally
        sendername_escaped=$(escape_latex "$sendername")
        sender_name_output="${sendername_escaped}"
    else
        # Renmei - use the command directly (no escaping needed for LaTeX command)
        sender_name_output="${sender_renmei_cmd}"
    fi
    
    senderaddressa_escaped=$(escape_latex "$senderaddressa")
    senderaddressb_escaped=$(escape_latex "$senderaddressb")
    senderpostcode_escaped=$(escape_latex "$senderpostcode")
    
    # Write header
    cat > "$TEX_FILE" <<EOF
\\documentclass{jletteraddress}

% Sender's information (差出人情報)
\\sendername{${sender_name_output}}
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
        
        # Check if name contains semicolon (renmei - multiple names)
        if echo "$name" | grep -q ';'; then
            # Process renmei (multiple names)
            # Reverse the order so CSV left names appear on the right in the address
            renmei_parts=""
            first_name=""
            name_count=0
            first_surname=""
            first_given_name=""
            has_name_without_surname=false
            
            # Split by semicolon and collect all name parts
            IFS=';' read -ra NAMES <<< "$name"
            declare -a name_items_array=()
            declare -a honorific_items_array=()
            declare -a has_surname_array=()
            declare -a surname_array=()
            declare -a given_name_array=()
            
            # First pass: collect all names and honorifics, extract surname from first name
            for idx in "${!NAMES[@]}"; do
                name_part="${NAMES[$idx]}"
                # Trim whitespace
                name_part=$(echo "$name_part" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
                
                if [ -z "$name_part" ]; then
                    continue
                fi
                
                # Check if name_part contains colon (name:honorific format)
                if echo "$name_part" | grep -q ':'; then
                    # Split by colon
                    IFS=':' read -ra NAME_HONORIFIC <<< "$name_part"
                    name_item=$(echo "${NAME_HONORIFIC[0]}" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
                    honorific_item=$(echo "${NAME_HONORIFIC[1]}" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
                    
                    # Use default honorific if empty
                    honorific_item=${honorific_item:-'様'}
                else
                    # Use honorific from CSV field
                    name_item="$name_part"
                    honorific_item="$honorific"
                fi
                
                # Check if name has surname (contains full-width space)
                if echo "$name_item" | grep -q '　'; then
                    # Has surname - extract surname and given name
                    surname=$(echo "$name_item" | sed 's/　.*$//')
                    given_name=$(echo "$name_item" | sed 's/^.*　//')
                    has_surname=true
                else
                    # No surname - this is given name only
                    surname=""
                    given_name="$name_item"
                    has_surname=false
                    if [ $idx -gt 0 ]; then
                        has_name_without_surname=true
                    fi
                fi
                
                # Store first name's surname for later use
                if [ $idx -eq 0 ] && [ "$has_surname" = true ]; then
                    first_surname="$surname"
                    first_given_name="$given_name"
                fi
                
                # Escape LaTeX special characters
                name_item_escaped=$(escape_latex "$name_item")
                honorific_item_escaped=$(escape_latex "$honorific_item")
                surname_escaped=$(escape_latex "$surname")
                given_name_escaped=$(escape_latex "$given_name")
                
                # Store in arrays
                name_items_array+=("$name_item_escaped")
                honorific_items_array+=("$honorific_item_escaped")
                has_surname_array+=("$has_surname")
                surname_array+=("$surname_escaped")
                given_name_array+=("$given_name_escaped")
                name_count=$((name_count + 1))
            done
            
            # Second pass: build renmei_parts in reverse order
            # Check if we need to use withspace commands
            # Note: Arrays are in original CSV order (left to right)
            # After reversal, first element (idx 0) will be on the right in address
            if [ "$has_name_without_surname" = true ] && [ -n "$first_surname" ]; then
                # Use withspace commands when second name or later has no surname
                # Process in reverse order (last to first) for display
                if [ $name_count -eq 2 ]; then
                    # Find which name has no surname (in original CSV order)
                    if [ "${has_surname_array[1]}" = false ]; then
                        # Second name (idx 1) has no surname in CSV
                        # CSV order: idx 0 (left, with surname) -> idx 1 (right, no surname)
                        # Display order (reversed): idx 1 (left, no surname) <- idx 0 (right, with surname)
                        # @renmei@displaytwowithspace displays: first (left) then second (right)
                        # So we need: idx 1 (left, no surname) then idx 0 (right, with surname)
                        renmei_cmd="\\renmeitwowithspace{${first_surname}}{${given_name_array[1]}}{${honorific_items_array[1]}}{${given_name_array[0]}}{${honorific_items_array[0]}}"
                    else
                        # First name has no surname (shouldn't happen, but handle it)
                        renmei_cmd="\\renmeitwo{${name_items_array[1]}}{${honorific_items_array[1]}}{${name_items_array[0]}}{${honorific_items_array[0]}}"
                    fi
                    first_name="${name_items_array[1]}"
                elif [ $name_count -eq 3 ]; then
                    # Check which name has no surname
                    if [ "${has_surname_array[1]}" = false ]; then
                        # Second name (idx 1) has no surname in CSV
                        # After reversal: idx 2 (right), idx 1 (middle, no surname), idx 0 (left)
                        renmei_cmd="\\renmeithreewithspace{${first_surname}}{${given_name_array[1]}}{${honorific_items_array[1]}}{${given_name_array[0]}}{${honorific_items_array[0]}}{${name_items_array[2]}}{${honorific_items_array[2]}}"
                    else
                        # Use regular command
                        renmei_cmd="\\renmeithree{${name_items_array[2]}}{${honorific_items_array[2]}}{${name_items_array[1]}}{${honorific_items_array[1]}}{${name_items_array[0]}}{${honorific_items_array[0]}}"
                    fi
                    first_name="${name_items_array[2]}"
                else
                    # For 4 or more names, use regular command with separated surname, given name, and honorific
                    # For 4 names, due to LaTeX's 9-parameter limit, we use shared surname format
                    if [ $name_count -eq 4 ]; then
                        # Use first surname for all names (assuming they share the same surname)
                        first_surname_for_four="${surname_array[0]}"
                        if [ -z "$first_surname_for_four" ]; then
                            # If first name has no surname, use empty
                            first_surname_for_four=""
                        fi
                        # Build command: surname, then name1, honorific1, name2, honorific2, name3, honorific3, name4, honorific4
                        renmei_cmd="\\renmeifour{${first_surname_for_four}}{${given_name_array[3]}}{${honorific_items_array[3]}}{${given_name_array[2]}}{${honorific_items_array[2]}}{${given_name_array[1]}}{${honorific_items_array[1]}}{${given_name_array[0]}}{${honorific_items_array[0]}}"
                        first_name="${name_items_array[3]}"
                    else
                        # For more than 4 names, use regular command (will error, but handle gracefully)
                        for ((i=${#name_items_array[@]}-1; i>=0; i--)); do
                            if [ -z "$renmei_parts" ]; then
                                renmei_parts="{${surname_array[i]}}{${given_name_array[i]}}{${honorific_items_array[i]}}"
                                first_name="${name_items_array[i]}"
                            else
                                renmei_parts="${renmei_parts}{${surname_array[i]}}{${given_name_array[i]}}{${honorific_items_array[i]}}"
                            fi
                        done
                        echo "Error: Unsupported number of names in renmei: $name_count" >&2
                        renmei_cmd="\\renmeitwo${renmei_parts}"
                    fi
                fi
            else
                # Use regular commands with separated surname, given name, and honorific
                # Build renmei_parts in reverse order (last to first) for display
                for ((i=${#name_items_array[@]}-1; i>=0; i--)); do
                    if [ -z "$renmei_parts" ]; then
                        renmei_parts="{${surname_array[i]}}{${given_name_array[i]}}{${honorific_items_array[i]}}"
                        first_name="${name_items_array[i]}"
                    else
                        renmei_parts="${renmei_parts}{${surname_array[i]}}{${given_name_array[i]}}{${honorific_items_array[i]}}"
                    fi
                done
                
                # Determine which command to use based on name count
                if [ $name_count -eq 2 ]; then
                    renmei_cmd="\\renmeitwo${renmei_parts}"
                elif [ $name_count -eq 3 ]; then
                    renmei_cmd="\\renmeithree${renmei_parts}"
                elif [ $name_count -eq 4 ]; then
                    renmei_cmd="\\renmeifour${renmei_parts}"
                else
                    echo "Error: Unsupported number of names in renmei: $name_count" >&2
                    renmei_cmd="\\renmeitwo${renmei_parts}"
                fi
            fi
            
            # Escape other fields
            postcode_escaped=$(escape_latex "$postcode")
            address1_escaped=$(escape_latex "$address1")
            address2_escaped=$(escape_latex "$address2")
            
            # Append address to file (honorific is empty for renmei)
            cat >> "$TEX_FILE" <<EOF
  % Recipient: ${first_name} (renmei)
  \\addaddress
      {${renmei_cmd}}
      {}
      {${postcode_escaped}}
      {${address1_escaped}}
      {${address2_escaped}}

EOF
        else
            # Single name (existing behavior)
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
        fi
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

