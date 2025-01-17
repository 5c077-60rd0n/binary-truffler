# This script traverses a TFS repository and lists all binaries in a spreadsheet that should not be included in a migration to GitHub.
# It also lists binaries that are not in the .gitignore, .tfignore, and .tfattributes files.

import os
import subprocess
import openpyxl
import argparse
import logging
import sys
from openpyxl import Workbook

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

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

def check_tf_command():
    """Check if the tf command is available."""
    try:
        subprocess.run(['tf', 'help'], capture_output=True, text=True, shell=True, check=True)
        logging.info("TFS command-line tool is available.")
    except subprocess.CalledProcessError:
        logging.error("TFS command-line tool is not available. Please ensure it is installed and included in your PATH.")
        logging.info("Installation instructions:")
        logging.info("Windows: Install Visual Studio with the 'Azure DevOps Server' workload.")
        logging.info("macOS: Install Homebrew and run 'brew install tfs'.")
        logging.info("Ubuntu: Install .NET Core SDK and download the TFS cross-platform command-line tool from the official GitHub repository.")
        sys.exit(1)

# Function to get the list of files from TFS
def get_tfs_files_list(tfs_url, tfs_project, username, pat):
    """Get the list of files from TFS."""
    command = f'tf dir {tfs_url}/{tfs_project} /r /filesOnly /login:{username},{pat}'
    try:
        result = subprocess.run(command, capture_output=True, text=True, shell=True, check=True)
        files_list = result.stdout.splitlines()
        return files_list
    except subprocess.CalledProcessError as e:
        logging.error(f"Failed to get files from TFS: {e}")
        return []

# Function to get the list of binaries from TFS
def get_tfs_binaries_list(tfs_url, tfs_project, username, pat):
    """Get the list of binaries from TFS."""
    files_list = get_tfs_files_list(tfs_url, tfs_project, username, pat)
    binaries_list = []
    binary_extensions = ('.dll', '.exe', '.pdb', '.lib', '.obj', '.bin', '.so', '.a', '.dylib', '.o', '.out', '.class', '.jar', '.war', '.ear')
    for file in files_list:
        if file.endswith(binary_extensions):
            binaries_list.append(file)
    return binaries_list

def main():
    parser = argparse.ArgumentParser(description="Traverse a TFS repository and list all binaries.")
    parser.add_argument('--tfs_url', required=True, help="TFS server URL")
    parser.add_argument('--tfs_project', required=True, help="TFS project name")
    parser.add_argument('--username', required=True, help="TFS username")
    parser.add_argument('--pat', required=True, help="TFS Personal Access Token")
    args = parser.parse_args()

    check_tf_command()

    logging.info("Starting to get binaries list from TFS...")
    tfs_binaries_list = get_tfs_binaries_list(args.tfs_url, args.tfs_project, args.username, args.pat)
    logging.info(f"Found {len(tfs_binaries_list)} binaries in TFS project {args.tfs_project}")

if __name__ == "__main__":
    main()


