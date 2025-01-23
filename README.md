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
python binary_truffler.py --zip_path <ZIP_PATH> --extract_to <EXTRACT_TO> --output_path <OUTPUT_PATH>
```

### Example
```sh
python binary_truffler.py --zip_path path/to/repo.zip --extract_to path/to/extract --output_path path/to/output.xlsx
```

Replace `<ZIP_PATH>`, `<EXTRACT_TO>`, and `<OUTPUT_PATH>` with the path to your zip file, the directory to extract the repository to, and the path to save the output spreadsheet, respectively.

## Logging

The script uses logging to provide feedback on its progress and any issues encountered. Logs are printed to the console with timestamps and log levels.

## Spreadsheet Format

The output spreadsheet will be in `.xlsx` format and will contain the following columns:
- **File Path**: The path to the binary file.
- **File Size**: The size of the binary file in bytes.
- **Ignored**: Whether the file is ignored by `.gitignore`, `.tfignore`, or `.tfattributes`.

## Functions

### `unzip_repo(zip_path, extract_to)`
Unzips the repository to the specified directory.

### `get_files_list(directory)`
Returns a list of all files in the specified directory.

### `get_directories_list(directory)`
Returns a list of all directories in the specified directory.

### `get_binaries_list(directory)`
Returns a list of all binaries in the specified directory.

### `create_spreadsheet(binaries_list, output_path)`
Creates a spreadsheet listing all binaries and saves it to the specified path.

## PowerShell Script

`tfs_truffler.ps1` is a PowerShell script that authenticates a user with TFS using a username and PAT, downloads the repository, and lists all binaries in a spreadsheet.

### Requirements

- PowerShell 5.1 or later
- `AzureDevOps` module

You can install the required module using the following command:
```powershell
Install-Module -Name AzureDevOps -Scope CurrentUser -Force
```

### Usage

To run the script, use the following command:
```powershell
.\tfs_truffler.ps1 -username <USERNAME> -pat <PAT> -tfsUrl <TFS_URL> -project <PROJECT> -repo <REPO> -outputPath <OUTPUT_PATH>
```

### Example
```powershell
.\tfs_truffler.ps1 -username "user@example.com" -pat "yourPAT" -tfsUrl "https://dev.azure.com/yourorganization" -project "YourProject" -repo "YourRepo" -outputPath "C:\path\to\output.xlsx"
```

Replace `<USERNAME>`, `<PAT>`, `<TFS_URL>`, `<PROJECT>`, `<REPO>`, and `<OUTPUT_PATH>` with your TFS username, personal access token, TFS URL, project name, repository name, and the path to save the output spreadsheet, respectively.

### Logging

The script provides feedback on its progress and any issues encountered through console output.

### Spreadsheet Format

The output spreadsheet will be in `.xlsx` format and will contain the following columns:
- **File Path**: The path to the binary file.
- **File Size**: The size of the binary file in bytes.
- **Ignored**: Whether the file is ignored by `.gitignore`, `.tfignore`, or `.tfattributes`.

## PowerShell Script for Finding Binaries

`find_binaries.ps1` is a PowerShell script that evaluates files in TFS projects, identifies binaries, and lists them in a spreadsheet.

### Requirements

- PowerShell 5.1 or later
- `TF.exe` (Team Foundation Version Control command-line tool)
- **Team Explorer 2019**: This version is compatible with Visual Studio 2019 and includes the `tf.exe` tool.

You can download and install Team Explorer 2019 from the Visual Studio website:
- [Download Team Explorer 2019](https://visualstudio.microsoft.com/vs/older-downloads/)

### Usage

To run the script, use the following command:
```powershell
.\find_binaries.ps1 -tfsUrl <TFS_URL> -outputPath <OUTPUT_PATH>
```

### Example
```powershell
.\find_binaries.ps1 -tfsUrl "https://your-tfs-url/tfs/YourCollection" -outputPath "C:\path\to\output.xlsx"
```

Replace `<TFS_URL>` and `<OUTPUT_PATH>` with your TFS URL and the path to save the output spreadsheet, respectively.

### Logging

The script provides feedback on its progress and any issues encountered through console output.

### Spreadsheet Format

The output spreadsheet will be in `.xlsx` format and will contain the following columns:
- **File Path**: The path to the binary file.
- **File Size**: The size of the binary file in bytes.
- **Ignored**: Whether the file is ignored by `.gitignore`, `.tfignore`, or `.tfattributes`.

### Additional Notes

- Ensure that `tf.exe` is accessible in your system's PATH or specify the full path to `tf.exe` in the script if it is not in the default location.
- If you are using Visual Studio Code (VSCode) exclusively, you will still need to have `tf.exe` available on your system to run the `find_binaries.ps1` script.
