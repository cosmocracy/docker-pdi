FROM eclipse-temurin:11
MAINTAINER Andre Pereira andrespp@gmail.com

# Set Environment Variables
ENV PDI_VERSION=9.3 PDI_BUILD=9.3.0.0-428 \
	PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/data-integration \
	KETTLE_HOME=/data-integration

# Needed packages/dependencies
RUN apt-get update && apt-get install -y unzip

# Download PDI
RUN wget --progress=dot:giga https://sourceforge.net/projects/pentaho/files/Pentaho-${PDI_VERSION}/client-tools/pdi-ce-${PDI_BUILD}.zip \
	&& unzip -q *.zip \
	&& rm -f *.zip \
	&& mkdir /jobs

# Aditional Drivers
WORKDIR $KETTLE_HOME

RUN wget https://downloads.sourceforge.net/project/jtds/jtds/1.3.1/jtds-1.3.1-dist.zip \
	&& unzip jtds-1.3.1-dist.zip -d lib/ \
	&& rm jtds-1.3.1-dist.zip \
	&& wget https://github.com/FirebirdSQL/jaybird/releases/download/v3.0.4/Jaybird-3.0.4-JDK_1.8.zip \
	&& unzip Jaybird-3.0.4-JDK_1.8.zip -d lib \
	&& rm -rf lib/docs/ Jaybird-3.0.4-JDK_1.8.zip

# First time run
RUN pan.sh -file ./plugins/platform-utils-plugin/samples/showPlatformVersion.ktr \
	&& kitchen.sh -file samples/transformations/files/test-job.kjb

# Install xauth
RUN apt-get update && apt-get install -y xauth

#VOLUME /jobs

COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["help"]
