# Slack notifier for Airflow Tasks SLA misses

## Requirements

Airflow must to be configured to use Postgres as database, other
configuration are not supported.

## Configuration

The script is configured using environment variables

| Variable     |  Description   | 
|--------------|----------------|
| PGHOST       | postgresql hostname of airflow
| PGUSER       | postgresql username of airflow
| PGPASSWORD   | postgresql password of airflow
| PGDATABASE   | postgresql database of airflow
| SLACK_URL    | Slack webhook to send notifications
| SLACK_CHANNEL| Slack channel
| SLACK_TO     | Add one or more @user1 @user2 to the message posted
| SCHEDULE     | If not defined the container exits after one execution. If defined the container stay up and run the script periodically
| TRACE        | If valorized enable debugging on the bash scripts (set -x)

The format for schedule variable is defined by go-cron package, is the standard unix cron syntax
with the common shortcuts like @hourly, @daily, @weekly.


