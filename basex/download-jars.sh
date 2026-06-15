#!/bin/bash

# download-jars.sh
# Downloads JAR files from Maven Central based on coordinates in a text file

set -e  # Exit on error

# Configuration
MAVEN_CENTRAL="https://repo1.maven.org/maven2"
OUTPUT_DIR="./lib/custom"
VERBOSE=false

# Function to display usage
usage() {
    cat << EOF
Usage: $0 [OPTIONS] <input-file>

Downloads JAR files from Maven Central based on coordinates in a text file.

Options:
    -o, --output DIR    Output directory (default: ./lib/custom)
    -s, --source URL    Maven repository source (default: https://repo1.maven.org/maven2)
    -v, --verbose       Show detailed output
    -h, --help          Show this help message

Input file format:
    # Lines starting with # are comments
    # Empty lines are ignored
    # Format: groupId:artifactId:version[:classifier]
    
    net.sf.saxon:Saxon-HE:10.9
    org.xmlresolver:xmlresolver:6.0.21
    org.xmlresolver:xmlresolver:6.0.21:data

Example:
    $0 -o ./custom-libs dependencies.txt
EOF
    exit 0
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -o|--output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -s|--source)
            MAVEN_CENTRAL="$2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            INPUT_FILE="$1"
            shift
            ;;
    esac
done

# Check if input file is provided
if [ -z "$INPUT_FILE" ]; then
    echo "Error: No input file specified"
    usage
fi

# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file '$INPUT_FILE' not found"
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Function to download a JAR file
download_jar() {
    local groupId="$1"
    local artifactId="$2"
    local version="$3"
    local classifier="$4"
    
    # Convert groupId to path (dots to slashes)
    local groupPath=$(echo "$groupId" | tr '.' '/')
    
    # Construct the JAR filename
    local jarFilename="${artifactId}-${version}.jar"
    if [ -n "$classifier" ]; then
        jarFilename="${artifactId}-${version}-${classifier}.jar"
    fi
    
    # Construct the URL
    local url="${MAVEN_CENTRAL}/${groupPath}/${artifactId}/${version}/${jarFilename}"
    
    # Local output path
    local outputPath="${OUTPUT_DIR}/${jarFilename}"
    
    # Check if file already exists
    if [ -f "$outputPath" ]; then
        echo "✓ Already exists: $jarFilename"
        return 0
    fi
    
    # Download the file
    echo "Downloading: $groupId:$artifactId:$version${classifier:+:$classifier}"
    
    if [ "$VERBOSE" = true ]; then
        curl -L --fail --progress-bar -o "$outputPath" "$url"
    else
        if curl -L --fail --silent -o "$outputPath" "$url"; then
            echo "  ✓ Downloaded: $jarFilename"
        else
            echo "  ✗ Failed: $jarFilename"
            return 1
        fi
    fi
    
    # Verify download
    if [ -f "$outputPath" ] && [ -s "$outputPath" ]; then
        # Check if it's a valid JAR (ZIP) file
        if file "$outputPath" | grep -q "Zip archive\|Java archive"; then
            echo "  ✓ Verified: $jarFilename"
            return 0
        else
            echo "  ✗ Invalid JAR file: $jarFilename"
            rm -f "$outputPath"
            return 1
        fi
    else
        echo "  ✗ Download failed or file empty: $jarFilename"
        return 1
    fi
}

# Parse and process the input file
echo "Processing dependencies from: $INPUT_FILE"
echo "Output directory: $OUTPUT_DIR"
echo "Repository: $MAVEN_CENTRAL"
echo ""

SUCCESS_COUNT=0
FAIL_COUNT=0

# Read the input file line by line
while IFS= read -r line || [ -n "$line" ]; do
    # Skip empty lines and comments
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
    
    # Remove leading/trailing whitespace
    line=$(echo "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
    
    # Split by colon
    IFS=':' read -r groupId artifactId version classifier <<< "$line"
    
    # Validate required fields
    if [ -z "$groupId" ] || [ -z "$artifactId" ] || [ -z "$version" ]; then
        echo "⚠ Invalid line (missing required fields): $line"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        continue
    fi
    
    # Download the JAR
    if download_jar "$groupId" "$artifactId" "$version" "$classifier"; then
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    else
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
    
    echo ""
done < "$INPUT_FILE"

# Summary
echo "========================================="
echo "Download complete!"
echo "Successful: $SUCCESS_COUNT"
echo "Failed: $FAIL_COUNT"

if [ $FAIL_COUNT -gt 0 ]; then
    exit 1
fi

exit 0