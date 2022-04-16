#!/usr/bin/env bash
if [[ $# -eq 0 ]] ; then
    echo 'Bonjour Marcheur Blanc!'
    #exit 0
fi

i=0
for var in "$@"
do
    echo "Bonjour $i: $var!"
    ((i++))
done


echo -e "
91 word $COMP_WORDS
92 cword $COMP_CWORD
93 line $COMP_LINE
"
