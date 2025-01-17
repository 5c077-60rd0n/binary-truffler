# binary-truffler

`binary_truffler.py` is a Python script that traverses a TFS repository and lists all binaries in a spreadsheet that should not be included in a migration to GitHub. It also lists binaries that are not in the `.gitignore`, `.tfignore`, and `.tfattributes` files.

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
python binary_truffler.py --tfs_url <TFS_URL> --tfs_project <TFS_PROJECT> --username <USERNAME> --pat <PAT>
```

### Example
```sh
python binary_truffler.py --tfs_url http://tfs-server:8080/tfs --tfs_project ProjectName --username your_username --pat your_pat
```

Replace `<TFS_URL>`, `<TFS_PROJECT>`, `<USERNAME>`, and `<PAT>` with your TFS server URL, project name, username, and Personal Access Token, respectively.

## Logging

The script uses logging to provide feedback on its progress and any issues encountered. Logs are printed to the console with timestamps and log levels.

## Functions

### `get_files_list(directory)`
Returns a list of all files in the specified directory.

### `get_directories_list(directory)`
Returns a list of all directories in the specified directory.

### `get_binaries_list(directory)`
Returns a list of all binaries in the specified directory.

### `get_tfs_files_list(tfs_url, tfs_project, username, pat)`
Returns a list of all files in the specified TFS project.

### `get_tfs_binaries_list(tfs_url, tfs_project, username, pat)`
Returns a list of all binaries in the specified TFS project.
