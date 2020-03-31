FROM store/intersystems/iris-community:2020.1.0.209.0

# alternatively, start from a full IRIS kit and add your license key 
# FROM intersystems/iris:2020.1.0.209.0
# COPY iris.key /usr/irissys/mgr/iris.key

USER root
RUN mkdir /data && \
	chown irisowner /data
USER irisowner

# load code & set up
COPY src/iris/ /data/src/
COPY iris.script /tmp/

RUN iris start IRIS \
	&& iris session IRIS < /tmp/iris.script