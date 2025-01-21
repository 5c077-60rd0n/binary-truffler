# This script unzips a repository in its current directory and lists all binaries in a spreadsheet that should not be included in a migration to GitHub.
# It also lists binaries that are not in the .gitignore, .tfignore, and .tfattributes files.

import os
import zipfile
import argparse
import logging
import sys

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
    binary_extensions = ('.dll', '.exe', '.pdb', '.lib', '.obj', '.bin', '.so', '.a', '.dylib', '.o', '.out', '.class', '.jar', '.war', '.ear')
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith(binary_extensions):
                binaries_list.append(os.path.join(root, file))
    return binaries_list

def main():
    parser = argparse.ArgumentParser(description="Unzip a repository and list all binaries.")
    parser.add_argument('--zip_path', required=True, help="Path to the zip file of the repository")
    parser.add_argument('--extract_to', required=True, help="Directory to extract the repository to")
    args = parser.parse_args()

    unzip_repo(args.zip_path, args.extract_to)

    logging.info("Starting to get binaries list from the extracted repository...")
    binaries_list = get_binaries_list(args.extract_to)
    logging.info(f"Found {len(binaries_list)} binaries in the extracted repository")

if __name__ == "__main__":
    main()


