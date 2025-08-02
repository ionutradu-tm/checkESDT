FROM ubuntu:24.10
COPY src/run_docker.sh /run.sh
RUN chmod +x /run.sh

CMD /run.sh