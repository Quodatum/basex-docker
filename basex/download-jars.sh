#!/bin/bash

# simple-download-jars.sh - No verification
# Downloads JAR files from Maven Central

INPUT_FILE="$1"
OUTPUT_DIR="${2:-./lib/custom}"
MAVEN_CENTRAL="https://repo1.maven.org/maven2"

if [ -z "$INPUT_FILE" ]; then
    echo "Usage: $0 <input-file> [output-directory]"
    exit 1
fi

if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: File '$INPUT_FILE' not found"
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

while IFS= read -r line || [ -n "$line" ]; do
    # Skip comments and empty lines
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
    
    # Parse Maven coordinates
    IFS=':' read -r groupId artifactId version classifier <<< "$line"
    
    if [ -z "$groupId" ] || [ -z "$artifactId" ] || [ -z "$version" ]; then
        echo "Skipping invalid line: $line"
        continue
    fi
    
    # Convert groupId to path
    groupPath=$(echo "$groupId" | tr '.' '/')
    
    # Build filename and URL
    jarFile="${artifactId}-${version}.jar"
    if [ -n "$classifier" ]; then
        jarFile="${artifactId}-${version}-${classifier}.jar"
    fi
    
    url="${MAVEN_CENTRAL}/${groupPath}/${artifactId}/${version}/${jarFile}"
    
    echo "Downloading: $groupId:$artifactId:$version${classifier:+:$classifier}"
    
    # Download if not already present
    if [ ! -f "${OUTPUT_DIR}/${jarFile}" ]; then
        if curl -L --fail --silent --show-error -o "${OUTPUT_DIR}/${jarFile}" "$url"; then
            echo "  ✓ Saved to ${OUTPUT_DIR}/${jarFile}"
        else
            echo "  ✗ Failed to download"
        fi
    else
        echo "  ✓ Already exists"
    fi
    
done < "$INPUT_FILE"

echo "Done!"