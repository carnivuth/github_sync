FROM debian:bookworm

RUN apt update

# install cron and crontab
RUN apt install -y cron curl git jq grep
COPY crontab /etc/
# set permissions
RUN chmod 600 /etc/crontab
RUN chown root:root /etc/crontab

# add project files
WORKDIR /usr/local/bin
COPY github_sync.sh .
COPY start.sh .

CMD [ "./start.sh" ]
