#!/bin/sh
#
#  Licensed to the Apache Software Foundation (ASF) under one or more
#  contributor license agreements.  See the NOTICE file distributed with
#  this work for additional information regarding copyright ownership.
#  The ASF licenses this file to You under the Apache License, Version 2.0
#  (the "License"); you may not use this file except in compliance with
#  the License.  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

# --------------------------------------------------------------------
# $Rev: 1032841 $ $Date: 2010-11-09 12:45:02 +0800 (Tue, 09 Nov 2010) $
# --------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Start/Stop Script for the Geronimo Server
#
# This script is based upon Tomcat's catalina.sh file to enable
# those familiar with Tomcat to quickly get started with Geronimo.
#
# This script file can be used directly instead of startup.sh and
# shutdown.sh as they call this script file anyway.
#
# You should not have to edit this file.  If you wish to have environment
# variables set each time you run this script refer to the information
# on the setenv.sh script that is called by this script below.
#
# Invocation Syntax:
#
#   geronimo.sh command [geronimo_args]
#
#   For detailed command usage information, just run geronimo.sh without any
#   arguments.
#
# Environment Variable Prequisites:
#
#   GERONIMO_HOME   (Optional) May point at your Geronimo top-level directory.
#                   If not specified, it will default to the parent directory
#                   of the location of this script.
#
#   GERONIMO_OPTS   (Optional) Java runtime options used when the "start",
#                   "stop", or "run" command is executed.
#
#   GERONIMO_OUT    (Optional) File that Geronimo's stdout and stderr streams
#                   will be redirected to if Geronimo is started in the
#                   background.
#                   Defaults to $GERONIMO_HOME/var/log/geronimo.out
#
#   GERONIMO_PID    (Optional) Path of the file which should contains the pid
#                   of the Geronimo java process, when start (fork) is used
#
#   GERONIMO_TMPDIR (Optional) Directory path location of temporary directory
#                   the JVM should use (java.io.tmpdir). Defaults to var/temp 
#                   (resolved to server instance directory).
#
#   JAVA_HOME       Points to your Java Development Kit installation.
#                   JAVA_HOME doesn't need to be set if JRE_HOME is set
#                   unless you use the "debug" command.
#                   It is mandatory either JAVA_HOME or JRE_HOME are set.
#
#   JRE_HOME        Points to your Java Runtime Environment installation.
#                   Set this if you wish to run Geronimo using the JRE
#                   instead of the JDK (except for the "debug" command).
#                   Defaults to JAVA_HOME if empty.
#                   It is mandatory either JAVA_HOME or JRE_HOME are set.
#
#   JAVA_OPTS       (Optional) Java runtime options used when the "start",
#                   "stop", or "run" command is executed.
#
#   JDB_SRCPATH     (Optional) The Source Path to be used by jdb debugger
#                   when the "debug" command is executed.
#                   Defaults to %GERONIMO_HOME%\src
#
#   JPDA_ADDRESS    (Optional) Java runtime options used when the "jpda start"
#                   command is executed. The default is 8000.
#
#   JPDA_TRANSPORT  (Optional) JPDA transport used when the "jpda start"
#                   command is executed. The default is "dt_socket".
#
#   JPDA_OPTS       (Optional) JPDA command line options.
#                   Only set this if you need to use some unusual JPDA
#                   command line options.  This overrides the use of the
#                   other JPDA_* environment variables.
#                   Defaults to JPDA command line options contructed from
#                   the JPDA_ADDRESS, JPDA_SUSPEND and JPDA_TRANSPORT
#                   environment variables.
#
#   JPDA_SUSPEND    (Optional) Suspend the JVM before the main class is loaded.
#                   Valid values are 'y' and 'n'.  The default is "n".
#
#   START_OS_CMD    (Optional) Operating system command that will be placed in
#                   front of the java command when starting Geronimo in the
#                   background.  This can be useful on operating systems where
#                   the OS provides a command that allows you to start a process
#                   with in a specified CPU or priority.
#
# Troubleshooting execution of this script file:
#
#  GERONIMO_ENV_INFO (Optional) Environment variable that when set to "on"
#                    (the default) outputs the values of the GERONIMO_HOME,
#                    GERONIMO_TMPDIR, JAVA_HOME and
#                    JRE_HOME before the command is issued. Set to "off"
#                    if you do not want this information displayed.
#
# Scripts called by this script:
#
#   $GERONIMO_HOME/bin/setenv.sh
#                   (Optional) This script file is called if it is present.
#                   Its contents may set one or more of the above environment
#                   variables.  It is preferable (to simplify migration to
#                   future Geronimo releases) to set environment variables
#                   in this file rather than modifying Geronimo's script files.
#
#   $GERONIMO_HOME/bin/setjavaenv.sh
#                   This batch file is called to set environment variables
#                   relating to the java or jdb executable to invoke.
#                   This file should not need to be modified.
#
# Exit Codes:
#
#  0 - Success
#  1 - Error
# -----------------------------------------------------------------------------

