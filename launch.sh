#!/bin/bash

# Check for the data directory and create it if it doesn't exist
data_dir="data"
if [ ! -d "$data_dir" ]; then
    mkdir "$data_dir"
    echo "Data directory created."
else
    echo "Data directory already exists."
fi
model_dir="models"

# Get the full path of the data directory and set it as an environment variable
DATA_DIR_PATH=$(realpath "$data_dir")
export DATA_DIR_PATH

# Create the .env file
env_file=".env"
echo "DATA_DIR_PATH=$DATA_DIR_PATH" > "$env_file"

# if $DATA_DIR_PATH/models--mistralai--Mistral-7B-Instruct-v0.2 does not exist, mkdir and download it from GCS
if [ ! -d "$DATA_DIR_PATH/Mistral-7B-Instruct-v0.2" ]; then
    sudo apt-get update
    sudo apt-get install apt-transport-https ca-certificates gnupg curl
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
    sudo apt-get update && sudo apt-get install google-cloud-cli
    mkdir -p $DATA_DIR_PATH/models--mistralai--Mistral-7B-Instruct-v0.2
    echo "Downloading Mistral-7B-Instruct-v0.2 model from GCS..."
    gsutil cp -r gs://mistral-bucket-432/Mistral-7B-Instruct-v0.2 $DATA_DIR_PATH
else
    echo "Mistral-7B-Instruct-v0.2 model already exists."
fi

# Function to prompt for user input and write to .env file
prompt_and_save() {
    echo "Please enter the $1:"
    read input_value
    echo "$1=$input_value" >> "$env_file"
    export "$1=$input_value"
}

# Prompt for Hugging Face API key and server key
prompt_and_save "SERVER_KEY"

# Run docker compose
echo "Running Docker Compose..."
docker compose up -d

echo "Setup complete."
