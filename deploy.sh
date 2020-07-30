#!/bin/sh

FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $FILE_DIR

SERVICE_NAME=$1

if [ "$SERVICE_NAME" == "" ]; then
    echo "Usage: ./deploy.sh service_name"
    exit;
fi

# Check service name
RESP_CODE=$(curl -sL -w "%{http_code}" -o /dev/null "http://localhost:8000/ports/$SERVICE_NAME.txt")
if [[ RESP_CODE -gt 399 || RESP_CODE -lt 200 ]]; then
    echo "Service $SERVICE_NAME was not found in port mappings by URL http://localhost:8000/ports/$SERVICE_NAME.txt. Response code - $RESP_CODE"
    exit;
fi

# Get active environment
ACTIVE_ENV=$("$FILE_DIR/nginx/active-env.sh" get $SERVICE_NAME)
if [ "$ACTIVE_ENV" == "green" ]; then
    NEW_ENV="blue"
else
    NEW_ENV="green"
fi
echo "Active environment is $ACTIVE_ENV, switching to $NEW_ENV"

# Run new container
docker-compose --project-name=zdt-nginx-poc build "$SERVICE_NAME-$NEW_ENV"
docker-compose --project-name=zdt-nginx-poc up -d "$SERVICE_NAME-$NEW_ENV"

# Wait till the new conteiner is fully up
PORTS=$(curl --silent "http://localhost:8000/ports/$SERVICE_NAME.txt")
if [ "$NEW_ENV" == "blue" ]; then
    NEW_PORT=$(printf "$PORTS" | cut -f 2 -d " ")
else
    NEW_PORT=$(printf "$PORTS" | cut -f 3 -d " ")
fi
until $(curl --output /dev/null --silent --head --fail http://localhost:$NEW_PORT/health); do
    printf '.'
    sleep 1
done
echo
echo "New $NEW_ENV container is up"

# Update nginx configuration
"$FILE_DIR/nginx/active-env.sh" "set-$NEW_ENV" $SERVICE_NAME

# Ask nginx to read update configuration
docker exec -it zdt-nginx-poc_nginx_1 nginx -s reload
echo "Nging configuration is updated and reloaded"

# Waiting for 5 seconds to finish all on-going requests
echo "Waiting for 5 seconds to finish all on-going requests"
for i in {1..5}
do
   sleep 1
   printf '.'
done

# Shut the old container down
docker-compose --project-name=zdt-nginx-poc stop "$SERVICE_NAME-$ACTIVE_ENV"
echo "Old $ACTIVE_ENV container is down"