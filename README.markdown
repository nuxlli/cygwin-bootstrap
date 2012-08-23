# Use #

```
# In powershell
$options = "open_bash=false&with-sshd=22&with-apt-cyg"; powershell -NoProfile -ExecutionPolicy unrestricted -Command "(new-object net.webClient).DownloadString('http://bit.ly/psCygwinInstall?$options') | iex"

# In bash (inception option, do not ask!)
options="sshd=false&target_path=$(cygpath -w $HOME\\cygwin)" powershell -NoProfile -ExecutionPolicy unrestricted -Command "(new-object net.webClient).DownloadString('http://bit.ly/psCygwinInstall?${options}') | iex"
```

# Options #

```
mirror       # Where the mirror is to be installed cygwin (default: http://mirror.cs.vt.edu/pub/cygwin/cygwin)
uninstall    # Uninstall cygwin? (default: false)
target_path  # Path to install cygwin (default: C:\cygwin)
packages     # Extra packages to install
open_bash    # Opens bash immediately after installation (default: false);
with-sshd    # Port to run ssh or false to disabled? (default: 22)
with-apt-cyg # Install (https://code.google.com/p/apt-cyg/) and dependencies (default: false);
```
