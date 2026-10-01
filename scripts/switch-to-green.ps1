kubectl set selector service bluegreen-service app=bluegreen,version=green

if ($LASTEXITCODE -eq 0) {
    Write-Host "Traffic switched to GREEN"
} else {
    Write-Host "Failed to switch traffic to GREEN"
    exit 1
}