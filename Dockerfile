FROM pmdevel/ubuntu:14.04-pm

MAINTAINER Niclas Ahlstrand <niclas.ahlstrand@pensionsmyndigheten.se>

ENV ORACLE_HOME /u01/app/oracle/product/11.2.0/xe
ENV TMP_DIR /tmp/docker_install_dir

# Necessary packages
RUN apt-get install -y libaio1 net-tools bc wget
ADD chkconfig /sbin/chkconfig
RUN chmod 755 /sbin/chkconfig

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
ADD shutdown_db.sh 			$TMP_DIR/
ADD shutdown_db.sql			$TMP_DIR/
ADD change_character_set.sh	$TMP_DIR/

RUN /etc/init.d/oracle-xe configure < $TMP_DIR/oracle_config.txt

RUN sed -i -E 's/KEY = [A-Z_]+/KEY = EXTPROC0/g' $ORACLE_HOME/network/admin/listener.ora

RUN echo "export ORACLE_HOME=$ORACLE_HOME"    >> /etc/bash.bashrc
RUN echo "export PATH=$ORACLE_HOME/bin:$PATH" >> /etc/bash.bashrc
RUN echo "export ORACLE_SID=XE"               >> /etc/bash.bashrc

# Start db and listeners
RUN service oracle-xe start

# Shutdown db
RUN chmod 755 $TMP_DIR/shutdown_db.sh
RUN $TMP_DIR/shutdown_db.sh

# Change character set
RUN chmod 755 $TMP_DIR/change_character_set.sh
RUN $TMP_DIR/change_character_set.sh WE8ISO8859P15

# Clean-up
RUN rm -rf $TMP_DIR

# Stop db
RUN service oracle-xe stop


# Add a "Message of the Day" to help identify container when logging in via SSH
RUN echo '[ Ubuntu 14.04 PM Oracle XE]' > /etc/motd

EXPOSE 22
EXPOSE 1521
EXPOSE 8080

CMD sed -i -E "s/HOST = [^)]+/HOST = $HOSTNAME/g" $ORACLE_HOME/network/admin/listener.ora; \
    service oracle-xe start; \
    /usr/sbin/sshd -D

