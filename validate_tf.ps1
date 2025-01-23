$tfExePath = "tf.exe"

# Check if tf.exe is accessible
try {
    $versionOutput = & $tfExePath
    Write-Host "tf.exe is accessible and working."
    Write-Host $versionOutput
} catch {
    Write-Host "tf.exe is not accessible. Please ensure it is installed and added to your PATH."
    exit 1
}

# Run a sample command to list the contents of a TFS project
$projectPath = "$/YourProject"
try {
    $dirOutput = & $tfExePath dir $projectPath /recursive
    Write-Host "Successfully listed contents of project: $projectPath"
    Write-Host $dirOutput
} catch {
    Write-Host "Failed to list contents of project: $projectPath"
    Write-Host $_.Exception.Message
    exit 1
}
