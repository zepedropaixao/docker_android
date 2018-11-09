#
# HOW TO BUILD
# docker build -f docker/dev/ionic/Dockerfile -t is-dev/ionic .
#
# HOW TO USE. ex:
# docker run --rm -ti -v $(pwd):/app is-dev/ionic --version
#

FROM node:8

RUN apt-get update && apt-get install -y software-properties-common unzip

RUN echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections && \
  add-apt-repository -y "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" && \
  apt-get update && \
  apt-get install -y oracle-java8-installer && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer

ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

RUN wget --no-verbose --output-document=sdk-tools.zip "https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip" && \
    unzip sdk-tools.zip -d /usr/local/android-sdk-linux

ENV ANDROID_HOME /usr/local/android-sdk-linux
ENV PATH $PATH:${ANDROID_HOME}/tools:$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools/bin/

RUN ( sleep 2 && while [ 1 ]; do sleep 1; echo y; done ) | /usr/local/android-sdk-linux/tools/android update sdk

RUN sdkmanager "tools" "platform-tools"
RUN sdkmanager "build-tools;26.0.2" "build-tools;25.0.3"
RUN sdkmanager "platforms;android-26" "platforms;android-25" "platforms;android-24" "platforms;android-23"
RUN sdkmanager "extras;android;m2repository" "extras;google;m2repository"
RUN sdkmanager "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2"
RUN sdkmanager "extras;m2repository;com;android;support;constraint;constraint-layout-solver;1.0.2"

RUN set -o errexit -o nounset \
    && echo "Downloading Gradle" \
    && wget --no-verbose --output-document=gradle.zip "https://services.gradle.org/distributions/gradle-4.6-bin.zip" \
    \
    && echo "Checking download hash" \
    && echo "98bd5fd2b30e070517e03c51cbb32beee3e2ee1a84003a5a5d748996d4b1b915 *gradle.zip" | sha256sum --check - \
    \
    && echo "Installing Gradle" \
    && unzip gradle.zip \
    && rm gradle.zip \
    && mv "gradle-4.6" "/opt/gradle/" \
    && ln --symbolic "/opt/gradle/bin/gradle" /usr/bin/gradle \
    \
    && echo "Adding gradle user and group" \
    && groupadd --system gradle \
    && useradd --system --gid gradle --shell /bin/bash --create-home gradle \
    && mkdir /home/gradle/.gradle \
    && chown --recursive gradle:gradle /home/gradle \
    \
    && echo "Symlinking root Gradle cache to gradle Gradle cache" \
    && ln -s /home/gradle/.gradle /root/.gradle

ENV GRADLE_USER_HOME /app/.graddle

RUN npm -g add cordova
RUN npm -g add ionic

VOLUME ["/app"]
WORKDIR /app

CMD ["/bin/bash"]
