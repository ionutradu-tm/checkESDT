FROM ubuntu:latest
COPY run_docker.sh /run.sh
RUN chmod +x /run.sh

CMD /run.sh