
for s_arg; do [[ "$s_arg" == -a ]] && b_append=1 && break; done
if (( b_append )); then
else
  while read -rN1; do
    echo -n "$REPLY"
    echo -n "$REPLY" > "$fp_in"
  done
fi
