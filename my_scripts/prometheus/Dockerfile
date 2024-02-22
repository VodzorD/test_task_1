FROM python:3.9

WORKDIR /usr/src/app

COPY generator.py .
COPY watcher.sh .

RUN apt-get update && apt-get install -y inotify-tools

RUN mkdir targets

RUN chmod +x watcher.sh

CMD ["./watcher.sh"]