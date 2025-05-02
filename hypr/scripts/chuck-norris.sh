#!/bin/bash

cache_file="$HOME/.cache/chuck-norris"


if [ ! -f $cache_file ];then
    touch $cache_file
fi

if ping -c 1 8.8.8.8 &> /dev/null;then
    joke=$(curl -s https://api.chucknorris.io/jokes/random | jq -r '.value')
    echo "$joke" | fold -s -w 50
    echo "$joke" > "$cache_file"
else
    joke=$(cat "$cache_file")
    echo "$joke" | fold -s -w 50
fi



