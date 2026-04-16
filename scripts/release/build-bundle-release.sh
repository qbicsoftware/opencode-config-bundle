#!/bin/sh

set -eu

usage() {
  cat <<EOF
Usage: build-bundle-release.sh --tag <tag> [--output-dir <dir>]
EOF
}

sha256_file() {
  file=$1
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$file" | awk '{print $1}'
  else
    shasum -a 256 "$file" | awk '{print $1}'
  fi
}

TAG=
OUTPUT_DIR=${PWD}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --tag)
      shift
      TAG=${1:-}
      ;;
    --output-dir)
      shift
      OUTPUT_DIR=${1:-}
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'error: unknown option: %s\n' "$1" >&2
      usage >&2
      exit 1
      ;;
  esac
  shift
done

[ -n "$TAG" ] || { printf 'error: --tag is required\n' >&2; exit 1; }

SCRIPT_DIR=$(CDPATH= cd "$(dirname "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd "$SCRIPT_DIR/../.." && pwd)
OUTPUT_DIR=$(mkdir -p "$OUTPUT_DIR" && CDPATH= cd "$OUTPUT_DIR" && pwd)

BUNDLE_ROOT="opencode-config-bundle-$TAG"
ARCHIVE_NAME="$BUNDLE_ROOT.tar.gz"
CHECKSUMS_NAME="$BUNDLE_ROOT-checksums.txt"

TMP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/opencode-config-bundle.XXXXXX")
trap 'rm -rf "$TMP_DIR"' EXIT INT TERM

STAGE_ROOT="$TMP_DIR/$BUNDLE_ROOT"
mkdir -p "$STAGE_ROOT/.opencode/schemas"
mkdir -p "$STAGE_ROOT/prompts"

cp "$REPO_ROOT/prompts/agent-architect.txt" "$STAGE_ROOT/prompts/agent-architect.txt"
cp "$REPO_ROOT/prompts/code-reviewer.txt" "$STAGE_ROOT/prompts/code-reviewer.txt"
cp "$REPO_ROOT/prompts/coding-boss.txt" "$STAGE_ROOT/prompts/coding-boss.txt"
cp "$REPO_ROOT/prompts/docs-planner.txt" "$STAGE_ROOT/prompts/docs-planner.txt"
cp "$REPO_ROOT/prompts/docs-reviewer.txt" "$STAGE_ROOT/prompts/docs-reviewer.txt"
cp "$REPO_ROOT/prompts/docs-writer-fast.txt" "$STAGE_ROOT/prompts/docs-writer-fast.txt"
cp "$REPO_ROOT/prompts/docs.txt" "$STAGE_ROOT/prompts/docs.txt"
cp "$REPO_ROOT/prompts/implementer-small.txt" "$STAGE_ROOT/prompts/implementer-small.txt"
cp "$REPO_ROOT/prompts/implementer.txt" "$STAGE_ROOT/prompts/implementer.txt"
cp "$REPO_ROOT/prompts/planner.txt" "$STAGE_ROOT/prompts/planner.txt"

cp "$REPO_ROOT/opencode.openai.json" "$STAGE_ROOT/opencode.openai.json"
cp "$REPO_ROOT/opencode.mixed.json" "$STAGE_ROOT/opencode.mixed.json"
cp "$REPO_ROOT/opencode.big-pickle.json" "$STAGE_ROOT/opencode.big-pickle.json"
cp "$REPO_ROOT/opencode.minimax.json" "$STAGE_ROOT/opencode.minimax.json"
cp "$REPO_ROOT/opencode.kimi.json" "$STAGE_ROOT/opencode.kimi.json"
cp "$REPO_ROOT/.opencode/schemas/handoff.schema.json" "$STAGE_ROOT/.opencode/schemas/handoff.schema.json"
cp "$REPO_ROOT/.opencode/schemas/result.schema.json" "$STAGE_ROOT/.opencode/schemas/result.schema.json"

