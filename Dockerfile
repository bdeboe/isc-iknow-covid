FROM intersystems/iris-community:2020.1.0.209.0

# alternatively, start from a full IRIS kit and add your license key 
# FROM intersystems/iris:2020.1.0.209.0
# COPY iris.key /usr/irissys/mgr/iris.key


ENV FILE_SERVER=ai2-semanticscholar-cord-19.s3-us-west-2.amazonaws.com \
    FILE_UPDATE=2020-03-20 \
    FILE_NAME=biorxiv_medrxiv

USER root
RUN mkdir /data && \
    apt-get update && apt-get -y install curl && \
	chown irisowner /data

USER irisowner

RUN curl https://${FILE_SERVER}/${FILE_UPDATE}/${FILE_NAME}.tar.gz -o /data/${FILE_NAME}.tar.gz && \
    tar xzf /data/${FILE_NAME}.tar.gz -C /data/ && \
    rm /data/*.tar.gz 

# load code & set up
COPY src/iris/ /data/src/
COPY iris.script /tmp/

RUN iris start IRIS \
	&& iris session IRIS < /tmp/iris.script