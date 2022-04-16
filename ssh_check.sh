#!/usr/bin/env bash

if [[ ! -r ~/.ssh/authorized_keys ]]; then
  echo -e "[-] Error: file ~/.ssh/authorized_keys must exists"
else
  echo -e "[+] ~/.ssh/authorized_keys exists"
fi

sp_home=$(stat -c '%A' ~)
if ! grep -q 'drwx.-..-.' <<< "$sp_home"; then
  echo -e "[-] Error: Home directory do not have the good rights ($sp_home).
    It must be writable by owner but not group and all
    Run: chmod 755 ~"
else 
  echo -e "[+] ~"
fi

sp_ssh=$(stat -c '%A' ~/.ssh)
if ! grep -q 'drwx------' <<< "$sp_ssh"; then
  echo -e "[-] Error: ~/.ssh directory do not have the good rights ($sp_ssh)
    It must be writable by owner but not group and all
    Run: chmod 0700 ~/.ssh"
else
  echo -e "[+] ~/.ssh"
fi

sp_authorized=$(stat -c '%A' ~/.ssh/authorized_keys)
if ! grep -q '.rw..-..-.' <<< "$sp_authorized"; then
  echo -e "[-] Error: ~/.ssh/authorized_keys directory do not have the good rights ($sp_authorized)
    Run: chmod 0600 ~/.ssh/authorized_keys"
else
  echo -e "[+] ~/.ssh/authorized_keys"
fi