cat > "$STAGE_ROOT/opencode-bundle.manifest.json" <<EOF
{
  "manifest_version": "1.0.0",
  "bundle_name": "qbic-opencode-config-bundle",
  "bundle_version": "$TAG",
  "source_repo": "https://github.com/qbicsoftware/opencode-config-bundle",
  "release_tag": "$TAG",
  "presets": [
    {
      "name": "openai",
      "description": "OpenAI-based multi-tier agent configuration with planning-first workflow",
      "entrypoint": "opencode.openai.json",
      "prompt_files": [
        "prompts/coding-boss.txt",
        "prompts/planner.txt",
        "prompts/implementer-small.txt",
        "prompts/implementer.txt",
        "prompts/code-reviewer.txt",
        "prompts/docs.txt",
        "prompts/docs-planner.txt",
        "prompts/docs-writer-fast.txt",
        "prompts/docs-reviewer.txt",
        "prompts/agent-architect.txt"
      ]
    },
    {
      "name": "mixed",
      "description": "Mixed model stack (Claude for routing/planning/review, Codex for execution)",
      "entrypoint": "opencode.mixed.json",
      "prompt_files": [
        "prompts/coding-boss.txt",
        "prompts/planner.txt",
        "prompts/implementer-small.txt",
        "prompts/implementer.txt",
        "prompts/code-reviewer.txt",
        "prompts/docs.txt",
        "prompts/docs-planner.txt",
        "prompts/docs-writer-fast.txt",
        "prompts/docs-reviewer.txt",
        "prompts/agent-architect.txt"
      ]
    },
    {
      "name": "kimi",
      "description": "Kimi-based multi-tier agent configuration",
      "entrypoint": "opencode.kimi.json",
      "prompt_files": [
        "prompts/coding-boss.txt",
        "prompts/planner.txt",
        "prompts/implementer-small.txt",
        "prompts/implementer.txt",
        "prompts/code-reviewer.txt",
        "prompts/docs.txt",
        "prompts/docs-planner.txt",
        "prompts/docs-writer-fast.txt",
        "prompts/docs-reviewer.txt",
        "prompts/agent-architect.txt"
      ]
    },
    {
      "name": "big-pickle",
      "description": "Big Pickle model-based multi-tier agent configuration",
      "entrypoint": "opencode.big-pickle.json",
      "prompt_files": [
        "prompts/coding-boss.txt",
        "prompts/planner.txt",
        "prompts/implementer-small.txt",
        "prompts/implementer.txt",
        "prompts/code-reviewer.txt",
        "prompts/docs.txt",
        "prompts/docs-planner.txt",
        "prompts/docs-writer-fast.txt",
        "prompts/docs-reviewer.txt",
        "prompts/agent-architect.txt"
      ]
    },
    {
      "name": "minimax",
      "description": "MiniMax-based multi-tier agent configuration",
      "entrypoint": "opencode.minimax.json",
      "prompt_files": [
        "prompts/coding-boss.txt",
        "prompts/planner.txt",
        "prompts/implementer-small.txt",
        "prompts/implementer.txt",
        "prompts/code-reviewer.txt",
        "prompts/docs.txt",
        "prompts/docs-planner.txt",
        "prompts/docs-writer-fast.txt",
        "prompts/docs-reviewer.txt",
        "prompts/agent-architect.txt"
      ]
    }
  ]
}
EOF

