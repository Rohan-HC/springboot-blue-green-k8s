kubectl set selector service bluegreen-service app=bluegreen,version=blue

if ($LASTEXITCODE -eq 0) {
    Write-Host "Traffic switched to BLUE"
} else {
    Write-Host "Failed to switch traffic to BLUE"
    exit 1
}