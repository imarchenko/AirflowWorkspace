#!/bin/bash

#refactor environment vars
echo "refactor environment variables"
sudo sed -Ei "s#base_dir#$DOMINO_WORKING_DIR#g" /home/ubuntu/airflow/airflow.cfg

#create DB in postgres
sudo chown -R postgres /mnt/airflow/postgresql/
sudo service postgresql start

echo "CREATE USER airflow with PASSWORD 'airflow'" | sudo sh -c 'sudo -u postgres psql'
echo "CREATE DATABASE airflow;" | sudo sh -c 'sudo -u postgres psql'
echo "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO airflow;" | sudo sh -c 'sudo -u postgres psql'


echo "build dependencies"
airflow initdb
airflow variables -s DOMINO_API_HOST $DOMINO_API_HOST
airflow variables -s DOMINO_USER_API_KEY $DOMINO_USER_API_KEY
#start airflow webserver and scheduler
echo "Starting up Airflow"
airflow webserver -p 8080 -hn "0.0.0.0" &
airflow scheduler