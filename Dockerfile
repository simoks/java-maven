# ----------------------------
# Stage 1 : Build Maven
# ----------------------------
FROM maven:3.9.6-eclipse-temurin-8 AS build

WORKDIR /app

# Copier uniquement le projet maven
COPY maven/pom.xml .
RUN mvn -B dependency:go-offline

COPY maven/src ./src

RUN mvn clean verify -DskipTests

# ----------------------------
# Stage 2 : Runtime
# ----------------------------
FROM eclipse-temurin:8-jre

WORKDIR /app

# Prends le fichier .jar généré dans target/ et copie-le dans l'image finale en le renommant app.jar
COPY --from=build /app/target/*.jar app.jar

RUN useradd -ms /bin/bash appuser
USER appuser

ENTRYPOINT ["java", "-jar", "app.jar"]
