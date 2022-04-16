# We start at 70 because 63 is used for process substitution
# -- like:  echo <(echo 23)  # outputs: /dev/fd/63
declare -i i_fd_first=70

fork_join(){
  forkall "$@"
  joinall "$@"
}

forkall(){
  ### Asynchronous execute <arg1:s_cmd> for all <args:array> as parameter
  ### <arg1:s_cmd> can have a $1 that will be replaced by each argument
  ### From: https://stackoverflow.com/a/20018504/2544873
  local s_cmd=$1; [[ $s_cmd =~ \$1 ]] || s_cmd+=' "$1"'
  local -a a_arg=("${@:2}")

  # Local
  local -a a_pid=()  # TODO

  # Spawn a thread per file
  # -- For all command
  # -- Get value -> file -> docstring -> fd
  for i in "${!a_arg[@]}"; do
    local s_cmd_cur=${s_cmd//\$1/${a_arg[$i]}}
    >&2 printf '%02d: %s\n' "$i" "$s_cmd_cur"
    eval "exec $((i + i_fd_first))< <($s_cmd_cur)"
  done

}

joinall(){
  local -A d_out=()
  local -i i=0

  # Join thread and append docstring -> dictionarie
  for i in "${!a_arg[@]}"; do
    echo Join 1
    d_out[$i]=$(cat <&$((i + i_fd_first)))
  done

  # Close file descriptor
  for i in "${!a_arg[@]}"; do
    eval "exec $((i + i_fd_first))<&-"
  done

  # Print
  for i in "${!d_out[@]}"; do
    echo "$i: ${d_out[$i]}"
  done
}

spy(){
  ### Read fd in subshell => do not tuch write fd
  echo "Tin Shell $BASH_SUBSHELL"
  (
  echo "Tin Subshell $BASH_SUBSHELL"
  local -i i=0
  for i in "$@"; do
    eval "(
      cat &
    ) <&$((i + i_fd_first))"
  done
  )
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && fork_join "$@"
