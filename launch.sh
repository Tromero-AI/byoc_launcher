#!/bin/bash

# Check for the data directory and create it if it doesn't exist
data_dir="data"
if [ ! -d "$data_dir" ]; then
    mkdir "$data_dir"
    echo "Data directory created."
else
    echo "Data directory already exists."
fi

# Get the full path of the data directory and set it as an environment variable
DATA_DIR_PATH=$(realpath "$data_dir")
export DATA_DIR_PATH

# Create the .env file
env_file=".env"
echo "DATA_DIR_PATH=$DATA_DIR_PATH" > "$env_file"

# Function to prompt for user input and write to .env file
prompt_and_save() {
    echo "Please enter the $1:"
    read input_value
    echo "$1=$input_value" >> "$env_file"
    export "$1=$input_value"
}

# Prompt for Hugging Face API key and server key
prompt_and_save "HUGGINGFACE_API_KEY"
prompt_and_save "SERVER_KEY"

# Run docker compose
echo "Running Docker Compose..."
docker compose up

echo "Setup complete."
