# Paths
$mirror      = "http://box-soft.com/"
$download    = Join-Path $home "Downloads\Cygwin"
$setup_path  = Join-Path $download "setup.exe"
$target_path = "C:\cygwin"

# Download setup
(New-Object System.Net.WebClient).DownloadFile("http://cygwin.com/setup.exe", $setup_path)

# Run setup
$setup_path -s $mirror -L $download -l $download -R $target -q -P curl -P vim -P openssh -P wget
