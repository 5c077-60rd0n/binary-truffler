tparam (
    [string]$username,
    [string]$pat,
    [string]$tfsUrl,
    [string]$project,
    [string]$repo,
    [string]$outputPath
)

# Install required modules
if (-not (Get-Module -ListAvailable -Name Az.DevOps)) {
    Install-Module -Name Az.DevOps -Scope CurrentUser -Force
}

Import-Module Az.DevOps

# Authenticate with TFS
$securePat = ConvertTo-SecureString $pat -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ($username, $securePat)
$connection = Connect-AzAccount -Credential $credential -ServicePrincipal -Tenant $tfsUrl

# Download the repository
$repoPath = "$env:TEMP\$repo"
if (Test-Path $repoPath) {
    Remove-Item -Recurse -Force $repoPath
}
New-Item -ItemType Directory -Path $repoPath

Write-Host "Downloading repository..."
$repository = Get-AzDevOpsRepository -ProjectName $project -RepositoryName $repo
$repository | Get-AzDevOpsRepositoryContent -DestinationPath $repoPath

# Function to determine if a file is binary
function Is-BinaryFile {
    param (
        [string]$filePath
    )
    $bytes = Get-Content -Path $filePath -Encoding Byte -ReadCount 1024
    foreach ($byte in $bytes) {
        if ($byte -eq 0) {
            return $true
        }
    }
    return $false
}

# Get list of binaries
Write-Host "Getting list of binaries..."
$binariesList = @()
Get-ChildItem -Path $repoPath -Recurse -File | ForEach-Object {
    if (Is-BinaryFile -filePath $_.FullName) {
        $binariesList += [PSCustomObject]@{
            FilePath = $_.FullName
            FileSize = $_.Length
            Ignored  = $false # Implement logic to check if the file is ignored
        }
    }
}

# Create spreadsheet
Write-Host "Creating spreadsheet..."
$excel = New-Object -ComObject Excel.Application
$workbook = $excel.Workbooks.Add()
$worksheet = $workbook.Worksheets.Item(1)
$worksheet.Name = "Binaries List"

$worksheet.Cells.Item(1, 1) = "File Path"
$worksheet.Cells.Item(1, 2) = "File Size"
$worksheet.Cells.Item(1, 3) = "Ignored"

$row = 2
foreach ($binary in $binariesList) {
    $worksheet.Cells.Item($row, 1) = $binary.FilePath
    $worksheet.Cells.Item($row, 2) = $binary.FileSize
    $worksheet.Cells.Item($row, 3) = $binary.Ignored
    $row++
}

$workbook.SaveAs($outputPath)
$workbook.Close($false)
$excel.Quit()

Write-Host "Spreadsheet saved to $outputPath"

# Clean up
Write-Host "Cleaning up..."
Remove-Item -Recurse -Force $repoPath
Write-Host "Done."
