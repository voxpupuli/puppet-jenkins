#!/bin/sh
JENKINS_CONFIG=/etc/sysconfig/jenkins-slave

# Read config
[ -f "$JENKINS_CONFIG" ] && . "$JENKINS_CONFIG"

if [ -x /sbin/runuser ] ; then
    RUNUSER=runuser
else
    RUNUSER=su
fi

# Run swarm client
exec $RUNUSER - $JENKINS_SLAVE_USER \
    -c "$JAVA $JAVA_ARGS -jar $JENKINS_SLAVE_JAR $JENKINS_SLAVE_ARGS"
