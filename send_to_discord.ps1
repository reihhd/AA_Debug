param (
    [Parameter(Mandatory=$true)]
    [string]$webhookUrl,
    [Parameter(Mandatory=$true)]
    [string]$imagePath,
    [string]$jsonPath = ""
)

# Fungsi untuk mengirim file + embed (jika jsonPath disediakan)
if ($jsonPath -and (Test-Path $jsonPath)) {
    $payload = Get-Content $jsonPath -Raw
    $boundary = "---------------------------" + (Get-Date).Ticks.ToString("x")
    $utf8 = [System.Text.Encoding]::UTF8

    $bodyLines = @(
        "--$boundary",
        "Content-Disposition: form-data; name=`"payload_json`"",
        "Content-Type: application/json",
        "",
        $payload,
        "--$boundary",
        "Content-Disposition: form-data; name=`"file`"; filename=`"screenshot.png`"",
        "Content-Type: image/png",
        "",
        [System.IO.File]::ReadAllBytes($imagePath),
        "--$boundary--"
    )

    $bodyStream = [System.IO.MemoryStream]::new()
    for ($i = 0; $i -le 5; $i++) {
        $data = $utf8.GetBytes($bodyLines[$i] + "`r`n")
        $bodyStream.Write($data, 0, $data.Length)
    }
    $imgBytes = $bodyLines[6]  # Langsung byte array
    $bodyStream.Write($imgBytes, 0, $imgBytes.Length)
    $bodyStream.Write($utf8.GetBytes("`r`n--$boundary--`r`n"), 0, ($utf8.GetBytes("`r`n--$boundary--`r`n")).Length)
    $bodyStream.Position = 0

    $headers = @{"Content-Type" = "multipart/form-data; boundary=$boundary"}
} else {
    # Kirim hanya file (tanpa embed)
    $boundary = "---------------------------" + (Get-Date).Ticks.ToString("x")
    $utf8 = [System.Text.Encoding]::UTF8
    $fileBytes = [System.IO.File]::ReadAllBytes($imagePath)

    $bodyLines = @(
        "--$boundary",
        "Content-Disposition: form-data; name=`"file`"; filename=`"screenshot.png`"",
        "Content-Type: image/png",
        "",
        $fileBytes,
        "--$boundary--"
    )

    $bodyStream = [System.IO.MemoryStream]::new()
    for ($i = 0; $i -le 3; $i++) {
        $data = $utf8.GetBytes($bodyLines[$i] + "`r`n")
        $bodyStream.Write($data, 0, $data.Length)
    }
    $bodyStream.Write($bodyLines[4], 0, $bodyLines[4].Length)
    $bodyStream.Write($utf8.GetBytes("`r`n--$boundary--`r`n"), 0, ($utf8.GetBytes("`r`n--$boundary--`r`n")).Length)
    $bodyStream.Position = 0

    $headers = @{"Content-Type" = "multipart/form-data; boundary=$boundary"}
}

try {
    $response = Invoke-RestMethod -Uri $webhookUrl -Method Post -Headers $headers -Body $bodyStream -TimeoutSec 10
    Write-Host "Success"
} catch {
    Write-Host "Failed: $_"
    exit 1
} finally {
    $bodyStream.Dispose()
    if ($jsonPath -and (Test-Path $jsonPath)) { Remove-Item $jsonPath -Force -ErrorAction SilentlyContinue }
}
