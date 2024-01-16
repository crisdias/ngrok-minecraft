# Minecraft Server DNS Updater

## Overview
This service ensures that your Minecraft server running on a dynamic IP address remains accessible to players. It leverages `ngrok` to expose your local Minecraft server to the internet and `jq` to parse the ngrok public URL. It then updates the DNS records on Cloudflare, allowing players to connect to your server using a friendly domain name instead of a numeric IP address.

Us this to run a public Minecraft server without exposing your home network.

This setup is based on [this article](https://medium.com/@oliverbravery/publically-exposing-tcp-ports-with-static-url-without-port-forwarding-9ddd32ca2726) by Oliver Bravery.

## Features
- **Automatic ngrok Tunnel Creation**: Sets up a secure ngrok tunnel for the Minecraft server.
- **Dynamic DNS Update**: Automatically updates Cloudflare DNS records with the new ngrok tunnel information.
- **Alpine-Based Lightweight Container**: The entire service runs within a Docker container based on the lightweight Alpine Linux.

## How It Works
1. The service starts an ngrok tunnel to the Minecraft server.
2. It retrieves the public URL assigned by ngrok.
3. Parses the URL and extracts the public address and port.
4. Updates the corresponding SRV record in your Cloudflare DNS settings with the new address and port.

## Setup
1. Setup your ngrok and Clouflare accounts following the instructions [here](https://medium.com/@oliverbravery/publically-exposing-tcp-ports-with-static-url-without-port-forwarding-9ddd32ca2726). Make sure your domain service is `_minecraft`, and the protocol is `tcp`, since this is what Minecraft will be looking for.
2. Build the Docker container using the provided Dockerfile.
3. Set the environment variables with your ngrok authtoken and Cloudflare credentials.
4. Run the Docker container.
5. Connect to your Minecraft server using the domain name you set up in Cloudflare. E.g.: If you set `mc` as the subdomain, `_minecraft` as the service, and the protocol is `tcp`, connect to `mc.example.com` in Minecraft.

## Pre-built Docker Image

If you prefer to run the ngrok Minecraft service directly using Docker without building, you can use the following `docker run` command:

```sh
docker run -d --name ngrok-tunnel \
  -p 4040:4040 \
  --env NGROK_AUTHTOKEN=<YOUR_AUTHTOKEN> \
  --env MINECRAFT_PORT=25565 \
  --env CLOUDFLARE_ZONE_ID=<YOUR_ZONE_ID> \
  --env CLOUDFLARE_DNS_RECORD_ID=<YOUR_DNS_RECORD_ID> \
  --env CLOUDFLARE_API_TOKEN=<YOUR_API_TOKEN> \
  --restart unless-stopped \
  crisdias/ngrok-minecraft
```

Replace the placeholder values (`<YOUR_AUTHTOKEN>`, `<YOUR_ZONE_ID>`, `<YOUR_DNS_RECORD_ID>`, `<YOUR_API_TOKEN>`) with your actual ngrok and Cloudflare credentials.

This command will start the ngrok container and set it to restart unless explicitly stopped.

### Docker Compose

For those who prefer using `docker-compose`, here is an example `docker-compose.yml` that includes both the Minecraft server and the ngrok service:

```yaml
version: '3.4'

services:
  mc:
    container_name: server
    image: itzg/minecraft-server
    environment:
      EULA: "TRUE"
      GAMEMODE: survival
      DIFFICULTY: normal
      TZ: "America/Sao_Paulo"
    volumes:
      - ./data:/data
    stdin_open: true
    tty: true
    restart: unless-stopped
  ngrok:
    container_name: ngrok-tunnel
    image: crisdias/ngrok-minecraft
    network_mode: service:mc
    environment:
      - NGROK_AUTHTOKEN=<YOUR_AUTHTOKEN>
      - CLOUDFLARE_ZONE_ID=<YOUR_ZONE_ID>
      - CLOUDFLARE_DNS_RECORD_ID=<YOUR_DNS_RECORD_ID>
      - CLOUDFLARE_API_TOKEN=<YOUR_API_TOKEN>
      - MINECRAFT_PORT=25565
    restart: unless-stopped
    depends_on:
      - mc
```

Save this as `docker-compose.yml` and run with `docker compose up -d`.

Remember to replace the placeholders with your actual data and agree to the Minecraft EULA by setting `EULA` to `TRUE` if you agree.

## Environment Variables
- `NGROK_AUTHTOKEN`: Your ngrok authentication token.
- `MINECRAFT_PORT`: The local port where your Minecraft server is running.
- `CLOUDFLARE_ZONE_ID`: The zone ID of your domain on Cloudflare.
- `CLOUDFLARE_DNS_RECORD_ID`: The ID of the DNS record you wish to update.
- `CLOUDFLARE_API_TOKEN`: Your Cloudflare API token.

Please follow the instructions [here](https://medium.com/@oliverbravery/publically-exposing-tcp-ports-with-static-url-without-port-forwarding-9ddd32ca2726) to create a Cloudflare API token and SRV record.

## License
This project is open-sourced under the MIT License. See the LICENSE file for more details.
