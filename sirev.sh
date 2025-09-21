#!/bin/bash

if [[ "${1,,}" =~ ^(h|help)$ ]]; then
    echo "Usage: "
    echo "bash $0            --  Check the whole lobby"
    echo "bash $0 p Player1  --  Only check the given player"
    echo "bash $0 h          --  Displays this usage output"
    exit
elif [[ "$1" == "setup" && -f "msys2_shell.cmd" ]]; then
    echo "msys2_shell.cmd -defterm -no-start -here -c \"bash sirev.sh; read -p 'Press enter to close...' z\"" > " sirev.bat"
    wget https://github.com/lexiforest/curl-impersonate/releases/download/v1.2.2/libcurl-impersonate-v1.2.2.x86_64-win32.tar.gz -O curl.tar.gz
    rm /bin/curl.exe
    tar -xf curl.tar.gz ./bin/curl.exe
    mv bin/curl.exe /curl.exe
    rm -r setup.bat curl.tar.gz
fi

## Tracker Network Endpoint
tne="https://api.tracker.gg/api/v2/r6siege/standard/profile/ubi"
## Chrome Impersonate Binary
cib="./curl"
## Temporary File Name
tfn="$(date +%s)"
## Match Replay Location
mrl="/mnt/e/Tom Clancy's Rainbow Six Siege/MatchReplay"
## Edit variables if using msys2
if [[ -f "msys2.exe" ]]; then
    cib="/curl.exe"
    mrl="$(echo "$mrl" | sed 's|^/mnt||')"
fi
## Current Match Directory
cmd="$(ls -l "$mrl" | tail -n1 | sed 's/.* //')"

clean(){
    rm -f "$tfn-1.txt" "$tfn-2.txt" "$tfn-3.txt"
}

strings "$mrl/$cmd/$cmd-R01.rec" > "$tfn-1.txt"
## Located Line Number
lln="$(grep -n "teamscore1" "$tfn-1.txt" | tail -n1 | sed 's/:.*//')"
sed -i "${lln},\$d" "$tfn-1.txt"
tr '\n' ',' < "$tfn-1.txt" | tr -d $'\t' > "$tfn-2.txt"
sed -i 's/profileid\$/\nprofileid/g' "$tfn-2.txt"
sed -i '7d;1d' "$tfn-2.txt"
## Single Out Player
sop="$(grep -i -- "$2" "$tfn-2.txt")"
if [[ "${1,,}" == "p" && -n "$sop" ]]; then
    echo "$sop" > "$tfn-2.txt"
elif [[ "${1,,}" == "p" && -z "$sop" ]]; then
    echo "Player \"$2\" does not exist."
    clean
    exit
fi
sed -i 's/profileid,/UID: /g; s/,/\n/' "$tfn-2.txt"
sed -i 's/.*playername,team,heroname/playername,BLANK_NAME_BUG/g' "$tfn-2.txt" ##Catch the blank name bug
sed -i 's/.*playername,/Name: /g; s/,/\n/' "$tfn-2.txt"
sed -i 's/.*rolename,/Op: /g; s/,/\n\n/' "$tfn-2.txt"
sed -i '/,/d; /roleportrait/d' "$tfn-2.txt"
sed -i '$d' "$tfn-2.txt"
cp "$tfn-2.txt" "$tfn-3.txt"
sed -i '/UID:\|Name:/!d' "$tfn-3.txt"
tr -d '\n' < "$tfn-3.txt" > "$tfn-1.txt"
sed -i 's/UID: /\n/g; s/Name: /:/g' "$tfn-1.txt"
sed -i '1d'  "$tfn-1.txt"
echo >> "$tfn-1.txt"
while read -r line; do
    uid="$(echo "$line" | sed 's/:.*//')"
    nam="$(echo "$line" | sed 's/.*://')"
    "$cib" -sk -H "User-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36" "$tne/$uid" > "$tfn-3.txt"
    sed -i 's/platformSlug/\nplatformSlug/g' "$tfn-3.txt"
    sed -i 's/","platformUserIdentifier.*//g; /"data":/d' "$tfn-3.txt"
    sed -i 's/",".*":"/:/g' "$tfn-3.txt"
    sed -i 's/.*":"//g; /^ubi:\|^psn:\|^xbl:/!d' "$tfn-3.txt"
    awk '!a[$0]++' "$tfn-3.txt" > "$tfn" && mv "$tfn" "$tfn-3.txt"
    ubi="$(sed -n 's/^ubi://p' "$tfn-3.txt")"
    psn="$(sed -n 's/^psn://p' "$tfn-3.txt")"
    xbl="$(sed -n 's/^xbl://p' "$tfn-3.txt")"
    unset rng inh
    if [[ -z "$(grep -i -- "$nam" "$tfn-3.txt")" ]]; then
        rng="\nReal Name: $ubi"
    fi
    if [[ "${ubi,,}" == "${nam,,}" && "${xbl,,}" == "${nam,,}" && "${psn,,}" == "${nam,,}" ]]; then
        if [[ -z "$rng" ]]; then
            rng="\nReal Name: $ubi"
        fi
        rng="$rng\nPlatform: Unknown"
    elif [[ "${ubi,,}" != "${nam,,}" && "${xbl,,}" == "${nam,,}" && "${psn,,}" == "${nam,,}" ]]; then
        rng="$rng\nPlatform: Console"
    elif [[ "${ubi,,}" != "${nam,,}" && "${xbl,,}" == "${nam,,}" && "${psn}" != "${nam,,}" ]]; then
        rng="$rng\nPlatform: Xbox"
    elif [[ "${ubi,,}" != "${nam,,}" && "${xbl,,}" != "${nam,,}" && "${psn,,}" == "${nam,,}" ]]; then
        rng="$rng\nPlatform: PSN"
    fi
    if [[ -n "$rng" ]]; then
        sed -i "s/$uid/$uid$rng/g" "$tfn-2.txt"
    fi
done < "$tfn-1.txt"
cat "$tfn-2.txt"
clean
#https://r6.tracker.network/r6siege/profile/ubi/*UID*/overview
