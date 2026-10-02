FROM eclipse-temurin:17 AS builder
WORKDIR /application
ARG ARTIFACT_NAME
COPY ${ARTIFACT_NAME}.jar application.jar
RUN java -Djarmode=layertools -jar application.jar extract

# Thay đổi 1: image chạy chỉ cần JRE, không cần cả JDK
FROM eclipse-temurin:17-jre
WORKDIR /application

# Thay đổi 2: tạo user riêng với UID cố định
RUN groupadd --system --gid 10001 spring \
    && useradd --system --uid 10001 --gid spring spring


ARG EXPOSED_PORT
EXPOSE ${EXPOSED_PORT}

ENV SPRING_PROFILES_ACTIVE=docker

COPY --from=builder /application/dependencies/ ./
RUN true
COPY --from=builder application/spring-boot-loader/ ./
RUN true
COPY --from=builder application/snapshot-dependencies/ ./
RUN true
COPY --from=builder application/application/ ./

# Thay đổi 3: chạy app bằng user đó thay vì root
USER 10001
ENTRYPOINT ["java", "org.springframework.boot.loader.launch.JarLauncher"]