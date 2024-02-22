FROM python:3.9

WORKDIR /usr/src/app

COPY ./src/generator.py .
COPY ./src/watcher.sh .

RUN apt-get update && apt-get install -y inotify-tools

RUN mkdir targets

RUN chmod +x watcher.sh

CMD ["./watcher.sh"]