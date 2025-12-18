#!/usr/bin/env pwsh
# Script de test pour vérifier les trajets dans la base de données

Write-Host "🚀 Test API Moov Backend" -ForegroundColor Cyan
Write-Host "=========================" -ForegroundColor Cyan

$baseUrl = "http://localhost:3000/api"

# 1. Vérifier que le serveur est en marche
Write-Host "`n1. Vérification du serveur..." -ForegroundColor Yellow
try {
    $health = Invoke-RestMethod -Uri "$baseUrl/health" -Method GET
    Write-Host "✅ Serveur OK: $($health.status)" -ForegroundColor Green
} catch {
    Write-Host "❌ Serveur non accessible: $_" -ForegroundColor Red
    exit 1
}

# 2. Essayer de se connecter
Write-Host "`n2. Connexion..." -ForegroundColor Yellow
$loginData = @{
    email = "test@example.com"
    password = "test123"
} | ConvertTo-Json

try {
    $loginResult = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method POST -Body $loginData -ContentType "application/json"
    $token = $loginResult.token
    Write-Host "✅ Connexion réussie!" -ForegroundColor Green
    Write-Host "   Token: $($token.Substring(0, 20))..." -ForegroundColor Gray
} catch {
    Write-Host "❌ Erreur connexion: $_" -ForegroundColor Red
    Write-Host "   Essayez avec un compte valide" -ForegroundColor Yellow
    exit 1
}

# 3. Récupérer les trajets
Write-Host "`n3. Récupération des trajets publiés..." -ForegroundColor Yellow
$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

try {
    $rides = Invoke-RestMethod -Uri "$baseUrl/rides/my-rides" -Method GET -Headers $headers
    Write-Host "✅ Réponse reçue!" -ForegroundColor Green
    Write-Host "   Contenu: " -ForegroundColor Gray
    $rides | ConvertTo-Json -Depth 5 | Write-Host
} catch {
    Write-Host "❌ Erreur récupération trajets: $_" -ForegroundColor Red
    Write-Host "   Response: $($_.Exception.Response)" -ForegroundColor Yellow
}

# 4. Lister tous les trajets (si route publique existe)
Write-Host "`n4. Récupération de TOUS les trajets..." -ForegroundColor Yellow
try {
    $allRides = Invoke-RestMethod -Uri "$baseUrl/rides/all" -Method GET -Headers $headers
    Write-Host "✅ Trajets trouvés:" -ForegroundColor Green
    $allRides | ConvertTo-Json -Depth 5 | Write-Host
} catch {
    Write-Host "⚠️ Route /rides/all non disponible ou erreur" -ForegroundColor Yellow
}

Write-Host "`n✅ Test terminé!" -ForegroundColor Cyan
