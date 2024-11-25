# Use a lightweight base image for better performance
FROM eclipse-temurin:17-jdk-alpine

# Expose application port
EXPOSE 8080

# Define application directory
ENV APP_HOME=/usr/src/app

# Copy application JAR into the container
COPY target/*.jar $APP_HOME/app.jar

# Set working directory
WORKDIR $APP_HOME

# Run the application
CMD ["java", "-jar", "app.jar"]
