function teee(){
  ### Imitate tee command. Usage echo 42 | teee -a file1.txt file2.txt
  local a_file=(/dev/stdout) b_append=1 arg fp
  for arg; do [[ "$arg" == -a ]] && b_append=1 || a_file+=("$arg"); done
  (( b_append )) || : > "$1"
  while read -rn1 -d $'\0'; do
    (( ${#REPLY} == 0 )) && { for fp in "${a_file[@]}"; do printf '\0' >> "$fp"; done; continue; }
    for fp in "${a_file[@]}"; do echo -n "$REPLY" >> "$fp"; done
  done
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && teee "$@"
