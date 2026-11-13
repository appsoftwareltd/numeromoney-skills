#!/usr/bin/env bash
# Calls the NumeroMoney User API and prints the response body.
#
#   nm.sh METHOD PATH [JSON_BODY | @file.json]
#   nm.sh GET /bank-accounts
#   nm.sh GET "/bank-accounts/$ID/transactions?uncategorisedOnly=true&pageSize=500"
#   nm.sh POST "/bank-accounts/$ID/categorisation-rules/preview" '{}'
#   NM_FORM='file=@statement.csv;csvImportFormatId=<id>' nm.sh POST "/bank-accounts/$ID/statement-imports"
#
# The token comes from NUMEROMONEY_TOKEN and reaches curl on stdin, so it never appears in the
# process list or in output. The HTTP status goes to stderr, and the exit code is 0 for 2xx,
# 1 otherwise. A 429 is retried after the Retry-After wait, up to 5 times.

set -euo pipefail

if [[ $# -lt 2 ]]; then
    sed -n '2,13p' "$0" >&2
    exit 2
fi

if [[ -z "${NUMEROMONEY_TOKEN:-}" ]]; then
    echo "NUMEROMONEY_TOKEN is not set." >&2
    exit 2
fi

method="$1"
path="$2"
body="${3:-}"
base="${NUMEROMONEY_BASE_URL:-https://www.numeromoney.com/api/v1}"

args=(-sS -X "$method" --config - -H "Accept: application/json" -A "numeromoney-skill/1 curl")

if [[ -n "$body" ]]; then
    args+=(-H "Content-Type: application/json" --data-binary "$body")
fi

if [[ -n "${NM_FORM:-}" ]]; then
    IFS=';' read -ra fields <<< "$NM_FORM"
    for field in "${fields[@]}"; do
        args+=(-F "$field")
    done
fi

headers="$(mktemp)"
trap 'rm -f "$headers"' EXIT

for attempt in 1 2 3 4 5; do
    response="$(printf 'header = "Authorization: Bearer %s"\n' "$NUMEROMONEY_TOKEN" \
        | curl "${args[@]}" -D "$headers" -w '\n%{http_code}' "$base$path")"
    status="${response##*$'\n'}"
    content="${response%$'\n'*}"

    if [[ "$status" != "429" ]]; then
        break
    fi

    wait="$(grep -i '^retry-after:' "$headers" | tr -dc '0-9')"
    echo "429 rate_limited, waiting ${wait:-15}s (attempt $attempt)" >&2
    sleep "${wait:-15}"
done

printf '%s\n' "$content"
echo "HTTP $status" >&2

[[ "$status" =~ ^2 ]]
