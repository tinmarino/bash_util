# shellcheck disable=SC2059  # Don't use variables in 
# From https://www.runscripts.com/support/guides/scripting/bash/debugging-bash/stack-trace

gs_root_path=$(readlink -f "${BASH_SOURCE[0]}")
gs_root_path=$(dirname "$gs_root_path");

# Source the dipatcher utility
source "$gs_root_path/test_stacktrace.sh"

stacktrace ()
{
   declare frame=0
   declare argv_offset=0

   while caller_info=( $(caller $frame) ) ; do

       if shopt -q extdebug ; then

           declare argv=()
           declare argc
           declare frame_argc

           for ((frame_argc=${BASH_ARGC[frame]},frame_argc--,argc=0; frame_argc >= 0; argc++, frame_argc--)) ; do
               argv[argc]=${BASH_ARGV[argv_offset+frame_argc]}
               case "${argv[argc]}" in
                   *[[:space:]]*) argv[argc]="'${argv[argc]}'" ;;
               esac
           done
           argv_offset=$((argv_offset + ${BASH_ARGC[frame]}))
           echo ":: ${caller_info[2]}: Line ${caller_info[0]}: ${caller_info[1]}(): ${FUNCNAME[frame]} ${argv[*]}"
       fi

       frame=$((frame+1))
   done

   if [[ $frame -eq 1 ]] ; then
       caller_info=( $(caller 0) )
       echo ":: ${caller_info[2]}: Line ${caller_info[0]}: ${caller_info[1]}"
   fi
}

spawn(){
  # Fork
  for i in {0..10}; do ((i_fd=i+100))
     "exec $i_fd< <(echo message \"$i_fd\")"
  done

  # Join thread and append docstring -> dictionarie
  for i in {0..10}; do ((i_fd=i+100))
    a_out[$i]=$(cat <&"$i_fd")
  done

  IFS=$'\n' echo "${a_out[*]}"
}

spawn(){
  # From: https://stackoverflow.com/a/20018504/2544873
  local a_pid=()
  local i_fd cmd i_fd_last
  # We start at 70 because 63 is used for process substitution
  # -- like:  echo <(echo 23)  # outputs: /dev/fd/63
  local i_fd_first=70

  # Spawn a thread per file
  # -- For all command
  # -- Get value -> file -> docstring -> fd
  i_fd=$i_fd_first
  for cmd in "${!gd_cmd[@]}"; do
    local file=${gd_cmd[$cmd]}
    eval "exec $i_fd< <(get_file_docstring \"$file\" long)"
    a_pid+=($!)
    ((i_fd++))
  done

  # Join thread and append docstring -> dictionarie
  i_fd=$i_fd_first
  for cmd in "${!gd_cmd[@]}"; do
    gd_fct[$cmd]=$(cat <&$i_fd)
    ((i_fd++))
  done

  # Close file descriptor
  (( i_fd_last = i_fd_first + ${#gd_cmd[@]} ))
  for (( i_fd=i_fd_first; i_fd <= i_fd_last; i_fd++ )); do
    eval "exec $i_fd<&-"
  done
}





bidon(){
  : "Register subcommands and their docstring
  Global: gd_cmd <out>"
  # From: https://stackoverflow.com/a/20018504/2544873
  local a_pid=()
  local i_fd cmd i_fd_last
  # We start at 70 because 63 is used for process substitution
  # -- like:  echo <(echo 23)  # outputs: /dev/fd/63
  local i_fd_first=70

  # Spawn a thread per file
  # -- For all command
  # -- Get value -> file -> docstring -> fd
  i_fd=$i_fd_first
  for cmd in "${!gd_cmd[@]}"; do
    local file=${gd_cmd[$cmd]}
    eval "exec $i_fd< <(get_file_docstring \"$file\" long)"
    a_pid+=($!)
    ((i_fd++))
  done

  # Join thread and append docstring -> dictionarie
  i_fd=$i_fd_first
  for cmd in "${!gd_cmd[@]}"; do
    gd_fct[$cmd]=$(cat <&$i_fd)
    ((i_fd++))
  done

  # Close file descriptor
  (( i_fd_last = i_fd_first + ${#gd_cmd[@]} ))
  for (( i_fd=i_fd_first; i_fd <= i_fd_last; i_fd++ )); do
    eval "exec $i_fd<&-"
  done
}


print_stack(){
  ### Print current stack trace to stderr
  local -i i=0 j=0 k=0
  local fstg="| %-3s | %-25s | %-20s | %-4s | %-15s |\n"
  >&2 printf "$fstg" N Function File Line Arguments
  >&2 printf "$fstg" --- --- --- --- ---
  for i in "${!FUNCNAME[@]}"; do
    local -a a_argv=(); shopt -q extdebug && { local argc=${BASH_ARGC[i]}; for ((j=0; j<argc; j++)); do a_argv[$((argc-j))]=${BASH_ARGV[$((k++))]}; done; }
    >&2 printf "$fstg" "$i" "${FUNCNAME[$i]}" "${BASH_SOURCE[$i]}" "${BASH_LINENO[$i]}" "${a_argv[*]}"
  done
  shopt -q extdebug || >&2 printf "# Note: run 'shopt -s extdebug' to see call arguments\n"
}


stacktrace ()
{
   declare frame=0
   declare argv_offset=0

   while caller_info=( $(caller $frame) ) ; do

       if shopt -q extdebug ; then

           declare argv=()
           declare argc
           declare frame_argc

           for ((frame_argc=${BASH_ARGC[frame]},frame_argc--,argc=0; frame_argc >= 0; argc++, frame_argc--)) ; do
               argv[argc]=${BASH_ARGV[argv_offset+frame_argc]}
               case "${argv[argc]}" in
                   *[[:space:]]*) argv[argc]="'${argv[argc]}'" ;;
               esac
           done
           argv_offset=$((argv_offset + ${BASH_ARGC[frame]}))
           echo ":: ${caller_info[2]}: Line ${caller_info[0]}: ${caller_info[1]}(): ${FUNCNAME[frame]} ${argv[*]}"
       fi

       frame=$((frame+1))
   done

   if [[ $frame -eq 1 ]] ; then
       caller_info=( $(caller 0) )
       echo ":: ${caller_info[2]}: Line ${caller_info[0]}: ${caller_info[1]}"
   fi
}


bidon(){
  pad=$(printf '%0.1s' "-"{1..60})
  padlength=40
  string2='bbbbbbb'
  for string1 in a aa aaaa aaaaaaaa
  do
       printf '%s' "$string1"
       printf '%*.*s' 0 $((padlength - ${#string1} - ${#string2} )) "$pad"
       printf '%s\n' "$string2"
       string2=${string2:1}
  done
}
