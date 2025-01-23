$tfExePath = "C:\Program Files\Microsoft Visual Studio\2022\TeamExplorer\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer\tf.exe"

# Check if tf.exe is accessible
if (-Not (Test-Path $tfExePath)) {
    Write-Host "tf.exe not found at path: $tfExePath" -ForegroundColor Red
    exit 1
}

function Get-FileSize {
    param (
        [string]$itemfullpath
    )
    Write-Verbose "Evaluating: $itemfullpath" -Verbose
    # Check if file exceeds 100 MB
    $rslt = & $tfExePath info "$itemfullpath" | Select-String -Pattern "size"
    if ([int64]$rslt.Line.Split(':')[1] -gt 100000000) {
        Write-Host "File: $itemfullpath exceeds 100 MB" -ForegroundColor Red
        $filenameCountExceed100MB += 1
        $ExceededSize = "y"
        Write-Output "$itemfullpath`tsize: $([int64]$rslt.Line.Split(':')[1])" | Tee-Object -FilePath "C:\temp\$($item.name)_FileList.txt" -Append
        return $ExceededSize
    }
}

function Is-BinaryFile {
    param (
        [string]$filePath
    )
    $bytes = [System.IO.File]::ReadAllBytes($filePath)
    foreach ($byte in $bytes) {
        if ($byte -eq 0) {
            return $true
        }
    }
    return $false
}

function Is-Ignored {
    param (
        [string]$filePath
    )
    $gitignore = Get-Content -Path ".gitignore" -ErrorAction SilentlyContinue
    $tfignore = Get-Content -Path ".tfignore" -ErrorAction SilentlyContinue
    $tfattributes = Get-Content -Path ".tfattributes" -ErrorAction SilentlyContinue

    foreach ($pattern in $gitignore + $tfignore + $tfattributes) {
        if ($filePath -like $pattern) {
            return $true
        }
    }
    return $false
}

function Get-BinaryFiles {
    param (
        [string]$directory
    )
    $binaryFiles = @()
    Get-ChildItem -Path $directory -Recurse -File | ForEach-Object {
        if (Is-BinaryFile -filePath $_.FullName) {
            $binaryFiles += $_.FullName
        }
    }
    return $binaryFiles
}

function Get-ProjectFolderFileSize {
    param (
        [array]$folders
    )
    # Retrieve List Filename FullPath from a project
    $itemEvaluate = 0
    $fileNameCount = 0
    $filenameCountExceed100MB = 0
    $fileNameCountMain = 0
    $fileNameCountCOTS = 0
    foreach ($proj_item in $folders) {
        if ($proj_item -eq "") {
            # Skipping blank line
        } else {
            if ($proj_item.StartsWith("$/")) {
                # Folder path
                $path = $proj_item.Split(':')
            } elseif ($proj_item -like "*.*" -and !($proj_item.Contains('$'))) {
                # Filename Full Path
                $itemfullpath = $path[0] + $proj_item -join "/"
                
                if ($itemfullpath.Contains("/Main/") -or $itemfullpath.Contains("/MAIN/")) {
                    if (Get-FileSize -itemfullpath $itemfullpath -eq "y") {
                        Write-Verbose "File: $itemfullpath exceeds 100 MB" -Verbose
                        $filenameCountExceed100MB += 1
                    }
                    $filenameCountMain += 1
                }
            
                if ($itemfullpath.Contains("/COTS/")) {
                    if (Get-FileSize -itemfullpath $itemfullpath -eq "y") {
                        Write-Verbose "File: $itemfullpath exceeds 100 MB" -Verbose
                        $filenameCountExceed100MB += 1
                    }
                    $fileNameCountCOTS += 1
                }
                $fileNameCount += 1
            }
        }
        $itemEvaluate += 1
        Write-Progress -PercentComplete ($itemEvaluate / $folders.Count * 100) -Status "Processed $proj_count Project of $($items.count)" -Activity "Project Name: $projectname`tItem $itemEvaluate of $($folders.count)`tFilename Count from MAIN folder: $filenameCountMain`tFilename Count from COTS folder: $fileNameCountCOTS"
    }
    if ($filenameCountExceed100MB -gt 0) {
        Write-Output "Project Name: $projectname COTS\MAIN File Count: $filenameCount File Count Exceeded 100MB: $filenameCountExceed100MB" | Tee-Object -FilePath "C:\temp\$($projectname)_FileList.txt" -Append
    }
}