# OS specific support.  $var _must_ be set to either true or false.
cygwin=false
os400=false
case "`uname`" in
CYGWIN*) cygwin=true;;
OS400*) os400=true;;
esac

# resolve links - $0 may be a softlink
PRG="$0"

while [ -h "$PRG" ]; do
  ls=`ls -ld "$PRG"`
  link=`expr "$ls" : '.*-> \(.*\)$'`
  if expr "$link" : '/.*' > /dev/null; then
    PRG="$link"
  else
    PRG=`dirname "$PRG"`/"$link"
  fi
done

# Get standard environment variables
PRGDIR=`dirname "$PRG"`

# Only set GERONIMO_HOME if not already set
[ -z "$GERONIMO_HOME" ] && GERONIMO_HOME=`cd "$PRGDIR/.." ; pwd`

if [ -r "$GERONIMO_HOME"/bin/setenv.sh ]; then
  . "$GERONIMO_HOME"/bin/setenv.sh
fi

# For Cygwin, ensure paths are in UNIX format before anything is touched
if $cygwin; then
  [ -n "$JAVA_HOME" ] && JAVA_HOME=`cygpath --unix "$JAVA_HOME"`
  [ -n "$JRE_HOME" ] && JRE_HOME=`cygpath --unix "$JRE_HOME"`
  [ -n "$JDB_SRCPATH" ] && JDB_SRCPATH=`cygpath --unix "$JDB_SRCPATH"`
  [ -n "$GERONIMO_HOME" ] && GERONIMO_HOME=`cygpath --unix "$GERONIMO_HOME"`
fi

# For OS400
if $os400; then
  # Set job priority to standard for interactive (interactive - 6) by using
  # the interactive priority - 6, the helper threads that respond to requests
  # will be running at the same priority as interactive jobs.
  COMMAND='chgjob job('$JOBNAME') runpty(6)'
  system $COMMAND

  # Enable multi threading
  export QIBM_MULTI_THREADED=Y
fi

# Get standard Java environment variables
# (based upon Tomcat's setclasspath.sh but renamed since Geronimo's classpath
# is set in the JAR manifest)
if $os400; then
  # -r will Only work on the os400 if the files are:
  # 1. owned by the user
  # 2. owned by the PRIMARY group of the user
  # this will not work if the user belongs in secondary groups
  BASEDIR="$GERONIMO_HOME"
  . "$GERONIMO_HOME"/bin/setjavaenv.sh
else
  if [ -r "$GERONIMO_HOME"/bin/setjavaenv.sh ]; then
    BASEDIR="$GERONIMO_HOME"
    . "$GERONIMO_HOME"/bin/setjavaenv.sh
  else
    echo "Cannot find $GERONIMO_HOME/bin/setjavaenv.sh"
    echo "This file is needed to run this program"
    exit 1
  fi
