# The MIT License
#
#  Copyright (c) 2015, CloudBees, Inc.
#
#  Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files (the "Software"), to deal
#  in the Software without restriction, including without limitation the rights
#  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#  copies of the Software, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions:
#
#  The above copyright notice and this permission notice shall be included in
#  all copies or substantial portions of the Software.
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#  THE SOFTWARE.

FROM java:8-jdk

ENV HOME /home/jenkins
RUN groupadd -g 10000 jenkins && \
    useradd -c "Jenkins user" -d $HOME -u 10000 -g 10000 -m jenkins

RUN mkdir /usr/share/jenkins
ADD http://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/2.54/remoting-2.54.jar /usr/share/jenkins/slave.jar
RUN chmod 644 /usr/share/jenkins/slave.jar

RUN mkdir /tmp/hotcache
ADD http://updates.jenkins-ci.org/download/war/1.625.2/jenkins.war $HOME/.jenkins/war
ADD http://updates.jenkins-ci.org/download/plugins/maven-plugin/2.12.1/maven-plugin.hpi /tmp/files
ADD http://updates.jenkins-ci.org/download/plugins/subversion/2.5.4/subversion.hpi /tmp/files
ADD http://updates.jenkins-ci.org/download/plugins/git-client/1.19.0/git-client.hpi /tmp/files

RUN chmod -R 755 /tmp/files

WORKDIR $HOME
USER jenkins

RUN mkdir -p $HOME/.tmp $HOME/.jenkins/cache/jars $HOME/.jenkins/war/extracted

RUN unzip -q -n /tmp/hotcache/jenkins.war -d $HOME/.jenkins/war/extracted WEB-INF/lib/* && \
    for i in /tmp/hotcache/*.hpi; do unzip -q -n $i -d $HOME/.jenkins/war/extracted WEB-INF/lib/*; done && \
    java -cp /usr/share/jenkins/slave.jar hudson.remoting.InitializeJarCacheMain $HOME/.jenkins/war/extracted/WEB-INF/lib $HOME/.jenkins/cache/jars && \
    rm -rf $HOME/.jenkins/war

USER root
RUN rm -rf /tmp/files

USER jenkins
VOLUME ["/home/jenkins"]
