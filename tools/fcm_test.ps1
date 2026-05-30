param(
  [Parameter(Mandatory=$true)]
  [string]$DeviceToken,
  [string]$Title = "Test",
  [string]$Body = "This is a test notification"
)

# اقرأ ملف Service Account
$jsonPath = Join-Path $PSScriptRoot "service-account-key.json"
if (-not (Test-Path $jsonPath)) { $jsonPath = "service-account-key.json" }
if (-not (Test-Path $jsonPath)) {
  Write-Host "❌ service-account-key.json not found" -ForegroundColor Red
  exit 1
}

$sa = Get-Content $jsonPath -Raw | ConvertFrom-Json
$ProjectId = $sa.project_id
$ClientEmail = $sa.client_email
$PrivateKey = $sa.private_key

Write-Host "Project ID : $ProjectId" -ForegroundColor Cyan
Write-Host "Client Email: $ClientEmail" -ForegroundColor Cyan

# تحميل BouncyCastle من NuGet
$bcDllPath = "$env:TEMP\BouncyCastle.Cryptography.dll"
if (-not (Test-Path $bcDllPath)) {
  Write-Host "🔄 Downloading BouncyCastle (required for RSA signing)..." -ForegroundColor Cyan
  $nugetUrl = "https://www.nuget.org/api/v2/package/BouncyCastle.Cryptography/2.2.1"
  $zipPath = "$env:TEMP\bc.zip"
  Invoke-WebRequest -Uri $nugetUrl -OutFile $zipPath -UseBasicParsing
  Expand-Archive -Path $zipPath -DestinationPath "$env:TEMP\bc" -Force
  $dllFullPath = Get-ChildItem -Path "$env:TEMP\bc" -Recurse -Filter "BouncyCastle.Cryptography.dll" | Select-Object -First 1 -ExpandProperty FullName
  Copy-Item $dllFullPath $bcDllPath -Force
  Remove-Item "$env:TEMP\bc" -Recurse -Force -ErrorAction SilentlyContinue
  Remove-Item $zipPath -Force -ErrorAction SilentlyContinue
}

Add-Type -Path $bcDllPath

# إنشاء JWT assertion باستخدام BouncyCastle
$header = @{ alg = "RS256"; typ = "JWT" }
$now = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
$payload = @{
  iss = $ClientEmail
  scope = "https://www.googleapis.com/auth/firebase.messaging"
  aud = "https://oauth2.googleapis.com/token"
  exp = $now + 3600
  iat = $now
}

function Base64UrlEncode($bytes) {
  return [Convert]::ToBase64String($bytes).TrimEnd('=').Replace('+', '-').Replace('/', '_')
}

$b64Header = Base64UrlEncode ([Text.Encoding]::UTF8.GetBytes(($header | ConvertTo-Json -Compress)))
$b64Payload = Base64UrlEncode ([Text.Encoding]::UTF8.GetBytes(($payload | ConvertTo-Json -Compress)))
$signatureInput = "$b64Header.$b64Payload"

# استيراد Private Key عبر BouncyCastle
$pemReader = New-Object Org.BouncyCastle.OpenSsl.PemReader([System.IO.StringReader]::new($PrivateKey))
$keyObj = $pemReader.ReadObject()
if ($keyObj -is [Org.BouncyCastle.Crypto.Parameters.RsaPrivateCrtKeyParameters]) {
  $privKey = $keyObj
} elseif ($keyObj -is [Org.BouncyCastle.Crypto.AsymmetricCipherKeyPair]) {
  $privKey = $keyObj.Private
} else {
  throw "Unexpected key type: $($keyObj.GetType().Name)"
}
$signer = [Org.BouncyCastle.Crypto.Signers.RsaDigestSigner]::new([Org.BouncyCastle.Crypto.Digests.Sha256Digest]::new())
$signer.Init($true, $privKey)
$dataBytes = [Text.Encoding]::UTF8.GetBytes($signatureInput)
$signer.BlockUpdate($dataBytes, 0, $dataBytes.Length)
$sigBytes = $signer.GenerateSignature()
$b64Sig = Base64UrlEncode $sigBytes
$assertion = "$signatureInput.$b64Sig"

# الحصول على Access Token
Write-Host "🔄 Getting access token..." -ForegroundColor Cyan
$tokenBody = @{ grant_type = "urn:ietf:params:oauth:grant-type:jwt-bearer"; assertion = $assertion }
$tokenRes = Invoke-RestMethod -Method Post -Uri "https://oauth2.googleapis.com/token" -ContentType "application/x-www-form-urlencoded" -Body $tokenBody
Write-Host "✅ Access token obtained" -ForegroundColor Green

# إرسال FCM v1 message
$fcmPayload = @{
  message = @{
    token = $DeviceToken
    notification = @{ title = $Title; body = $Body }
  }
} | ConvertTo-Json -Depth 3

Write-Host "🔄 Sending FCM message..." -ForegroundColor Cyan
$fcmUrl = "https://fcm.googleapis.com/v1/projects/$ProjectId/messages:send"
try {
  $fcmRes = Invoke-RestMethod -Method Post -Uri $fcmUrl -Headers @{ Authorization = "Bearer $($tokenRes.access_token)" } -ContentType "application/json" -Body $fcmPayload
  Write-Host "✅ SUCCESS: $($fcmRes | ConvertTo-Json -Depth 3)" -ForegroundColor Green
} catch [System.Net.WebException] {
  Write-Host "❌ FAILED: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
  $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
  $errText = $reader.ReadToEnd()
  try { $errText = ($errText | ConvertFrom-Json | ConvertTo-Json -Depth 3) } catch {}
  Write-Host $errText -ForegroundColor Red
} catch {
  Write-Host "❌ ERROR: $_" -ForegroundColor Red
}
