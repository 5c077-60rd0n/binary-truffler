param (
    [string]$username,
    [string]$pat,
    [string]$tfsUrl,
    [string]$project,
    [string]$repo,
    [string]$outputPath
)

# Ensure PSGallery repository is registered
if (-not (Get-PSRepository -Name "PSGallery" -ErrorAction SilentlyContinue)) {
    Register-PSRepository -Name "PSGallery" -SourceLocation "https://www.powershellgallery.com/api/v2" -InstallationPolicy Trusted
}

# Install required modules
if (-not (Get-Module -ListAvailable -Name Az)) {
    Install-Module -Name Az -Scope CurrentUser -Force -AllowClobber
}
if (-not (Get-Module -ListAvailable -Name AzureDevOps)) {
    Install-Module -Name AzureDevOps -Scope CurrentUser -Force
}

Import-Module Az
Import-Module AzureDevOps

# Authenticate with Azure DevOps
$securePat = ConvertTo-SecureString $pat -AsPlainText -Force
$connection = Connect-AzDevOps -Organization $tfsUrl -PersonalAccessToken $pat

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
$repositoryItems = Get-AzDevOpsRepositoryItem -ProjectName $project -RepositoryName $repo -Path "/"
foreach ($item in $repositoryItems) {
    if ($item.IsFolder -eq $false) {
        $filePath = $item.Path
        $fileContent = Get-AzDevOpsRepositoryItemContent -ProjectName $project -RepositoryName $repo -Path $filePath
        if (Is-BinaryFile -filePath $fileContent) {
            $binariesList += [PSCustomObject]@{
                FilePath = $filePath
                FileSize = $item.Size
                Ignored  = $false # Implement logic to check if the file is ignored
            }
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

Write-Host "Done."
