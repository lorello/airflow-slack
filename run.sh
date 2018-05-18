#!/bin/sh

[[ $TRACE ]] && set -x 

if [[ ! -z $SCHEDULE ]]; then
  exec /usr/local/bin/go-cron -s "$SCHEDULE" -p 8080 -- /usr/local/bin/check-airflow-sla
else
  echo '-----------------------------------------------------------------------------------'
  echo 
  echo "Running one-shot check, to launch as a daemon set the environment variable SCHEDULE"
  echo 
  echo '-----------------------------------------------------------------------------------'
  exec /usr/local/bin/check-airflow-sla
fi
