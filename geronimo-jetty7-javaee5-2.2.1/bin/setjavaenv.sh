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
# $Rev: 708650 $ $Date: 2008-10-29 03:48:22 +0800 (Wed, 29 Oct 2008) $
# --------------------------------------------------------------------

# --------------------------------------------------------------------
# Set environment variables relating to the execution of java commands.
#
# This script file is called by the geronimo.sh file (which is invoked
# by the startup.sh, shutdown.sh files).  This file is also invoked
# by the deploy.sh file.
#
# It is preferable (to simplify migration to future Geronimo releases)
# to set any environment variables you need in the setenv.sh file
# rather than modifying Geronimo's script files.  See the documentation
# in the geronimo.sh file for further information.
#
# (Based upon Apache Tomcat 5.5.12's setclasspath.sh)
#
# --------------------------------------------------------------------

# Make sure prerequisite environment variables are set
if [ -z "$JAVA_HOME" -a -z "$JRE_HOME" ]; then
  __JAVA_TEST="which java"
  if [ -n "__JAVA_TEST" ]; then
    _RUNJAVA="java"
  else
    echo ""
    echo "ERROR:  Could not find a Java runtime."
    echo " - Neither the JAVA_HOME nor the JRE_HOME environment variable is defined"
    echo " - A Java implementation could not be found on the system PATH"
    echo "At least one of these is required for this program to execute."
    echo ""
    exit 1
  fi
else

if [ -z "$JAVA_HOME" -a "$1" = "debug" ]; then
  echo "JAVA_HOME should point to a JDK in order to run in debug mode."
  exit 1
fi
if [ -z "$JRE_HOME" ]; then
   if [ -d "$JAVA_HOME/jre" ]; then
     JRE_HOME="$JAVA_HOME/jre"
   else
     JRE_HOME="$JAVA_HOME"
   fi
fi

# If we're running under jdb, we need a full jdk.
if [ "$1" = "debug" ] ; then
  if [ "$os400" = "true" ]; then
    if [ ! -x "$JAVA_HOME"/bin/java -o ! -x "$JAVA_HOME"/bin/javac ]; then
      echo "The JAVA_HOME environment variable is not defined correctly"
      echo "This environment variable is needed to run this program"
      echo "NB: JAVA_HOME should point to a JDK not a JRE"
      exit 1
    fi
  else
    if [ ! -x "$JAVA_HOME"/bin/java -o ! -x "$JAVA_HOME"/bin/jdb -o ! -x "$JAVA_HOME"/bin/javac ]; then
      echo "The JAVA_HOME environment variable is not defined correctly"
      echo "This environment variable is needed to run this program"
      echo "NB: JAVA_HOME should point to a JDK not a JRE"
      exit 1
    fi
  fi
fi
if [ -z "$BASEDIR" ]; then
  echo "The BASEDIR environment variable is not defined"
  echo "This environment variable is needed to run this program"
  exit 1
fi
if [ ! -x "$BASEDIR"/bin/setjavaenv.sh ]; then
  if $os400; then
    # -x will Only work on the os400 if the files are:
    # 1. owned by the user
    # 2. owned by the PRIMARY group of the user
    # this will not work if the user belongs in secondary groups
    eval
  else
    echo "The BASEDIR environment variable is not defined correctly"
    echo "This environment variable is needed to run this program"
    exit 1
  fi
fi

# Set standard commands for invoking Java.
  _RUNJAVA="$JRE_HOME"/bin/java
if [ "$os400" != "true" ]; then
  _RUNJDB="$JAVA_HOME"/bin/jdb
fi
fi