fi

# Use a default JAVA_OPTS if it's not set
if [ -z "$JAVA_OPTS" ]; then
  JAVA_OPTS="-Xmx256m -XX:MaxPermSize=128m"
fi

if [ -z "$GERONIMO_TMPDIR" ] ; then
  # Define the java.io.tmpdir to use for Geronimo
  # A relative value will be resolved relative to each instance
  GERONIMO_TMPDIR=var/temp
fi

if [ -z "$GERONIMO_OUT" ] ; then
  # Define the output file we are to redirect both stdout and stderr to
  # when Geronimo is started in the background
  GERONIMO_OUT="$GERONIMO_HOME"/var/log/geronimo.out
fi

if [ -z "$JDB_SRCPATH" ] ; then
  # Define the source path to be used by the JDB debugger
  JDB_SRCPATH="$GERONIMO_HOME"/src
fi

# For Cygwin, switch paths to Windows format before running java
if $cygwin; then
  JAVA_HOME=`cygpath --absolute --windows "$JAVA_HOME"`
  JRE_HOME=`cygpath --absolute --windows "$JRE_HOME"`
  JDB_SRCPATH=`cygpath --absolute --windows "$JDB_SRCPATH"`
  GERONIMO_HOME=`cygpath --absolute --windows "$GERONIMO_HOME"`
  GERONIMO_TMPDIR=`cygpath --windows "$GERONIMO_TMPDIR"`
  EXT_DIRS="$GERONIMO_HOME/lib/ext;$JRE_HOME/lib/ext"
  ENDORSED_DIRS="$GERONIMO_HOME/lib/endorsed;$JRE_HOME/lib/endorsed"
else
  EXT_DIRS="$GERONIMO_HOME/lib/ext:$JRE_HOME/lib/ext"
  ENDORSED_DIRS="$GERONIMO_HOME/lib/endorsed:$JRE_HOME/lib/endorsed"
fi

# ----- Execute The Requested Command -----------------------------------------
if [ "$GERONIMO_ENV_INFO" != "off" ] ; then
  echo "Using GERONIMO_HOME:   $GERONIMO_HOME"
  echo "Using GERONIMO_TMPDIR: $GERONIMO_TMPDIR"
  if [ "$1" = "debug" ] ; then
    echo "Using JAVA_HOME:       $JAVA_HOME"
    echo "Using JDB_SRCPATH:     $JDB_SRCPATH"
  else
    echo "Using JRE_HOME:        $JRE_HOME"
  fi
fi

LONG_OPT=
if [ "$1" = "start" ] ; then
  LONG_OPT=--long
  if [ "$GERONIMO_ENV_INFO" != "off" ] ; then
    echo "Using GERONIMO_OUT:    $GERONIMO_OUT"
  fi
fi

if [ "$1" = "jpda" ] ; then
  if [ -z "$JPDA_SUSPEND" ]; then
    JPDA_SUSPEND="n"
  fi
  if [ -z "$JPDA_TRANSPORT" ]; then
    JPDA_TRANSPORT="dt_socket"
  fi
  if [ -z "$JPDA_ADDRESS" ]; then
    JPDA_ADDRESS="8000"
  fi
  if [ -z "$JPDA_OPTS" ]; then
    JPDA_OPTS="-Xdebug -Xrunjdwp:transport=$JPDA_TRANSPORT,address=$JPDA_ADDRESS,server=y,suspend=$JPDA_SUSPEND"
  fi
  if [ "$GERONIMO_ENV_INFO" != "off" ] ; then
    echo "Using JPDA_OPTS:       $JPDA_OPTS"
  fi
  GERONIMO_OPTS="$GERONIMO_OPTS $JPDA_OPTS"
  shift
fi

# Setup the Java programming language agent
JAVA_AGENT_JAR="$GERONIMO_HOME/bin/jpa.jar"

