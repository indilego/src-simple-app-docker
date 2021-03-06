# springboot-maven3-centos
#
# This image provide a base for running Spring Boot based applications. It
# provides a base Java 8 installation and Maven 3.

FROM openshift/base-centos7

EXPOSE 8080

ENV JAVA_VERSON 1.8.0
ENV MAVEN_VERSION 3.3.9

LABEL io.k8s.description="Platform for building and running Spring Boot applications" \
      io.k8s.display-name="Spring Boot Maven 3" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,java,java8,maven,maven3,springboot"

RUN yum update -y && \
  yum install -y curl && \
  yum install -y java-$JAVA_VERSON-openjdk java-$JAVA_VERSON-openjdk-devel && \
  yum clean all

RUN curl -fsSL https://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar xzf - -C /usr/share \
  && mv /usr/share/apache-maven-$MAVEN_VERSION /usr/share/maven \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

ENV JAVA_HOME /usr/lib/jvm/java
ENV MAVEN_HOME /usr/share/maven


RUN git clone https://github.com/indilego/src-simple-app-docker.git /myapp/
RUN ls
RUN cp -R /myapp/* /opt/app-root/src
RUN chown -R 1001:0 /opt/app-root
USER 1001

RUN echo "---> Installing application source 2"
#RUN cp -Rf /tmp/src/. ./
#RUN cp -Rf /tmp/src/. /opt/app-root/src

RUN echo "---> Building Spring Boot application from source"

RUN  mvn clean install

RUN echo "---> Starting Spring Boot application"

ENTRYPOINT ["java","-jar","target/app.jar"]
