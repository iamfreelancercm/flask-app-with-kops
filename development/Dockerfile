FROM python:latest

ENV FLASK_RUN_HOST=0.0.0.0
WORKDIR /app
COPY requirements.txt requirements.txt
RUN pip3 install --no-cache-dir -r requirements.txt
COPY . .

# Copy NGINX configuration file
COPY nginx.conf /etc/nginx/conf.d/app.conf

# Expose ports
EXPOSE 80

# Start NGINX and Flask
CMD ["sh", "-c", "flask run --host=0.0.0.0"]
