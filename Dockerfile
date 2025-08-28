# Use a base Python image (since it runs Python scripts)
FROM python:3.9-slim-buster

# Set the working directory in the container
WORKDIR /app

# Copy the project files into the container
COPY . /app

# Make the standalone_docker.sh script executable
RUN chmod +x scripts/standalone_docker.sh

# Command to run the application using standalone_docker.sh
CMD ["./scripts/standalone_docker.sh"]