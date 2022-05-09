
test_print_stack(){
  second(){ print_stack_alma; }
  first(){ second toto; }
  first arg_first "$@"
}

print_stack_alma(){
  : "Print current stack trace, tested
  From: https://stackoverflow.com/a/2990533/254487"
  local -i i_init=${1:-0}
  local -i i_end=${2:-5}
  local -i i_indent=${3:-2}
  local lnum=${4:-5}  # Number of lines for the first frame
  local -i b_first_loop=1
  local -i i_frame=0
  local -i j=0 k=0

  # Warn can see more
  shopt -q extdebug || echo "# Note: run 'shopt -s extdebug' to see call arguments"

  # For each frame
  for i_frame in $(seq "$i_init" "$i_end"); do
    # Clause fo not work after stack size
    [[ ! -v BASH_LINENO ]] && break
    (( i_frame > ${#BASH_LINENO[@]} )) && break
    (( i_frame > ${#FUNCNAME[@]} )) && break

    # Get lines number of code to print
    local line_nr="${BASH_LINENO[$i_frame-1]}"
    if (( b_first_loop )); then
      # Take the lnum lines above for the first call in stack
      line_nr="$(( ret = line_nr - lnum, ret > 1 ? ret : 1 )),$line_nr"
      b_first_loop=0
    fi

    # Inspect
    local pad="$(printf "%${i_indent}s" "")"
    local fct="${FUNCNAME[$i_frame]:-main}"
    local file="${BASH_SOURCE[$i_frame]:-terminal}"
    local line=""
    ((line_nr != 0)) && {
      line="$({ [[ -r "$file" ]] && cat "$file" || echo "# No line info"; } \
      | sed -nE "${line_nr}s/^ */$pad/gp")"
    }

    # Inspect argument
    local -a a_argv=()
    if shopt -q extdebug; then
      local argc=${BASH_ARGC[i_frame]}
      #>&2 echo "Tin argc $argc"
      #>&2 print_args "${BASH_ARGV[@]}"
      for ((j=0; j<argc; j++)); do
        (( k >= ${#BASH_ARGV[@]} )) && break
        a_argv[$((argc-j))]=${BASH_ARGV[$((k++))]}
      done
    fi
    local argv=$(join_by ', ' "${a_argv[@]}")

    # Craft message
    local msg="in "
    msg+="${cblue}Function:$cend $fct($argv), "
    msg+="${cblue}File:$cend $file, "
    msg+="${cblue}Line:$cend $line_nr\n"

    # Print
    printf "%s" "$(abat "" <<< "$line")"
    printf "%${i_indent}s" ""
    printf "        %b\n" "$msg"
    ((i_indent+=2))
  done
}

join_by(){
  : "join_by $'\n' a b c #a<newline>b<newline>c, tested
  From: https://stackoverflow.com/a/17841619/2544873"
  local d=${1-} f=${2-}
  if shift 2; then
    printf %s "$f" "${@/#/$d}"
  fi
}

abat(){
  : "Filter to color code, tested"
  local lang="${1:-bash}"
  # Clause: bat must exists
  if ! command -v bat &> /dev/null; then
    echo -en "$cyellow"; cat -; echo -en "$cend"; return 0;
  fi
  bat --style plain --color always --pager "" --theme zenburn --language "$lang" - | perl -p -e 'chomp if eof'; return 0
}

