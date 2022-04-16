fork_join(){
  ### Asynchronous execute <arg1:s_cmd> for all <args:array> as parameter
  ### <arg1:s_cmd> can have a $1 that will be replaced by each argument
  ### From: https://stackoverflow.com/a/20018504/2544873
  local s_cmd=$1; [[ $s_cmd =~ \$1 ]] || s_cmd+=' "$1"'
  local -a a_arg=("${@:2}")

  # Local
  local -a a_pid=()  # TODO
  local -A d_out=()
  # We start at 70 because 63 is used for process substitution
  # -- like:  echo <(echo 23)  # outputs: /dev/fd/63
  local -i i_fd=0 i i_fd_last=0 i_fd_first=70
  local s_arg



  # Spawn a thread per file
  # -- For all command
  # -- Get value -> file -> docstring -> fd
  for i in "${!a_arg[@]}"; do
    local s_cmd_cur=${s_cmd//\$1/${a_arg[$i]}}
    eval "exec $((i + i_fd_first))< <($s_cmd_cur)"
  done

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

  #print_args "${a_arg[@]}"
  #print_args "$@"
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && fork_join "$@"