if [ "$1" = "debug" ] ; then
  if $os400; then
    echo "Debug command not available on OS400"
    exit 1
  else
    echo "Note: The jdb debugger will start Geronimo in another process and connect to it."
    echo "      To terminate Geronimo when running under jdb, run the "geronimo stop" command"
    echo "      in another window.  Do not use Ctrl-C as that will terminate the jdb client"
    echo "      (the debugger itself) but will not stop the Geronimo process."
    shift
    exec "$_RUNJDB" $JAVA_OPTS $GERONIMO_OPTS \
      -sourcepath "$JDB_SRCPATH" \
      -Djava.endorsed.dirs="$ENDORSED_DIRS" \
      -Djava.ext.dirs="$EXT_DIRS" \
      -Dorg.apache.geronimo.home.dir="$GERONIMO_HOME" \
      -Djava.io.tmpdir="$GERONIMO_TMPDIR" \
      -classpath "$GERONIMO_HOME"/bin/server.jar \
      org.apache.geronimo.cli.daemon.DaemonCLI $LONG_OPT "$@"
  fi

elif [ "$1" = "run" ]; then
  shift
  if [ -f "$JAVA_AGENT_JAR" ]; then
      exec "$_RUNJAVA" $JAVA_OPTS $GERONIMO_OPTS \
        -javaagent:"$JAVA_AGENT_JAR" \
        -Dorg.apache.geronimo.home.dir="$GERONIMO_HOME" \
        -Djava.endorsed.dirs="$ENDORSED_DIRS" \
        -Djava.ext.dirs="$EXT_DIRS" \
        -Djava.io.tmpdir="$GERONIMO_TMPDIR" \
        -jar "$GERONIMO_HOME"/bin/server.jar $LONG_OPT "$@"
  else
      exec "$_RUNJAVA" $JAVA_OPTS $GERONIMO_OPTS \
        -Dorg.apache.geronimo.home.dir="$GERONIMO_HOME" \
        -Djava.endorsed.dirs="$ENDORSED_DIRS" \
        -Djava.ext.dirs="$EXT_DIRS" \
        -Djava.io.tmpdir="$GERONIMO_TMPDIR" \
        -jar "$GERONIMO_HOME"/bin/server.jar $LONG_OPT "$@"
  fi

elif [ "$1" = "start" ] ; then
  shift
  ISHelp=false
  case "$1" in
  --help) ISHelp=true;;
  -help) ISHelp=true;;
  -h) ISHelp=true;;
  esac
  if $ISHelp; then
    if [ -f "$JAVA_AGENT_JAR" ]; then
	      exec "$_RUNJAVA" $JAVA_OPTS $GERONIMO_OPTS \
	        -javaagent:"$JAVA_AGENT_JAR" \
	        -Dorg.apache.geronimo.home.dir="$GERONIMO_HOME" \
	        -Djava.endorsed.dirs="$ENDORSED_DIRS" \
	        -Djava.ext.dirs="$EXT_DIRS" \
	        -Djava.io.tmpdir="$GERONIMO_TMPDIR" \
	        -jar "$GERONIMO_HOME"/bin/server.jar $LONG_OPT "$@"
	  else
	      exec "$_RUNJAVA" $JAVA_OPTS $GERONIMO_OPTS \
	        -Dorg.apache.geronimo.home.dir="$GERONIMO_HOME" \
	        -Djava.endorsed.dirs="$ENDORSED_DIRS" \
	        -Djava.ext.dirs="$EXT_DIRS" \
	        -Djava.io.tmpdir="$GERONIMO_TMPDIR" \
	        -jar "$GERONIMO_HOME"/bin/server.jar $LONG_OPT "$@"
	  fi
  else
    touch "$GERONIMO_OUT"
	  if [ -f "$JAVA_AGENT_JAR" ]; then
	      $START_OS_CMD "$_RUNJAVA" $JAVA_OPTS $GERONIMO_OPTS \
	        -javaagent:"$JAVA_AGENT_JAR" \
	        -Dorg.apache.geronimo.home.dir="$GERONIMO_HOME" \
	        -Djava.endorsed.dirs="$ENDORSED_DIRS" \
	        -Djava.ext.dirs="$EXT_DIRS" \
	        -Djava.io.tmpdir="$GERONIMO_TMPDIR" \
	        -jar "$GERONIMO_HOME"/bin/server.jar $LONG_OPT "$@" \
	        >> $GERONIMO_OUT 2>&1 &
	        echo ""
	        echo "Geronimo started in background. PID: $!"
	        if [ ! -z "$GERONIMO_PID" ]; then
	          echo $! > $GERONIMO_PID
	        fi
	  else
	      $START_OS_CMD "$_RUNJAVA" $JAVA_OPTS $GERONIMO_OPTS \
	        -Dorg.apache.geronimo.home.dir="$GERONIMO_HOME" \
	        -Djava.endorsed.dirs="$ENDORSED_DIRS" \
	        -Djava.ext.dirs="$EXT_DIRS" \
	        -Djava.io.tmpdir="$GERONIMO_TMPDIR" \
	        -jar "$GERONIMO_HOME"/bin/server.jar $LONG_OPT "$@" \
	        >> $GERONIMO_OUT 2>&1 &
	        echo ""
	        echo "Geronimo started in background. PID: $!"
	        if [ ! -z "$GERONIMO_PID" ]; then
	          echo $! > $GERONIMO_PID
	        fi
	  fi
  fi

