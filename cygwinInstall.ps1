# Paths
$mirror      = "http://box-soft.com/"
$download    = Join-Path $home "Downloads\Cygwin"
$setup_path  = Join-Path $download "setup.exe"
$target_path = "C:\cygwin"
$packages    = "curl openssh wget"

# Download setup
if (-not (Test-Path $setup_path)) {
  if (-not (Test-Path $download)) {
    mkdir $download
  }
  (New-Object System.Net.WebClient).DownloadFile("http://cygwin.com/setup.exe", $setup_path)
}

# Run setup
$packs = [string]::join(" -P ", $packages.split(" "))
"$setup_path -s $mirror -L $download -l $download -R $target_path -q -P $packs" | iex
