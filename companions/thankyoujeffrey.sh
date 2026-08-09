#!/usr/bin/env sh

set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
project_dir=$(CDPATH= cd -- "$script_dir/.." && pwd)

printf '%s\n' 'Thank You Jeffrey — a cross-shell PowerShell tribute'
printf '%s\n' '-----------------------------------------------------'
printf '%s\n' 'PowerShell is a tool for thought, and the pipeline carries the idea forward.'
printf '\n%s\n' 'PowerShell firsts:'

if command -v jq >/dev/null 2>&1 && [ -f "$project_dir/data/timeline.json" ]; then
    jq -r '.[] | "[\(.year)] \(.event)"' "$project_dir/data/timeline.json"
else
    printf '%s\n' '[2002] The Monad Manifesto is written' \
        '[2006] PowerShell 1.0 released to the world' \
        '[2016] PowerShell goes open source' \
        '[2020] PowerShell 7 — the unified shell'
fi

printf '\n%s\n' 'Snoverisms:'
if command -v jq >/dev/null 2>&1 && [ -f "$project_dir/data/snoverisms.json" ]; then
    jq -r '.[] | "\"\(.text)\" \(.attribution)"' "$project_dir/data/snoverisms.json"
else
    printf '%s\n' '"The pipeline is the heart of PowerShell." — Jeffrey Snover' \
        '"PowerShell is a tool for thought." — Jeffrey Snover'
fi

printf '\n%s\n' 'Thank you, Jeffrey.'
