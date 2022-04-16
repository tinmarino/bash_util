cat /tmp/foo
:>/tmp/foo
exec 3<> /tmp/foo  # open fd 3 (truncate)

echo test1 >&3  # write to fd 3
>&3 echo test2  # write to fd 3
0<&3 read line; echo "$line"
read -u 3 line; echo "$line"
{ exec < /dev/stdin; cat; } <&3
{ exec < /dev/stdin; cat; } <&70
eval "{ exec < /dev/stdin; cat; } <&3"
{ exec < /dev/stdin; read -u 70 line; echo "LINE: $line|"; }
cat - <&3  # read from fd 3
<&3 cat -
exec 3>&-  # close fd 3


echo Line $line
# 
# for i in 1 2 3; do read line <&3; echo "$line"; done

show_fseek(){
  :>/tmp/foo
  exec 3<> /tmp/foo  # open fd 3 (truncate)
  echo test1 >&3  # write to fd 3
  echo test2 >&3  # write to fd 3
  { exec < /dev/stdin; cat; } <&3

  read -u 3 line; echo "Line: $line"
  echo test3 >&3  # write to fd 3
  { exec < /dev/stdin; buffer; } <&3

  exec 3>&-  # close fd 3
}
