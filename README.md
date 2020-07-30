Zero downtime deploy PoC with Docker and nginx

1. `docker-compose --project-name=zdt-nginx-poc up -d`

2. `docker-compose --project-name=zdt-nginx-poc stop node-app-green`

3. Do deployment and test simultaneously:

    1. `ab -l -c 10 -n 10000 http://127.0.0.1:3010/`

    2. `./deploly.sh`

Test is passed - no single failure during the deploy