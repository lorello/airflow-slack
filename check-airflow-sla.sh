#!/bin/bash

[[ $TRACE ]] && set -x 

# example fo results:
#    floorplan-check|location-to-s3|2018-05-17 08:00:00|f|2018-05-17 12:54:13.903523||f

# labels received:
# task_id | dag_id | execution_date | email_sent | timestamp | description | notification_sent

# should I check only for recent misses? 
#sla_query="SELECT * FROM sla_miss WHERE timestamp > NOW() - INTERVAL '24 hour' AND email_sent='f' ORDER BY dag_id, task_id, timestamp LIMIT 100;"
sla_query="SELECT * FROM sla_miss WHERE email_sent='f' ORDER BY dag_id, task_id, timestamp LIMIT 1000;"

subject="*${SLACK_TO} some tasks are late*"

echo -e "The following task missed their SLA target:\n" > /tmp/message.txt

counter=0
psql --command "$sla_query" --quiet --tuples-only --no-align  | while read line
do 
    #echo "----------------------"
    #echo $line
    task_id="$(echo $line | cut -d'|' -f1)"
    dag_id="$(echo $line | cut -d'|' -f2)"
    exec_date="$(echo $line | cut -d'|' -f3)"
    #email_sent
    timestamp="$(echo $line | cut -d'|' -f5)"
    description="$(echo $line | cut -d'|' -f6)"
    #  notification_sent

    if [[ $dag_id != $last_dag_id ]]; then
       echo "*${dag_id}*" >> /tmp/message.txt
       last_dag_id=$dag_id
    fi
    if [[ $task_id != $last_task_id ]]; then
       echo "  _${task_id}_" >> /tmp/message.txt
       last_task_id=$task_id
    fi
    echo "     - $exec_date" >> /tmp/message.txt

    # Must be done later, when the slack message has been successfully sent
    echo "UPDATE sla_miss SET email_sent='t' WHERE dag_id='$dag_id' AND task_id='$task_id' AND timestamp='$timestamp';" >> /tmp/dbupdates.sql
    ((counter++))
done

# setup slacktee, if needed
if [[ ! -f /etc/slacktee.conf ]]; then
  echo "webhook_url=\"${SLACK_URL}\"" > /etc/slacktee.conf
  echo "username=\"${SLACK_FROM}\"" >> /etc/slacktee.conf
  echo "channel=\"${SLACK_CHANNEL}\"" >> /etc/slacktee.conf
fi

if (( $counter > 0 )); then

  cat /tmp/message.txt | slacktee --plain-text --title "$subject"

  if [[ $? -eq 0 ]]; then
    echo "Sent alert for '${counter}' sla misses (setting email_sent = t in database)"
    cat /tmp/dbupdates.sql | psql airflow
  fi

else

  echo "Urra! No sla misses"

fi

