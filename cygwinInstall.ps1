cls
$args
$url = [regex]::Replace($myInvocation.MyCommand.Definition, ".*(http://.*)'\).*", '$1')
[System.Net.HttpWebRequest]::Create($url).GetResponse().ResponseUri.AbsoluteUri

exit

# Paths
$mirror      = "http://mirror.cs.vt.edu/pub/cygwin/cygwin"
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
$setup_cmd = "$setup_path --no-startmenu --quiet-mode --site $mirror --local-package-dir $download --root $target_path"
$packs     = [string]::join(" -P ", $packages.split(" "))

"$setup_cmd -P cygwin -P coreutils | out-null" # | iex
"$setup_cmd -P $packs | out-null" # | iex

# Run ssh install
# "$(Join-Path "$(Join-Path $target_path "bin")" "bash.exe") 'date'" | iex
