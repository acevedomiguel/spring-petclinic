FROM maven:3.8.3-jdk-11 AS MAVEN_BUILD

ENV MAVEN_CONFIG=''
COPY pom.xml /build/
COPY mvnw /build/
COPY .mvn /build/.mvn/
COPY src /build/src/

WORKDIR /build/
RUN ./mvnw package

FROM openjdk:8-jdk-alpine
WORKDIR /app
COPY --from=MAVEN_BUILD /build/target /app/
ENTRYPOINT ["java", "-jar", "/app/spring-petclinic-2.5.0-SNAPSHOT.jar"]
