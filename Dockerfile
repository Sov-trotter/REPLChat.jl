FROM julia:1.6.0

RUN apt-get update && apt-get install -y gcc
ENV JULIA_PROJECT @.
WORKDIR /home

ENV VERSION 1
ADD . /home

RUN julia deploy/packagecompile.jl

EXPOSE 8080

ENTRYPOINT ["julia", "-t 8", "-JREPLChat.so", "-e", "REPLChat.run(\"test/repl_chat.sqlite\", \"file:///home/resources/authkeys.json\")"] 
