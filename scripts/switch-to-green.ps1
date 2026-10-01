Write-Host "Checking Green deployment..."

kubectl rollout status deployment/green-deployment --timeout=60s

if ($LASTEXITCODE -ne 0) {
    Write-Host "Green deployment rollout failed."
    exit 1
}

Write-Host "Waiting for Green pods to become Ready..."

kubectl wait `
    --for=condition=Ready `
    pod `
    -l app=bluegreen,version=green `
    --timeout=60s

if ($LASTEXITCODE -ne 0) {
    Write-Host "Green pods are not ready. Traffic will NOT be switched."
    exit 1
}

Write-Host "Green deployment is healthy."

kubectl set selector service bluegreen-service `
    app=bluegreen,version=green

if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to switch traffic to GREEN."
    exit 1
}

Write-Host "Traffic switched to GREEN successfully."