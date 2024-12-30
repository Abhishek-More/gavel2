# Use a Python 3.8 slim image as base
FROM python:3.8-slim

# Update apt-get and install necessary dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    python3-dev \
    python3-distutils \
    libatlas-base-dev \
    gfortran \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Create the directory where your app will reside
RUN mkdir /web

# Set the working directory
WORKDIR /root

# Copy the requirements file first to leverage Docker cache
COPY requirements.txt /web/requirements.txt

# Install the specified version of setuptools and pip
RUN python -m pip install --upgrade pip
RUN python -m pip install setuptools==58.0.0

# Install numpy from pre-built binary wheels (avoid compilation)
RUN python -m pip install numpy --no-cache-dir

RUN python -m pip install scipy --no-cache-dir

# Install other Python dependencies
RUN python -m pip install -r /web/requirements.txt --no-cache-dir

# Switch to the app directory
WORKDIR /web

# Copy the rest of your application code
COPY . /web

# Set environment variable for the port
ENV PORT 5000

# Expose the app on the specified port
EXPOSE ${PORT}

# Command to run the application using gunicorn
CMD ["sh", "-c", "python initialize.py && gunicorn -b 0.0.0.0:$PORT gavel:app -w 3"]

