# Use #

```
  $options = "open_bash=true&sshd=true"; powershell -NoProfile -ExecutionPolicy unrestricted -Command "(new-object net.webClient).DownloadString('http://bit.ly/psCygwinInstall?$options') | iex"
```

# Options #

```
  mirror       # Where the mirror is to be installed cygwin (default: http://mirror.cs.vt.edu/pub/cygwin/cygwin)
  uninstall    # Uninstall cygwin? (default: false)
  target_path  # Path to install cygwin (default: C:\cygwin)
  packages     # Extra packages to install
  sshd         # Enable ssh after install? (default: true)
  open_bash    # Opens bash immediately after installation (default: false);
  apt-cyg      # Install (https://code.google.com/p/apt-cyg/) and dependencies (default: false);
```
