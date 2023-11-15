#!/bin/bash

# exits if env variables are not set
set -e


while true
do
    # exit if ngrok is already running
    if pgrep -x "ngrok" > /dev/null
    then
        echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] ngrok is already running"
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] starting ngrok"
        ngrok authtoken $NGROK_AUTHTOKEN
        ngrok tcp $MINECRAFT_PORT --log=stdout >/dev/null &
        sleep 1
        PUBLIC_URL=$(curl -sS http://localhost:4040/api/tunnels | jq -r '.tunnels[0].public_url')

        IFS=":"
        array=($PUBLIC_URL)
        unset IFS;
        PORT=${array[2]}
        URL="${array[1]#??}"

        curl -X PATCH "https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID/dns_records/$CLOUDFLARE_DNS_RECORD_ID" \
        -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
        -H "Content-Type: application/json" \
        -d '{
            "data" : {
            "port": '$PORT',
            "target": "'$URL'"
            }
        }'
        echo
    fi
    sleep 15
done
