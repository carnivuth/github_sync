FROM debian:bookworm

RUN apt update

# install cron and crontab
RUN apt install cron -y
ADD crontab /etc/cron.d/
# set permissions
RUN chmod 0644 /etc/cron.d/crontab

# add project files
WORKDIR /usr/local/bin
ADD github_sync.sh .
ADD deps .
RUN apt install $(cat deps) -y

CMD ["cron", "-f", "&&", "tail", "-f", "/var/log/cron.log"]
