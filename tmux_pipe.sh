tmux_pipe(){
  exec cat - \
    | awk -v date="$(date "+%Y-%m-%dT%H:%M:%S")" -v pre="${1##/dev/}" '{
      gsub(/\x1B][0-9];/, "");
      gsub(/\x0d/, "");
      gsub(/\x1B\[[0-9;?>]*[mKHhlC]/, "");
      print pre " " date " " $0
    }' >> "$HOME"/Test/tmux.log
}

tmux pipe-pane "$(declare -f tmux_pipe); tmux_pipe \"$(tty)\""


old(){
tmux pipe-pane "ansi=\"\\x1B\\[[0-9;?>]*[mKHhlC]\";
  pre=\"$(tty)\";
  pre=\${pre##/dev/};
  exec cat - \
    | awk -v date=\"\$(date \"+%Y-%m-%dT%H:%M:%S\")\" -v pre=\"\$pre\" -v ansi=\"\$ansi\" '{
      gsub(/\x1B][0-9];/,\"\");
      gsub(/\x0d/,\"\");
      gsub(ansi,\"\");
      print pre \" \" date \" \" \$0
    }' >> $HOME/Test/tmux.log"

  : " Inspired from: https://github.com/tmux-plugins/tmux-logging/blob/master/scripts/start_logging.sh
  "
  # 	tmux pipe-pane "exec cat - | sed -r 's/$ansi_codes//g' >> $FILE"
  # tmux  pipe-pane -o 'cat >>~/output.#I-#P'
  #date "+%Y-%m-%dT%H:%M:%S"
  #echo -e "**\e[31mRed\e[0m**" |
  #awk "{gsub(/$ansi_codes/,\"\"); print \"$(date "+%Y-%m-%dT%H:%M:%S") \" \$0}"

  ansi_codes="(\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]|)"

  tmux pipe-pane "exec cat - | awk '{ gsub(/\x1B][0-9];/,\"\"); gsub(/\x0d/,\"\"); gsub(/$ansi_codes/,\"\"); print \"$pre\" \$0 }' >> $HOME/Test/tmux.log"

  tmux pipe-pane "exec cat - >> $HOME/Test/tmux.log"

  eval "echo -e \"**\e[31mRed\e[0m**\e]titi\" \
    | awk '{
      gsub(/$ansi_codes/,\"\");
      gsub(/][0-9];/,\"\");
      gsub(/\x0d;/,\"\n\");
      print \"$pre\" \$0
    }' \
  "
}
