#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 <sample_path> [output_base_dir]"
  echo "Example: $0 ./sample.exe /home/kali/Desktop"
  exit 1
}

# --- Args & defaults ---
SAMPLE="${1:-}"; [[ -z "$SAMPLE" ]] && usage
OUTBASE="${2:-/home/kali/Desktop}"

# --- Sanity checks ---
for tool in rabin2 r2 objdump sha256sum; do
  command -v "$tool" >/dev/null 2>&1 || { echo "[-] Missing tool: $tool"; exit 2; }
done
[[ -r "$SAMPLE" ]] || { echo "[-] Cannot read sample: $SAMPLE"; exit 3; }
mkdir -p "$OUTBASE"

SNAME="$(basename "$SAMPLE")"
STAMP="$(date +%Y%m%d_%H%M%S)"
OUTDIR="${OUTBASE%/}/${SNAME}_r2dump_${STAMP}"
mkdir -p "$OUTDIR"

echo "[*] Sample:     $SAMPLE"
echo "[*] Output dir: $OUTDIR"

# --- Preserve a copy & hash ---
cp -f -- "$SAMPLE" "$OUTDIR/"
sha256sum -- "$SAMPLE" > "$OUTDIR/hash_sha256.txt" || true

# --- rabin2 set ---
rabin2 -I  -- "$SAMPLE" > "$OUTDIR/01_info.txt"             || true
rabin2 -S  -- "$SAMPLE" > "$OUTDIR/02_sections.txt"         || true
rabin2 -zz -- "$SAMPLE" > "$OUTDIR/03_strings_offsets.txt"  || true
rabin2 -z  -- "$SAMPLE" > "$OUTDIR/04_strings_basic.txt"    || true
rabin2 -i  -- "$SAMPLE" > "$OUTDIR/05_imports.txt"          || true
rabin2 -E  -- "$SAMPLE" > "$OUTDIR/06_exports.txt"          || true
rabin2 -L  -- "$SAMPLE" > "$OUTDIR/07_libraries.txt"        || true
rabin2 -R  -- "$SAMPLE" > "$OUTDIR/08_relocations.txt"      || true
rabin2 -U  -- "$SAMPLE" > "$OUTDIR/09_resources.txt"        || true

# --- objdump sections (alt view) ---
objdump -h -- "$SAMPLE"   > "$OUTDIR/10_sections_objdump.txt" || true

# --- radare2 quick scan (no TUI) ---
r2 -q -e scr.color=false \
   -c "aaa; iS; ii; afl; s entry0; af; pdf" \
   -- "$SAMPLE" > "$OUTDIR/11_r2_quickscan.txt" || true

# --- quick metadata summary ---
{
  echo "== SUMMARY =="
  echo "Sample: $SAMPLE"
  echo -n "SHA256: "; cat "$OUTDIR/hash_sha256.txt" 2>/dev/null | awk '{print $1}'
  echo -n "Entry:  "; grep -m1 -E 'entry|ep|Entrypoint' "$OUTDIR/01_info.txt" 2>/dev/null || true
  echo "Strings: $(wc -l < "$OUTDIR/03_strings_offsets.txt" 2>/dev/null || echo 0)"
} > "$OUTDIR/00_summary.txt"

echo "[+] Done. Artifacts saved in: $OUTDIR"