elif [ "$1" = "stop" ] ; then
  shift
  FORCE=0
# support -force as that is the option Tomcat uses, we will document
# --force as the option to be consistent with other Geronimo options.
  if [ "$1" = "--force" -o "$1" = "-force" ]; then
    shift
    FORCE=1
  fi

  "$_RUNJAVA" $JAVA_OPTS $GERONIMO_OPTS \
    -Dorg.apache.geronimo.home.dir="$GERONIMO_HOME" \
    -Djava.endorsed.dirs="$ENDORSED_DIRS" \
    -Djava.ext.dirs="$EXT_DIRS" \
    -Djava.io.tmpdir="$GERONIMO_TMPDIR" \
    -jar "$GERONIMO_HOME"/bin/shutdown.jar "$@"

  if [ $FORCE -eq 1 ]; then
    if [ ! -z "$GERONIMO_PID" ]; then
       echo "Killing: `cat $GERONIMO_PID`"
       kill -9 `cat $GERONIMO_PID`
    fi
  fi

else

  echo "Usage: geronimo.sh command [geronimo_args]"
  echo "commands:"
  echo "  debug             Debug Geronimo in jdb debugger"
  echo "  jpda run          Start Geronimo in foreground under JPDA debugger"
  echo "  jpda start        Start Geronimo in background under JPDA debugger"
  echo "  run               Start Geronimo in the foreground"
  echo "  start             Start Geronimo in the background"
  echo "  stop              Stop Geronimo"
  echo "  stop --force      Stop Geronimo (followed by kill -KILL)"
  echo ""
  echo "args for debug, jpda run, jpda start, run and start commands:"
  echo "       --quiet       No startup progress"
  echo "       --long        Long startup progress"
  echo "  -v   --verbose     INFO log level"
  echo "  -vv  --veryverbose DEBUG log level"
  echo "       --override    Override configurations. USE WITH CAUTION!"
  echo "       --help        Detailed help."
  echo "  -s   --secure      Enable Geronimo for 2 way secure JMX communication."
  echo ""
  echo "args for stop command:"
  echo "       --user        Admin user"
  echo "       --password    Admin password"
  echo "       --host        Hostname of the server"
  echo "       --port        RMI port to connect to"
  echo "       --secure      Enable secure JMX communication"
  exit 1

fi