touch -t 198001010000 "$STAGE_ROOT" "$STAGE_ROOT/.opencode" "$STAGE_ROOT/.opencode/schemas"
touch -t 198001010000 "$STAGE_ROOT/prompts"
touch -t 198001010000 "$STAGE_ROOT/opencode-bundle.manifest.json"
touch -t 198001010000 "$STAGE_ROOT/opencode.openai.json" "$STAGE_ROOT/opencode.mixed.json"
touch -t 198001010000 "$STAGE_ROOT/opencode.big-pickle.json" "$STAGE_ROOT/opencode.minimax.json" "$STAGE_ROOT/opencode.kimi.json"
touch -t 198001010000 "$STAGE_ROOT/.opencode/schemas/handoff.schema.json" "$STAGE_ROOT/.opencode/schemas/result.schema.json"
touch -t 198001010000 "$STAGE_ROOT/prompts/agent-architect.txt" "$STAGE_ROOT/prompts/code-reviewer.txt" "$STAGE_ROOT/prompts/coding-boss.txt" "$STAGE_ROOT/prompts/docs-planner.txt" "$STAGE_ROOT/prompts/docs-reviewer.txt" "$STAGE_ROOT/prompts/docs-writer-fast.txt" "$STAGE_ROOT/prompts/docs.txt" "$STAGE_ROOT/prompts/implementer-small.txt" "$STAGE_ROOT/prompts/implementer.txt" "$STAGE_ROOT/prompts/planner.txt"

LIST_FILE="$TMP_DIR/tar.list"
cat > "$LIST_FILE" <<EOF
$BUNDLE_ROOT
$BUNDLE_ROOT/opencode-bundle.manifest.json
$BUNDLE_ROOT/opencode.openai.json
$BUNDLE_ROOT/opencode.mixed.json
$BUNDLE_ROOT/opencode.big-pickle.json
$BUNDLE_ROOT/opencode.minimax.json
$BUNDLE_ROOT/opencode.kimi.json
$BUNDLE_ROOT/.opencode
$BUNDLE_ROOT/.opencode/schemas
$BUNDLE_ROOT/.opencode/schemas/handoff.schema.json
$BUNDLE_ROOT/.opencode/schemas/result.schema.json
$BUNDLE_ROOT/prompts
$BUNDLE_ROOT/prompts/agent-architect.txt
$BUNDLE_ROOT/prompts/code-reviewer.txt
$BUNDLE_ROOT/prompts/coding-boss.txt
$BUNDLE_ROOT/prompts/docs-planner.txt
$BUNDLE_ROOT/prompts/docs-reviewer.txt
$BUNDLE_ROOT/prompts/docs-writer-fast.txt
$BUNDLE_ROOT/prompts/docs.txt
$BUNDLE_ROOT/prompts/implementer-small.txt
$BUNDLE_ROOT/prompts/implementer.txt
$BUNDLE_ROOT/prompts/planner.txt
EOF

TAR_NO_RECURSION=
if tar --help 2>/dev/null | grep -q -- '--no-recursion'; then
  TAR_NO_RECURSION="--no-recursion"
fi

if tar --help 2>/dev/null | grep -q -- '--uid'; then
  tar $TAR_NO_RECURSION --format=ustar --uid 0 --gid 0 --uname root --gname root -cf "$TMP_DIR/bundle.tar" -C "$TMP_DIR" -T "$LIST_FILE"
elif tar --help 2>/dev/null | grep -q -- '--owner'; then
  tar $TAR_NO_RECURSION --format=ustar --owner 0 --group 0 --numeric-owner -cf "$TMP_DIR/bundle.tar" -C "$TMP_DIR" -T "$LIST_FILE"
else
  tar $TAR_NO_RECURSION --format=ustar -cf "$TMP_DIR/bundle.tar" -C "$TMP_DIR" -T "$LIST_FILE"
fi

ARCHIVE_PATH="$OUTPUT_DIR/$ARCHIVE_NAME"
gzip -n -c "$TMP_DIR/bundle.tar" > "$ARCHIVE_PATH"

ARCHIVE_SHA=$(sha256_file "$ARCHIVE_PATH")
printf '%s  %s\n' "$ARCHIVE_SHA" "$ARCHIVE_NAME" > "$OUTPUT_DIR/$CHECKSUMS_NAME"

printf '%s\n' "$ARCHIVE_PATH"
printf '%s\n' "$OUTPUT_DIR/$CHECKSUMS_NAME"
