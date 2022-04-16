ps1_size(){
  # Ref1: https://stackoverflow.com/questions/3451993/how-to-expand-ps1
  >&2 echo -e "\nP0: Raw"
  local ps=$PS1
  echo -n "$ps" | xxd >&2 

  >&2 echo -e "\nP1: Expanding (require bash 4.4)"
  ps=${ps@P}
  echo -n "$ps" | xxd >&2 

  >&2 echo -e "\nP2: Removing everything 01 and 02"
  shopt -s extglob
  ps=${ps//$'\x01'*([^$'\x02'])$'\x02'}
  echo -n "$ps" | xxd >&2 

  >&2 echo -e "\nP3: Checking"
  if [[ "$ps" =~ [\x07\x1b\x9c] ]]; then
    # Check if escape inside
    # 07 => BEL
    # 1b => ESC
    # 9C => ST
    >&2 echo 'Warning: There is an escape code in your PS1 which is not betwwen \[ \]'
    >&2 echo "Tip: put \[ \] around your escape codes (ctlseqs + associated parameters)"
    echo -n "$ps" | xxd >&2
  # Check printable characters <= 20 .. 7e, and newline
  # -- Remove the trailing 0x0a (BEL)
  elif [[ "$ps" =~ [^[:graph:][:space:]] ]]; then
    >&2 echo 'Warning: There is a non printable character in PS1 which is not between \[ \]'
    >&2 echo "Tip: put \[ \] around your escape codes (ctlseqs + associated parameters)"
    echo "$ps"
    echo -n "$ps" | xxd >&2 
  fi

  # Echo result
  echo -n "${#ps}"
}

ps1_size
