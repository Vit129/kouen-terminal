#!/usr/bin/env bash
# Source from commit entrypoints after the final product/version edits.
prepare_graph_for_commit() {
  [[ -d graphify-out ]] || { echo "Graphify setup missing; stopping before commit." >&2; return 1; }
  PYTHONHASHSEED=0 graphify update . || return
  local tracked=() file
  while IFS= read -r -d '' file; do tracked+=("$file"); done < <(git ls-files -z -- graphify-out/)
  if ((${#tracked[@]})); then git add --update -- "${tracked[@]}" || return; fi
}

commit_with_graph() {
  prepare_graph_for_commit || return
  GRAPHIFY_SKIP_HOOK=1 git commit "$@"
}
