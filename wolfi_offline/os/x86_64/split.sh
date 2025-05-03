#!/usr/bin/env bash
# split_recombine.sh — split a binary file in two and recombine (portable macOS/Linux)

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <filename>"
  exit 1
fi

input="$1"

if [[ ! -f "$input" ]]; then
  echo "Error: File '$input' not found."
  exit 1
fi

# Compute total size in bytes (portable)
filesize=$(wc -c < "$input")
half=$(( filesize / 2 ))

# Define part names
part1="${input}.part1"
part2="${input}.part2"
output="recombined_${input}"

echo "Splitting '$input' ($filesize bytes) into:"
echo "  • $part1 (first $half bytes)"
echo "  • $part2 (remaining $(( filesize - half )) bytes)"

# Split
dd if="$input" of="$part1" bs=1 count="$half" status=progress
dd if="$input" of="$part2" bs=1 skip="$half" status=progress

#echo "Recombining into '$output'..."
#cat "$part1" "$part2" > "$output"
#
## Verify
#if cmp --silent "$input" "$output"; then
#  echo "Success: '$output' matches the original."
#else
#  echo "Warning: '$output' differs from the original."
#fi
