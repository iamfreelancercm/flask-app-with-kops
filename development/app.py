# Import necessary libraries and modules
from flask import Flask, request, redirect, url_for, render_template, send_from_directory
import pandas as pd
import boto3
from botocore.exceptions import NoCredentialsError
import os

# Initialize Flask application
app = Flask(__name__)

# Configure AWS S3 bucket details
S3_BUCKET = 'flask-waseem'
S3_KEY = os.getenv('S3_KEY')
S3_SECRET = os.getenv('S3_SECRET')
S3_REGION = 'us-east-1'

# Create an S3 client using boto3
s3 = boto3.client(
    's3',
    aws_access_key_id=S3_KEY,
    aws_secret_access_key=S3_SECRET,
    region_name=S3_REGION
)

# Directory to save uploaded files locally
UPLOAD_FOLDER = 'uploads'

# Create the uploads folder if it does not exist
if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

# Configure Flask to use the upload folder
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

# Route for the index page
@app.route('/')
def index():
    # List all files in the uploads folder
    files = os.listdir(app.config['UPLOAD_FOLDER'])
    return render_template('index.html', files=files)

# Route to handle file uploads
@app.route('/upload', methods=['POST'])
def upload_file():
    # Check if the request contains a file part
    if 'file' not in request.files:
        return redirect(request.url) # Redirect to the same URL if no file is part of the request
    
    file = request.files['file']
    
    # Check if the file has a filename and is a CSV file
    if file.filename == '':
        return redirect(request.url) # Redirect to the same URL if no filename is provided
    
    if file and file.filename.endswith('.csv'):
        filename = file.filename
        filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        # Save the uploaded file to the local upload folder
        file.save(filepath)
        
        # Read the CSV file using pandas and convert its content to HTML for display
        df = pd.read_csv(filepath)
        csv_content = df.to_html()  # Convert DataFrame to HTML table
        
         # Upload the file to the configured S3 bucket
        try:
            s3.upload_file(filepath, S3_BUCKET, filename)
        except FileNotFoundError:
            return "The file was not found." # Handle case where the file is not found
        except NoCredentialsError:
            return "Credentials not available." # Handle case where AWS credentials are not available
        
        # Render the display.html template with the CSV content and filename
        return render_template('display.html', csv_content=csv_content, filename=filename)
    # Redirect if the file is not a CSV file
    return redirect(request.url)

# Route to serve uploaded files from the uploads folder
@app.route('/uploads/<filename>')
def uploaded_file(filename):
    # Serve the requested file from the uploads directory
    return send_from_directory(app.config['UPLOAD_FOLDER'], filename)

# Run the Flask application
if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=True)

