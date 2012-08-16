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
  "Download cygwin setup.exe..."
  (New-Object System.Net.WebClient).DownloadFile("http://cygwin.com/setup.exe", $setup_path)
}

# Run setup
$setup_cmd = "$setup_path --no-startmenu --quiet-mode --site $mirror --local-package-dir $download --root $target_path"
$packs     = [string]::join(" -P ", $packages.split(" "))

#"Install cygwin and packages: $packages"
"$setup_cmd -P cygwin -P coreutils | out-null" | iex
"$setup_cmd -P $packs | out-null" | iex

# Run ssh install
$short_url = [regex]::Replace($myInvocation.MyCommand.Definition, ".*(http://.*)'\).*", '$1')
$self_url  = [System.Net.HttpWebRequest]::Create($short_url).GetResponse().ResponseUri.AbsoluteUri
$root_url  = [regex]::Replace($self_url, "(.*)/.*\.ps1", '$1')

$ssh_install_cmd = "bash <(curl -fsSkL $($root_url)/sshConfigure.sh)"
"$(Join-Path "$(Join-Path $target_path "bin")" "bash.exe") --login -c '$ssh_install_cmd'" | iex
