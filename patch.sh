#!/usr/bin/env bash
set -euo pipefail

die() { echo "error: $*" >&2; exit 1; }

[[ $# -ge 1 ]] || die "usage: $0 SOURCE_DIR [MANIFEST]"
command -v bspatch >/dev/null || die "install bsdiff: sudo apt install bsdiff"

BASE=$(cd -- "$(dirname -- "$0")" && pwd)
SRC=$(realpath -- "$1")
MANIFEST=${2:-"$BASE/manifest"}
OUT=$(realpath -m -- "$PWD/export")

[[ -d $SRC ]] || die "source directory not found"
[[ -f $MANIFEST ]] || die "manifest not found"

case "$OUT/" in "$SRC/"*) die "export cannot be inside source directory";; esac

rm -rf -- "$OUT"
mkdir -p -- "$OUT"
cp -a -- "$SRC"/. "$OUT"/
findsrc() {
    if [[ $2 == */* ]]; then
        find "$1" -type f -ipath "$1/$2" -print0
    else
        find "$1" -type f -iname "$2" -print0
    fi
}
outpath() {
    local rel="$1"
    local dir="$OUT" part found
    local name="${rel##*/}"
    local -a parts

    if [[ $rel == */* ]]; then
        IFS=/ read -ra parts <<< "${rel%/*}"

        for part in "${parts[@]}"; do
            found=$(find "$dir" -mindepth 1 -maxdepth 1 \
                -type d -iname "$part" -print -quit)

            dir=${found:-"$dir/$part"}
            mkdir -p -- "$dir"
        done
    fi

    found=$(find "$dir" -mindepth 1 -maxdepth 1 \
        -iname "$name" -print -quit)

    printf '%s\n' "${found:-"$dir/$name"}"
}
declare -A needed done

while IFS= read -r line || [[ -n $line ]]; do
    line=${line%$'\r'}
    line=${line%%#*}

    read -r hash source patch output extra <<< "$line"
    [[ -n ${hash:-} ]] || continue
    [[ -n ${output:-} && -z ${extra:-} ]] ||
        die "bad manifest line: $line"

    if [[ $patch == - && $output == - ]]; then
        key="delete:${source,,}"
    else
        key="output:${output,,}"
    fi

    needed["$key"]="$line"
    [[ ${done[$key]:-} ]] && continue

    matches=()

    while IFS= read -r -d '' file; do
        actual=$(sha256sum -- "$file")
        actual=${actual%% *}

        [[ $hash == '*' || ${actual,,} == ${hash,,} ]] &&
            matches+=("$file")
    done < <(findsrc "$OUT" "$source")

    ((${#matches[@]} == 0)) && continue
    ((${#matches[@]} == 1)) ||
        die "'$source' matches multiple files"

    file=${matches[0]}

    if [[ $patch == - && $output == - ]]; then
        echo "delete: ${file#"$OUT"/}"
        rm -f -- "$file"

    elif [[ $patch == - ]]; then
        target=$(outpath "$output")
        echo "rename: ${file#"$OUT"/} -> $output"
        [[ $file == "$target" ]] || mv -f -- "$file" "$target"

    else
        patchfile=$(find "$BASE" -type f \
            -ipath "$BASE/$patch" -print -quit)

        [[ -n $patchfile ]] || die "patch not found: $patch"

        target=$(outpath "$output")
        tmp=$(mktemp "${target}.tmp.XXXXXX")

        echo "patch: ${file#"$OUT"/} -> $output"

        bspatch "$file" "$tmp" "$patchfile" || {
            rm -f -- "$tmp"
            die "patch failed: $patch"
        }

        chmod --reference="$file" "$tmp" 2>/dev/null || true
        mv -f -- "$tmp" "$target"
    fi

    done["$key"]=1
done < "$MANIFEST"

for key in "${!needed[@]}"; do
    [[ ${done[$key]:-} ]] ||
        die "no matching source: ${needed[$key]}"
done

echo "finished: $OUT"