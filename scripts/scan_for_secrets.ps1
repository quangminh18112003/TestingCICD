<#
Simple repository secret scan using Select-String.
Usage: run from repo root in PowerShell
  ./scripts/scan_for_secrets.ps1
#>

$patterns = @(
    'SG\.[A-Za-z0-9_\-\.]+' ,
    'SENDGRID',
    'CLOUDINARY',
    'CLOUDINARY_API_KEY',
    'CLOUDINARY_API_SECRET',
    'VNPAY',
    'VNPAY_HASH_SECRET',
    'DB_PASSWORD',
    'MYSQL_ROOT_PASSWORD',
    'JWT_SECRET',
    'PASSWORD=' ,
    'api_key=',
    'api_secret='
)

Write-Output "Scanning repo for likely secrets..."

Get-ChildItem -Path . -Recurse -File -ErrorAction SilentlyContinue |
  Where-Object { $_.FullName -notmatch '\\.git' } |
  Select-String -Pattern $patterns -SimpleMatch -List | ForEach-Object {
    [PSCustomObject]@{
      File = $_.Path
      Line = $_.LineNumber
      Match = ($_.Line.Trim())
    }
  } | Format-Table -AutoSize

Write-Output "Done. If anything shows up here, rotate the secret in the provider immediately and remove from code/history." 
