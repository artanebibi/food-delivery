Write-Host "Deleting existing cluster..."
k3d cluster delete fd

Write-Host "Creating cluster..."
k3d cluster create fd --agents 2 --port "80:80@loadbalancer" --api-port 127.0.0.1:1706

$timeout = 120
while ((kubectl get nodes --no-headers | Select-String -Pattern " Ready " -AllMatches).Matches.Count -lt 3) {
    Write-Host "Waiting for nodes to be ready..."
    Start-Sleep -Seconds 5
    $timeout -= 5
    if ($timeout -le 0) {
        Write-Host "Timeout waiting for nodes. Exiting."
        exit 1
    }
}

kubectl apply -f namespace.yml

Write-Host "Waiting for namespace to be active..."
$timeout = 30
while ((kubectl get namespace devops-project -o jsonpath='{.status.phase}') -ne "Active") {
    Write-Host "Waiting for namespace to become Active..."
    Start-Sleep -Seconds 2
    $timeout -= 2
    if ($timeout -le 0) {
        Write-Host "Namespace not active, exiting."
        exit 1
    }
}

kubectl apply -f database.yml

kubectl apply -f backend.yml

kubectl apply -f frontend.yml

Write-Host "Waiting for frontend deployment to be ready..."
kubectl rollout status deployment frontend -n devops-project --timeout=120s

kubectl apply -f ingress-controller.yml

