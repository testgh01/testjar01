/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

//
// $Rev: 826768 $ $Date: 2009-10-20 03:10:35 +0800 (Tue, 20 Oct 2009) $
//

// Append some reasonable java flags if none were configured already
if (command.javaFlags.empty) {
    command.javaFlags << '-Xmx256m'
    command.javaFlags << '-XX:MaxPermSize=128m'
}

// If java version specific configuration were needed, it could take the following
// form
// 
// if (command.profiles.contains('java6')) {
//    command.javaFlags << '-Xmx2048m'
// }

// If the debug profile was selected, then append some debugging flags
if (command.profiles.contains('debug')) {
    command.javaFlags << '-Xdebug'
    command.javaFlags << '-Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=8000'
}
