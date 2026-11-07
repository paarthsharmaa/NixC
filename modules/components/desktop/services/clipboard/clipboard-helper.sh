# Backend for the quickshell clipboard panel (ClipboardPanel.qml).
#
#   clipboard-helper list          cliphist history: "<id>\t<preview>" lines
#   clipboard-helper preview <id>  what the preview pane shows (format below)
#   clipboard-helper copy <id>     put an entry back on the clipboard
#   clipboard-helper delete <id>   remove an entry from the history
#
# preview output: line 1 = kind (text|link|color|image|file|dir),
# line 2 = one-line description, line 3 = image to show (or empty),
# the rest = text body. Rendered previews (PDF/office/video) are cached in
# $XDG_RUNTIME_DIR, which is a per-user tmpfs, cleared at logout.

cache="${XDG_RUNTIME_DIR:-/tmp}/nixc-clipboard"
mkdir -p "$cache"

emit() { printf '%s\n%s\n%s\n' "$1" "$2" "$3"; }

# An image preview if the render worked, otherwise just the description.
emit_render() {
  if [ -s "$2" ]; then emit image "$1" "$2"; else emit file "$1" ""; fi
}

human() { numfmt --to=iec-i --suffix=B "$1"; }

# file:///a%20b -> /a b
uri_to_path() {
  local p="${1#file://}"
  printf '%b' "${p//%/\\x}"
}

# Text that is only file:// lines: Dolphin and other file managers copy
# files as a URI list.
is_uri_list() {
  [ -s "$1" ] && ! tr -d '\r' <"$1" | grep -v -e '^file://' -e '^$' >/dev/null
}

preview_path() {
  local f="$1" count="$2" more="" mime size key out meta pages tmp
  if [ "$count" -gt 1 ]; then more=" · +$((count - 1)) more"; fi

  if [ -d "$f" ]; then
    emit dir "$(basename "$f")/ · $(find "$f" -mindepth 1 -maxdepth 1 | wc -l) items$more" ""
    find "$f" -mindepth 1 -maxdepth 1 -printf '%f\n' | sort | head -n 300
    return
  fi
  if [ ! -e "$f" ]; then
    emit file "File no longer exists$more" ""
    printf '%s\n' "$f"
    return
  fi

  mime=$(file -bL --mime-type "$f")
  size=$(human "$(stat -Lc %s "$f")")
  meta="$(basename "$f") · $size$more"
  # Cache key: path + modification time, so an edited file re-renders.
  key=$(printf '%s %s' "$f" "$(stat -Lc %Y "$f")" | sha1sum | cut -c1-16)
  out="$cache/$key.png"

  case "$mime" in
    image/*)
      emit image "$meta" "$f"
      ;;
    application/pdf)
      [ -s "$out" ] || pdftoppm -png -singlefile -f 1 -l 1 -scale-to 1200 "$f" "${out%.png}" 2>/dev/null || true
      pages=$(pdfinfo "$f" 2>/dev/null | sed -n 's/^Pages: *//p')
      emit_render "$meta · ${pages:-?} pages" "$out"
      ;;
    video/*)
      [ -s "$out" ] || ffmpegthumbnailer -i "$f" -o "$out" -s 1200 -q 8 2>/dev/null || true
      emit_render "$meta" "$out"
      ;;
    application/msword | application/vnd.ms-* | application/rtf | text/rtf | \
      application/vnd.openxmlformats-officedocument.* | application/vnd.oasis.opendocument.*)
      # First page/slide via LibreOffice (if installed). Its own profile dir,
      # so this works while LibreOffice is open; first run takes a few seconds.
      if [ ! -s "$out" ] && command -v soffice >/dev/null; then
        tmp=$(mktemp -d "$cache/lo.XXXXXX")
        timeout 60 soffice -env:UserInstallation="file://$cache/lo-profile" \
          --headless --convert-to png --outdir "$tmp" "$f" >/dev/null 2>&1 || true
        for p in "$tmp"/*.png; do
          if [ -s "$p" ]; then mv "$p" "$out"; fi
        done
        rm -rf "$tmp"
      fi
      emit_render "$meta" "$out"
      ;;
    *)
      if [ "$(file -bL --mime-encoding "$f")" != binary ]; then
        emit text "$meta" ""
        head -c 20000 "$f"
      else
        emit file "$meta · $mime" ""
      fi
      ;;
  esac
}

preview() {
  local id="$1" mime img first lines chars
  local raw="$cache/$id.raw"
  cliphist decode "$id" >"$raw"
  mime=$(file -b --mime-type "$raw")

  case "$mime" in
    image/*)
      img="$cache/$id.${mime#image/}"
      mv "$raw" "$img"
      emit image "$(file -b "$img" | cut -d, -f1-2)" "$img"
      return
      ;;
  esac

  if is_uri_list "$raw"; then
    first=$(tr -d '\r' <"$raw" | grep -m1 '^file://')
    preview_path "$(uri_to_path "$first")" "$(grep -c '^file://' "$raw")"
  elif [ "$(wc -l <"$raw")" -le 1 ] && grep -Eq '^https?://[^[:space:]]+$' "$raw"; then
    emit link "Link" ""
    cat "$raw"
  elif [ "$(wc -l <"$raw")" -le 1 ] && grep -Eq '^#?([0-9A-Fa-f]{6}|[0-9A-Fa-f]{8})$' "$raw"; then
    emit color "Color" ""
    cat "$raw"
  else
    lines=$(($(wc -l <"$raw") + 1))
    chars=$(wc -m <"$raw")
    emit text "$lines lines · $chars characters" ""
    head -c 20000 "$raw"
  fi
  rm -f "$raw"
}

copy() {
  local raw="$cache/copy.raw"
  cliphist decode "$1" >"$raw"
  # Files go back as a URI list, so pasting into a file manager pastes files.
  if is_uri_list "$raw"; then
    wl-copy --type text/uri-list <"$raw"
  else
    wl-copy <"$raw"
  fi
  rm -f "$raw"
}

case "${1:-}" in
  list) cliphist list ;;
  preview) preview "$2" ;;
  copy) copy "$2" ;;
  delete)
    printf '%s\t\n' "$2" | cliphist delete
    rm -f "$cache/$2".*
    ;;
  *)
    echo "usage: clipboard-helper list|preview <id>|copy <id>|delete <id>" >&2
    exit 1
    ;;
esac
