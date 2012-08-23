# Load libs
Add-Type -AssemblyName System.Web

# Parse options
$short_url = [regex]::Replace($myInvocation.MyCommand.Definition, ".*(http://.*)'\).*", '$1')
$params    = [System.Web.HttpUtility]::ParseQueryString((New-Object System.URI $short_url).Query)

# Fixing to support bash and powershell
if ($env:home -eq $null) { $env:home = $home } 
if ($env:USERNAME -eq $null) { $env:USERNAME = $env:USER }

# Paths
$download   = Join-Path $env:home "Downloads\Cygwin"
$setup_path = Join-Path $download "setup.exe"
$options    = @{
  "mirror"      = "http://mirror.cs.vt.edu/pub/cygwin/cygwin"
  "uninstall"   = "false";
  "target_path" = "C:\cygwin";
  "packages"    = "";
  "open_bash"   = "false";
  "with-sshd"   = "22";
  "with-apt-cyg"= "false";
}

foreach($key in $params.AllKeys) {
  $options[$key] = $params[$key]
}

# Utils
function check($option) {
  $options[$option] -ne "false"
}

function dependence_for($mod, $dependences) {
  if (check($mod)) {
    $options["packages"] = ("$($options["packages"]) $dependences").trim()
  }
}

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
  dependence_for 'with-sshd' 'curl openssh'
  dependence_for 'with-apt-cyg' 'wget'
  $packs = [string]::join(" -P ", "cygwin coreutils $($options['packages'])".trim().split(" "))

  "Install cygwin and packages: $($options['packages'])"
  "$setup_cmd -P $packs | out-null" | iex
  
  if (Test-Path $bash_path) {
    # Configure sshd
    if (check('with-sshd')) {
      $self_url    = [System.Net.HttpWebRequest]::Create($short_url).GetResponse().ResponseUri.AbsoluteUri
      $root_url    = [regex]::Replace($self_url, "(.*)/.*\.ps1", '$1')
      $sshd_config = "bash <(curl -fsSkL $root_url/sshConfigure.sh) $($options['with-sshd'])"
      "$bash_path --login -c '$sshd_config ssh_install_cmd'" | iex
    }
  
    # Install apt-cyg
    if (check('with-apt-cyg')) {
      "$bash_path --login -c '(curl -fsSkL https://apt-cyg.googlecode.com/svn/trunk/apt-cyg) > /bin/apt-cyg && chmod +x /bin/apt-cyg'" | iex
    }
  
    # Open bash after install?
    if (check('open_bash')) { "$bash_path --login -i" | iex }
  } else {
    "Install error, cygwin not installed."
  }

# Uninstall
} else {
  if (Test-Path $bash_path) {
    "Removing cygwin"
    "$bash_path --login -c 'cygrunsrv -E sshd'" | iex
    "$bash_path --login -c 'cygrunsrv -R sshd'" | iex
    "$bash_path --login -c 'chown -R $($env:USERNAME) /var /home'" | iex
    "$bash_path --login -c 'chmod 777 /var /home'" | iex
    Remove-Item -Recurse -Force $options['target_path']
  }
}
