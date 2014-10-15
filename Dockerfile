FROM pmdevel/ubuntu:14.04-pm

MAINTAINER Niclas Ahlstrand <niclas.ahlstrand@pensionsmyndigheten.se>

ENV ORACLE_HOME /u01/app/oracle/product/11.2.0/xe

# Necessary packages
RUN apt-get install -y libaio1 net-tools bc wget
ADD chkconfig /sbin/chkconfig
RUN chmod 755 /sbin/chkconfig


RUN wget -L `wget -q -L -O - https://my.pcloud.com/publink/show?code=XZwru7ZWXKcneQzvGb07LA4ktGfwm0GVA2k | grep https | grep oracle | grep href | sed -n 's/.*href="\(.*\)" download.*/\1/p'`
RUN mv oracle-xe_11.2.0-2_amd64.deb /tmp/

# Oracle
RUN ln -s /usr/bin/awk /bin/awk
RUN mkdir -p /var/lock/subsys
RUN dpkg --install /tmp/oracle-xe_11.2.0-2_amd64.deb
RUN rm -f /tmp/oracle-xe_11.2.0-2_amd64.deb

#ADD init.ora $ORACLE_HOME/config/scripts/
#ADD initXETemp.ora $ORACLE_HOME/config/scripts/
#ADD oracle_config.txt /tmp/

#ADD shutdown_db.sh 			/tmp/
#ADD shutdown_db.sql			/tmp/
#ADD change_character_set.sh	/tmp/

#RUN /etc/init.d/oracle-xe configure < /tmp/oracle_config.txt
#RUN rm -f /tmp/oracle_config.txt

#RUN echo "export ORACLE_HOME=$ORACLE_HOME"    >> /etc/bash.bashrc
#RUN echo "export PATH=$ORACLE_HOME/bin:$PATH" >> /etc/bash.bashrc
#RUN echo "export ORACLE_SID=XE"               >> /etc/bash.bashrc

# Start db and listeners
#RUN service oracle-xe start

# Shutdown db
#RUN chmod 755 /tmp/shutdown_db.sh
#RUN /tmp/shutdown_db.sh

# Change character set
#RUN chmod 755 /tmp/change_character_set.sh
#RUN /tmp/change_character_set.sh WE8ISO8859P15

# Clean-up
#RUN rm -f /tmp/shutdown_db.sh
#RUN rm -f /tmp/shutdown_db.sql
#RUN rm -f /tmp/change_character_set_sh

# Stop db
#RUN service oracle-xe stop


# Add a "Message of the Day" to help identify container when logging in via SSH
#RUN echo '[ Ubuntu 14.04 PM Oracle XE]' > /etc/motd

EXPOSE 22
#EXPOSE 1521
#EXPOSE 8080

#CMD sed -i -E "s/HOST = [^)]+/HOST = $HOSTNAME/g" $ORACLE_HOME/network/admin/listener.ora; \
#    service oracle-xe start; \

CMD /usr/sbin/sshd -D
