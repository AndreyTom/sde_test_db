#!/bin/bash
docker pull postgres
docker run --name  postgres-container -e POSTGRES_PASSWORD="@sde_password012" -e POSTGRES_USER="test_sde" -e POSTGRES_DB="demo" -v $HOME/sde_tasks/sde_test_db:$HOME/sde_tasks/sde_test_db -p 5432:5432 -d postgres
sleep 10
docker exec postgres-container psql -U test_sde -d demo -f $HOME/sde_tasks/sde_test_db/sql/init_db/demo.sql
echo "БД готова"