FROM pmdevel/ubuntu:14.04-pm

MAINTAINER Niclas Ahlstrand <niclas.ahlstrand@pensionsmyndigheten.se>

ENV ORACLE_HOME /u01/app/oracle/product/11.2.0/xe
ENV TMP_DIR /tmp/docker_install_dir

# Necessary packages
RUN apt-get install -y libaio1 bc 
ADD chkconfig /sbin/chkconfig
RUN chmod 755 /sbin/chkconfig

# Install Java.
RUN \
  echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java7-installer && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk7-installer

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-7-oracle

RUN mkdir -p $TMP_DIR

# Download Oracle XE package (too big to store on github) 
RUN wget -L `wget -q -L -O - https://my.pcloud.com/publink/show?code=XZwru7ZWXKcneQzvGb07LA4ktGfwm0GVA2k | grep https | grep oracle | grep href | sed -n 's/.*href="\(.*\)" download.*/\1/p'`
RUN mv oracle-xe_11.2.0-2_amd64.deb $TMP_DIR/

# Oracle stuff
RUN ln -s /usr/bin/awk /bin/awk
RUN mkdir -p /var/lock/subsys
RUN dpkg --install $TMP_DIR/oracle-xe_11.2.0-2_amd64.deb

ADD init.ora				$ORACLE_HOME/config/scripts/
ADD initXETemp.ora			$ORACLE_HOME/config/scripts/
RUN chown oracle:dba 		$ORACLE_HOME/config/scripts/*
ADD oracle_config.txt		$TMP_DIR/

RUN /etc/init.d/oracle-xe configure < $TMP_DIR/oracle_config.txt

RUN echo "export ORACLE_HOME=$ORACLE_HOME" >> /etc/bash.bashrc
RUN echo "export PATH=$ORACLE_HOME/bin:$PATH" >> /etc/bash.bashrc
RUN echo "export ORACLE_SID=XE" >> /etc/bash.bashrc
#RUN echo "export NLS_LANG=`$ORACLE_HOME/bin/nls_lang.sh`" >> /etc/bash.bashrc
RUN echo "export ORACLE_BASE=/u01/app/oracle" >> /etc/bash.bashrc
RUN echo "export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH" >> /etc/bash.bashrc

# Clean-up
RUN rm -rf $TMP_DIR

# Add a "Message of the Day" to help identify container when logging in via SSH
RUN echo '[ Ubuntu 14.04 Oracle XE ]' > /etc/motd

EXPOSE 1521
EXPOSE 8080

CMD sed -i -E "s/HOST = [^)]+/HOST = $HOSTNAME/g" $ORACLE_HOME/network/admin/listener.ora; \
    sed -i -E "s/HOST = [^)]+/HOST = $HOSTNAME/g" $ORACLE_HOME/network/admin/tnsnames.ora; \
    service oracle-xe start; 