function Get-ProjectFolderBinaries {
    param (
        [array]$folders
    )
    $binaryFiles = @()
    foreach ($proj_item in $folders) {
        if ($proj_item -eq "") {
            # Skipping blank line
        } else {
            if ($proj_item.StartsWith("$/")) {
                # Folder path
                $path = $proj_item.Split(':')
            } elseif ($proj_item -like "*.*" -and !($proj_item.Contains('$'))) {
                # Filename Full Path
                $itemfullpath = $path[0] + $proj_item -join "/"
                if (Is-BinaryFile -filePath $itemfullpath) {
                    $binaryFiles += $itemfullpath
                }
            }
        }
    }
    return $binaryFiles
}

function Create-Spreadsheet {
    param (
        [array]$binariesList,
        [string]$outputPath
    )
    $excel = New-Object -ComObject Excel.Application
    $workbook = $excel.Workbooks.Add()
    $worksheet = $workbook.Worksheets.Item(1)
    $worksheet.Name = "Binaries List"

    $worksheet.Cells.Item(1, 1) = "File Path"
    $worksheet.Cells.Item(1, 2) = "File Size"
    $worksheet.Cells.Item(1, 3) = "Ignored"

    $row = 2
    foreach ($binary in $binariesList) {
        $fileSize = (Get-Item $binary).Length
        $ignored = Is-Ignored -filePath $binary
        $worksheet.Cells.Item($row, 1) = $binary
        $worksheet.Cells.Item($row, 2) = $fileSize
        $worksheet.Cells.Item($row, 3) = $ignored
        $row++
    }

    $workbook.SaveAs($outputPath)
    $workbook.Close($false)
    $excel.Quit()

    Write-Host "Spreadsheet saved to $outputPath"
}

# Main

# Initialize Counters
$aproj_count = 0
$rproj_count = 0
$global:proj_count = 0

# Exclude the following projects
$excludeProj = @(
    "Project1",
    "Project2",
    "Project3"
)

# Replace with your TFS API URL
$apiUrl = "https://your-tfs-url/tfs/YourCollection/_apis/projects?api-version=1.0&%24top=500"

$project = Invoke-RestMethod -Uri $apiUrl -UseDefaultCredentials
$items = $project.value | Select-Object -Property name, description | Sort-Object name
$binariesList = @()
foreach ($item in $items) {
    if ($item.description -notmatch "retired") {
        if ($excludeProj -contains $item.name) {
            Write-Output "$($item.name)`tskipped" | Tee-Object -FilePath "C:\temp\TFVCProjects.txt" -Append
            $rproj_count += 1
        } else {
            try {
                Write-Host "Processing project: $($item.name)"
                $folders = & $tfExePath dir "$/$($item.name)" /recursive
                Write-Host "Folders retrieved for project: $($item.name)"
                $global:projectname = $($item.name)
                Get-ProjectFolderFileSize -folders $folders
                $binariesList += Get-ProjectFolderBinaries -folders $folders
                Write-Output "$($item.name)`t$($folders.count)" | Tee-Object -FilePath "C:\temp\TFVCProjects.txt" -Append
                $aproj_count += 1
            } catch {
                Write-Host "Failed to retrieve folders for project: $($item.name)" -ForegroundColor Red
                Write-Host $_.Exception.Message
            }
        }
    } else {
        $rproj_count += 1
    }
    $proj_count += 1
    # Write-Progress -PercentComplete ($proj_count / $items.count * 100) -Status "Processed $proj_count Project of $($items.count)" -Activity "Active Project: $aproj_count`tRetired Project: $rproj_count"
}

# Save the spreadsheet to the current workspace directory
$currentWorkspace = (Get-Location).Path
$outputPath = Join-Path -Path $currentWorkspace -ChildPath "output.xlsx"

Create-Spreadsheet -binariesList $binariesList -outputPath $outputPath

Write-Output "Total Active Projects: $aproj_count`tTotal Retired Projects: $rproj_count" | Tee-Object -FilePath "C:\temp\TFVCProjects.txt" -Append
Write-Output "Total Projects: $proj_count" | Tee-Object -FilePath "C:\temp\TFVCProjects.txt" -Append
