param (
    [Parameter(Mandatory=$true)]
    [string]$webhookUrl,
    [Parameter(Mandatory=$true)]
    [string]$imagePath
)

# Baca konten file gambar
$bytes = [System.IO.File]::ReadAllBytes($imagePath)

# Buat payload multipart/form-data
$boundary = "---------------------------" + (Get-Date).Ticks.ToString("x")
$utf8 = [System.Text.Encoding]::UTF8

# Buat body request
$bodyLines = (
    "--$boundary",
    "Content-Disposition: form-data; name=`"file`"; filename=`"screenshot.png`"",
    "Content-Type: image/png",
    "",
    $bytes,
    "--$boundary--"
)

$bodyStream = [System.IO.MemoryStream]::new()
foreach ($line in $bodyLines[0..3]) {
    $data = $utf8.GetBytes($line + "`r`n")
    $bodyStream.Write($data, 0, $data.Length)
}
$bodyStream.Write($bodyLines[4], 0, $bodyLines[4].Length)
$bodyStream.Write($utf8.GetBytes("`r`n--$boundary--`r`n"), 0, ($utf8.GetBytes("`r`n--$boundary--`r`n")).Length)
$bodyStream.Position = 0

# Set headers
$headers = @{
    "Content-Type" = "multipart/form-data; boundary=$boundary"
}

# Kirim request
try {
    Invoke-RestMethod -Uri $webhookUrl -Method Post -Headers $headers -Body $bodyStream -TimeoutSec 10
    Write-Host "Success"
} catch {
    Write-Host "Failed: $_"
    exit 1
} finally {
    $bodyStream.Dispose()
}
