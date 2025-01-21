# This script unzips a repository in its current directory and lists all binaries in a spreadsheet that should not be included in a migration to GitHub.
# It also lists binaries that are not in the .gitignore, .tfignore, and .tfattributes files.

import os
import zipfile
import argparse
import logging
import sys
import concurrent.futures
import shutil

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

def install_openpyxl():
    """Install openpyxl if it is not already installed."""
    try:
        import openpyxl
    except ImportError:
        logging.info("openpyxl not found. Attempting to install...")
        try:
            import pip
            pip.main(['install', 'openpyxl'])
            import openpyxl
            logging.info("Successfully installed openpyxl.")
        except Exception as e:
            logging.error(f"Failed to install openpyxl: {e}")
            logging.info("Please ensure you have access to the internet or configure pip to use a proxy.")
            logging.info("To configure pip to use a proxy, set the HTTP_PROXY and HTTPS_PROXY environment variables.")
            logging.info("Example:")
            logging.info("export HTTP_PROXY=http://proxy.example.com:8080")
            logging.info("export HTTPS_PROXY=http://proxy.example.com:8080")
            sys.exit(1)

install_openpyxl()
from openpyxl import Workbook

def unzip_repo(zip_path, extract_to):
    """Unzip the repository to the specified directory."""
    with zipfile.ZipFile(zip_path, 'r') as zip_ref:
        zip_ref.extractall(extract_to)
    logging.info(f"Unzipped repository to {extract_to}")

# Function to get the list of files in a directory
def get_files_list(directory):
    """Get the list of files in a directory."""
    files_list = []
    for root, _, files in os.walk(directory):
        for file in files:
            files_list.append(os.path.join(root, file))
    return files_list

# Function to get the list of directories in a directory
def get_directories_list(directory):
    """Get the list of directories in a directory."""
    directories_list = []
    for root, directories, _ in os.walk(directory):
        for directory in directories:
            directories_list.append(os.path.join(root, directory))
    return directories_list

# Function to get the list of binaries in a directory
def get_binaries_list(directory):
    """Get the list of binaries in a directory."""
    binaries_list = []
    for root, _, files in os.walk(directory):
        for file in files:
            if is_binary(file):
                binaries_list.append(os.path.join(root, file))
    return binaries_list

def create_spreadsheet(binaries_list, output_path):
    """Create a spreadsheet listing all binaries."""
    wb = Workbook()
    ws = wb.active
    ws.title = "Binaries List"
    ws.append(["File Path", "File Size", "Ignored"])
    for binary in binaries_list:
        file_size = os.path.getsize(binary)
        ignored = is_ignored(binary)
        ws.append([binary, file_size, ignored])
    wb.save(output_path)
    logging.info(f"Spreadsheet saved to {output_path}")

def is_binary(file_path):
    # Implement logic to determine if a file is binary
    pass

def is_ignored(file_path):
    # Implement logic to determine if a file is ignored
    pass

def clean_up(directory):
    """Remove the extracted files and directories."""
    shutil.rmtree(directory)
    logging.info(f"Cleaned up extracted files from {directory}")

def main():
    parser = argparse.ArgumentParser(description="Unzip a repository and list all binaries.")
    parser.add_argument('--zip_path', required=True, help="Path to the zip file of the repository")
    parser.add_argument('--extract_to', required=True, help="Directory to extract the repository to")
    parser.add_argument('--output_path', required=True, help="Path to save the output spreadsheet")
    args = parser.parse_args()

    unzip_repo(args.zip_path, args.extract_to)

    logging.info("Starting to get binaries list from the extracted repository...")
    binaries_list = get_binaries_list(args.extract_to)
    logging.info(f"Found {len(binaries_list)} binaries in the extracted repository")

    create_spreadsheet(binaries_list, args.output_path)

    clean_up(args.extract_to)

if __name__ == "__main__":
    main()


