# Load libs
Add-Type -AssemblyName System.Web

# Parse options
$short_url = [regex]::Replace($myInvocation.MyCommand.Definition, ".*(http://.*)'\).*", '$1')
$params    = [System.Web.HttpUtility]::ParseQueryString((New-Object System.URI $short_url).Query)

# Paths
$download   = Join-Path $home "Downloads\Cygwin"
$setup_path = Join-Path $download "setup.exe"
$options    = @{
  "mirror"      = "http://mirror.cs.vt.edu/pub/cygwin/cygwin"
  "uninstall"   = "false";
  "target_path" = "C:\cygwin";
  "packages"    = "wget";
  "sshd"        = "true";
  "open_bash"   = "false";
}

foreach($key in $params.AllKeys) {
  $options[$key] = $params[$key]
}

Function check($option) { $options[$option] -eq "true" }

# Bash path
$bash_path = $(Join-Path "$(Join-Path $($options['target_path']) "bin")" "bash.exe")

if (-not (check('uninstall'))) {
  # Download setup
  if (-not (Test-Path $setup_path)) {
    if (-not (Test-Path $download)) {
      mkdir $download
    }
    "Download cygwin setup.exe..."
    (New-Object System.Net.WebClient).DownloadFile("http://cygwin.com/setup.exe", $setup_path)
  }

  # Run setup
  $setup_opt = @(
    "--no-startmenu",
    "--quiet-mode",
    "--site $($options['mirror'])",
    "--local-package-dir $download",
    "--root $($options['target_path'])"
  )
  $setup_cmd = "$setup_path $([string]::join(" ", $setup_opt))"
  
  # Packs
  if (check('sshd')) {
    $options['packages'] = "$($options['packages']) curl openssh"
  }
  
  $packs = [string]::join(" -P ", "cygwin coreutils $($options['packages'])".split(" "))

  "Install cygwin and packages: $($options['packages'])"
  "$setup_cmd -P $packs | out-null" | iex

  #Run ssh install
  if (check('sshd')) {
    $self_url  = [System.Net.HttpWebRequest]::Create($short_url).GetResponse().ResponseUri.AbsoluteUri
    $root_url  = [regex]::Replace($self_url, "(.*)/.*\.ps1", '$1')
    "$bash_path --login -c '$("bash <(curl -fsSkL $($root_url)/sshConfigure.sh)") ssh_install_cmd'" | iex
  }
  
  if (check('open_bash')) {
    "$bash_path --login -i" | iex
  }

# Uninstall
} else {
  if (Test-Path $bash_path) {
    "Removing cygwin"
    "$bash_path --login -c 'cygrunsrv -E sshd && cygrunsrv -R sshd'" | iex
    "$bash_path --login -c 'chown -R $($env:USERNAME) /var /home'" | iex
    "$bash_path --login -c 'chmod 777 /var /home'" | iex
    Remove-Item -Recurse -Force $options['target_path']
  }
}
