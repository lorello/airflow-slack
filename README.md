# Slack notifier for Airflow Tasks SLA misses

Airflow support natively the notification of SLA misses, but only using e-mail.

## How it works

The daemon periodically check on the database if there are tasks that missed their sla: this is a native functionality of Airflow. If some task is late, the daemon send a slack message and update the airflow database flagging the miss as _notified_.

## Requirements

Airflow must to be configured to use Postgres as database, other
configuration are not supported.

## Configuration

The script is configured using environment variables

| Variable     |  Description   | 
|--------------|----------------|
| `PGHOST`     | postgresql hostname of airflow
| `PGUSER`     | postgresql username of airflow
| `PGPASSWORD` | postgresql password of airflow
| `PGDATABASE` | postgresql database of airflow
| `SLACK_URL`  | Slack webhook to send notifications
| `SLACK_CHANNEL`| Slack channel
| `SLACK_TO`   | Add one or more @user1 @user2 to the message posted
| `SCHEDULE`   | If not defined the container exits after one execution. If defined the container stay up and run the script periodically
| `TRACE`      | If valorized enable debugging on the bash scripts (set -x)

The format for schedule variable is defined by [cron package](https://godoc.org/github.com/robfig/cron): 
you can use the common cron syntax with 6 fields (seconds, minutes, hours, day of month, month, day of week) and also the common shortcuts like `@hourly`, `@daily`, `@weekly`.


