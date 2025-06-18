#!/bin/bash
# Script to check AWS environment variables and return JSON for Terraform

EXPECTED_CHECKSUM_CALCULATION="when_required"
EXPECTED_CHECKSUM_VALIDATION="when_required"

# Initialize JSON output
OUTPUT="{}"

# Check AWS_REQUEST_CHECKSUM_CALCULATION
if [ "$AWS_REQUEST_CHECKSUM_CALCULATION" != "$EXPECTED_CHECKSUM_CALCULATION" ]; then
  OUTPUT=$(echo "$OUTPUT" | jq --arg v "$EXPECTED_CHECKSUM_CALCULATION" '.error_calculation = "AWS_REQUEST_CHECKSUM_CALCULATION must be set to \($v)"')
else
  OUTPUT=$(echo "$OUTPUT" | jq '.calculation_ok = "true"')
fi

# Check AWS_RESPONSE_CHECKSUM_VALIDATION
if [ "$AWS_RESPONSE_CHECKSUM_VALIDATION" != "$EXPECTED_CHECKSUM_VALIDATION" ]; then
  OUTPUT=$(echo "$OUTPUT" | jq --arg v "$EXPECTED_CHECKSUM_VALIDATION" '.error_validation = "AWS_RESPONSE_CHECKSUM_VALIDATION must be set to \($v)"')
else
  OUTPUT=$(echo "$OUTPUT" | jq '.validation_ok = "true"')
fi

# echo "DEBUG: JSON output: $OUTPUT" >&2

# Output JSON
echo "$OUTPUT"