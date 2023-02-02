#Windows
docker run -it \
    -e POSTGRES_USER="root" \
    -e POSTGRES_PASSWORD="root" \
    -e POSTGRES_DB="ny_taxi" \
    -v c:/Users/user/Documents/de/2_docker_sql/ny_taxi_postgres_data:/var/lib/postgresql/data\
    -p 5431:5432 \
postgres:13

#Linux 
docker run -it \
    -e POSTGRES_USER="root" \
    -e POSTGRES_PASSWORD="root" \
    -e POSTGRES_DB="ny_taxi" \
    -v $(pwd)/ny_taxi_postgres_data:/var/lib/postgresql/data\
    -p 5431:5432 \
postgres:13


#Connect to pgAdmin
docker run -it \
    -e PGADMIN_DEFAULT_EMAIL="admin@admin.com" \
    -e PGADMIN_DEFAULT_PASSWORD="root" \
    -p 8081:80 \
    dpage/pgadmin4

## Network
docker network create pg-network

docker run -it \
    -e POSTGRES_USER="root" \
    -e POSTGRES_PASSWORD="root" \
    -e POSTGRES_DB="ny_taxi" \
    -v c:/Users/user/Documents/data-zoomcamp/week_1_basics_n_setup/2_docker_sql/ny_taxi_postgres_data:/var/lib/postgresql/data\
    -p 5431:5432 \
    --network=pg-network \
    --name pg-database \
postgres:13

#pgAdmin for Network
docker run -it \
    -e PGADMIN_DEFAULT_EMAIL="admin@admin.com" \
    -e PGADMIN_DEFAULT_PASSWORD="root" \
    -p 8081:80 \
    --network=pg-network \
    --name pgadmin \
    dpage/pgadmin4  

#Ingest Data Script
URL="https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/yellow_tripdata_2019-01.csv.gz"
python ingest_data.py \
    --user=root \
    --password=root \
    --host=localhost \
    --port=5431 \
    --db=ny_taxi \
    --table_name=yellow_taxi_data \
    --url=${URL}


docker build -t taxi_ingest:v001 .

#run it in the network (host-localhost / pg-database) or kubernetes
docker run -it \
    --network=pg-network \
    taxi_ingest:v001 \
        --user=root \
        --password=root \
        --host=pg-database \
        --port=5431 \
        --db=ny_taxi \
        --table_name=yellow_taxi_data \
        --url="https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/yellow_tripdata_2021-01.csv.gz"

#run docker compose
docker-compose up -d