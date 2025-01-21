# binary-truffler

`binary_truffler.py` is a Python script that unzips a repository in its current directory and lists all binaries in a spreadsheet that should not be included in a migration to GitHub. It also lists binaries that are not in the `.gitignore`, `.tfignore`, and `.tfattributes` files.

## Requirements

- Python 3.x
- `openpyxl` library

You can install the required library using pip:
```sh
pip install openpyxl
```

## Usage

To run the script, use the following command:
```sh
python binary_truffler.py --zip_path <ZIP_PATH> --extract_to <EXTRACT_TO>
```

### Example
```sh
python binary_truffler.py --zip_path path/to/repo.zip --extract_to path/to/extract
```

Replace `<ZIP_PATH>` and `<EXTRACT_TO>` with the path to your zip file and the directory to extract the repository to, respectively.

## Logging

The script uses logging to provide feedback on its progress and any issues encountered. Logs are printed to the console with timestamps and log levels.

## Functions

### `unzip_repo(zip_path, extract_to)`
Unzips the repository to the specified directory.

### `get_files_list(directory)`
Returns a list of all files in the specified directory.

### `get_directories_list(directory)`
Returns a list of all directories in the specified directory.

### `get_binaries_list(directory)`
Returns a list of all binaries in the specified directory.
