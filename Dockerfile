# Use Alpine Linux image
FROM alpine:latest

# Install curl, jq, and other dependencies
RUN apk add --no-cache curl jq bash

# Download and install ngrok
ADD https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip /
RUN unzip ngrok-stable-linux-amd64.zip -d /bin && \
    rm -f ngrok-stable-linux-amd64.zip

# Set the working directory
WORKDIR /root

# Add your script file
COPY update_dns.sh .
RUN chmod +x update_dns.sh

# Run your script
CMD ["./update_dns.sh"]
