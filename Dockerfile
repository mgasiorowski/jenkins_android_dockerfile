# Android development environment for ubuntu precise (12.04 LTS).
# version 1.0


# First build the container and give a name to the resulting image:
# docker build -t jenkins/android .
#
# Run in background:
# docker run -d -P --name android_project_name jenkins/android
#
# You can start an interactive session to test new commands with:
# docker runt -P jenkins/android /bin/bash
#
# Configure docker container as jenkins node.
#
# Check IP address:
# docker inspect --format '{{ .NetworkSettings.Gateway }}' android_project_name
#
# Check port:
# docker port android_project_name 22


# Start with ubuntu precise (LTS).
FROM ubuntu:12.04

MAINTAINER Maciej Gąsiorowski "maciej.gasiorowski@grupawp.pl"

# Never ask for confirmations
ENV DEBIAN_FRONTEND noninteractive
RUN echo "debconf shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections
RUN echo "debconf shared/accepted-oracle-license-v1-1 seen true" | debconf-set-selections

# Repositories
ADD sources.list /etc/apt/

# Update apt
RUN apt-get -qq update

# First, install required software
RUN apt-get -y install python-software-properties
RUN apt-get -y install ant
RUN apt-get -y install git-core
RUN apt-get -y install curl

# Install and configure openssh-server
RUN apt-get -y install openssh-server
RUN mkdir /var/run/sshd

# Install 32bit Library
RUN apt-get -y install libstdc++6:i386 libgcc1:i386 zlib1g:i386 libncurses5:i386 --no-install-recommends

# Add user "jenkins"
RUN adduser jenkins --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password
RUN echo "jenkins:J3nk1ns" | chpasswd

# Add keys
ADD .ssh /home/jenkins/.ssh
RUN chown jenkins:jenkins -R /home/jenkins/.ssh

# Add oracle-jdk to repositories
RUN add-apt-repository ppa:webupd8team/java

# Add gradle repository
RUN add-apt-repository ppa:cwchien/gradle

# Update ant
RUN apt-get -qq update

# Install oracle-jdk
RUN apt-get -y install oracle-java7-installer

# Install gradle
RUN apt-get -y install gradle-ppa

# Install android sdk
RUN cd /usr/local/ && curl -L -O http://dl.google.com/android/android-sdk_r22.6.2-linux.tgz && tar xf android-sdk_r22.6.2-linux.tgz

# Add paths to user jenkins
RUN echo 'export ANDROID_HOME=/usr/local/android-sdk-linux' >>/home/jenkins/.bash_profile
RUN echo 'export PATH=$PATH:$ANDROID_HOME/tools' >>/home/jenkins/.bash_profile
RUN echo 'export PATH=$PATH:$ANDROID_HOME/platform-tools' >>/home/jenkins/.bash_profile
RUN echo 'export JAVA_HOME=/usr/lib/jvm/java-7-oracle' >>/home/jenkins/.bash_profile

# Add android tools and platform tools to PATH
ENV ANDROID_HOME /usr/local/android-sdk-linux
ENV PATH $PATH:$ANDROID_HOME/tools
ENV PATH $PATH:$ANDROID_HOME/platform-tools

# Export JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-7-oracle

# Install Android tools
RUN echo y | /usr/local/android-sdk-linux/tools/android update sdk --no-ui
RUN echo y | /usr/local/android-sdk-linux/tools/android update sdk --filter platform-tools --no-ui --force -a
RUN echo y | /usr/local/android-sdk-linux/tools/android update sdk --filter tools --no-ui --force -a
RUN echo y | /usr/local/android-sdk-linux/tools/android update sdk --filter 'build-tools-19.0.1' --no-ui --force -a
RUN echo y | /usr/local/android-sdk-linux/tools/android update sdk --filter 'build-tools-19.0.2' --no-ui --force -a
RUN echo y | /usr/local/android-sdk-linux/tools/android update sdk --filter 'build-tools-19.0.3' --no-ui --force -a
RUN echo y | /usr/local/android-sdk-linux/tools/android update sdk --filter 'build-tools-19.1.0' --no-ui --force -a
RUN echo y | /usr/local/android-sdk-linux/tools/android update sdk --filter 'build-tools-20' --no-ui --force -a
RUN echo y | /usr/local/android-sdk-linux/tools/android update sdk --filter 'android-19' --no-ui --force -a
RUN echo y | /usr/local/android-sdk-linux/tools/android update sdk --filter 'android-20' --no-ui --force -a
RUN echo y | /usr/local/android-sdk-linux/tools/android update sdk --filter 'addon-google_apis-google-19' --no-ui --force -a
RUN echo y | /usr/local/android-sdk-linux/tools/android update sdk --filter extra --no-ui --force -a

# Clean up
RUN rm -rf /usr/local/android-sdk_r22.6.2-linux.tgz
RUN apt-get autoremove && apt-get clean && apt-get autoclean

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
