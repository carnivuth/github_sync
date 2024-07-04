FROM debian:bookworm

RUN apt update

# install cron and crontab
RUN apt install cron -y
ADD crontab /etc/
# set permissions
RUN chmod 600 /etc/crontab
RUN chown root:root /etc/crontab

# add project files
WORKDIR /usr/local/bin
ADD github_sync.sh .
ADD deps .
ADD start.sh .
RUN apt install $(cat deps) -y

CMD [ "./start.sh" ]
