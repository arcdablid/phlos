# phlos &nbsp; [![bluebuild](https://github.com/arcdablid/phlos/actions/workflows/build.yml/badge.svg)](https://github.com/arcdablid/phlos/actions/workflows/build.yml)

A custom immutable Linux OS based on [The Bazzite Developer Experience](https://github.com/ublue-os/bazzite-dx) built using [BlueBuild](https://github.com/blue-build/template).

## Notable additions & features
- Ghostty terminal
- TeamViewer - because RustDesk isn't everywhere yet.
- VirtualBox - script by [by ettfemnio and Preston Petrie](https://github.com/ettfemnio/bazzite-virtualbox/blob/main/build.sh) using forked reference to monitor changes for security.
- Pre-installed extra [system packages & flatpaks](https://github.com/arcdablid/phlos/recipes/recipe.yml)
- Curated list of optional to install [Homebrew formulae, Cargo pkgs, Python pkgs & VSCode extensions](https://github.com/arcdablid/phlos/files/system/usr/share/phlos/index.yml)
- My [dotfiles](https://github.com/arcdablid/phlos/files/system/usr/share/phlos/dotfiles) should you wish to install them. Will probably move them to their own (chezmoi) repo in the future.
- [`rfs`](https://github.com/arcdablid/phlos/files/system/usr/bin/rfs) command to easily add/remove SMB/CIFS shares, via interactive input or `.toml` config files with the following format:

  ```toml
    # One server and its shares
    [[servers]]
    name = "your_server_name_here_1"
    addresses = [
        # In descending order of priority
        "10.10.10.10",      # 10G SFP+
        "192.168.192.168",  # 1G LAN
        "100.90.80.70",     # Tailscale
    ]
    [[servers.shares]]
    name = "your_share_name_here_1"
    mount_under = "~/rfs"   # Default location for user shares
    username = "your_username_here"
    password = "your_password_here"
    domain = "your_domain_here"
    [[servers.shares]]
    name = "your_share_name_here_2"
    mount_under = "~/elsewhere"
    username = "your_username_here"
    password = "your_password_here"
    domain = "your_domain_here"

    # Another server and its shares
    [[servers]]
    name = "your_server_name_here_N"
    addresses = [
        # In descending order of priority
        "10.10.10.10",      # 10G SFP+
        "192.168.192.168",  # 1G LAN
        "100.90.80.70",     # Tailscale
    ]
    [[servers.shares]]
    name = "your_share_name_here_1"
    mount_under = "~/somewhere"
    username = "your_username_here"
    password = "your_password_here"
    domain = "your_domain_here"
    [[servers.shares]]
    name = "your_share_name_here_2"
    mount_under = "~/shares"
    username = "your_username_here"
    password = "your_password_here"
    domain = "your_domain_here"
  ```

  The intention of `rfs` is to make it easy for users to mount shares under their home folder. Linux doesn't allow mounting of remote filesystems at user-level and mounting through the file browser has limitations, at least in as far as direct access from other applications. I also wanted extra functionality like the ability to specify multiple addresses per server, like a LAN one for when at home and a Tailscale one when out & about, automatically switching between them.
  Thusly, `rfs` generates per share systemd `.mount`, `.automount`, `.service` & `.timer` units, along with a journald config file for debugging, a credentials file by default under the `~/.config/rfs` path, and a script run by the `.service` unit which contains the main logic for checking server addresses & availability and acting accordingly - start, refresh or stop things. The `.timer` controls the frequency of how often this process happens. Lastly, a faux-registry file is generated to facilitate easy removal of shares later on. Check `rfs --help` for adjusting some (opinionated) default options.

  ### WARNING
  **`rfs` is a work in progress and far from perfect! I'm sure there's things that could be coded a lot better and that there's scenarios I haven't tested or accounted for, assuming it's something that could/should be handled at this level. Put succinctly, use at your own risk!**

- Specific `ujust` recipes to auto-setup most of the above & other useful extras:

  ```bash
    phlos-setup-all                  # Install all phlos curated apps
    phlos-setup-cargo-pkgs           # Setup only Cargo pkgs.
    phlos-setup-dotfiles             # Setup dotfiles.
    phlos-setup-homebrew             # Install only Homebrew taps & formulae.
    phlos-setup-pip-pkgs             # Setup only Python pkgs.
    phlos-setup-vscode-extensions    # Setup only VSCode extensions.
    phlos-vboxusers-add-current-user # Add vboxusers group to system if not there already and current user to it.
    phlos-add-rfs                    # Shortcut to add SMB/CIFS shares.
    phlos-remove-rfs                 # Shortcut to remove SMB/CIFS shares.
    phlos-clean                      # Clean up old packages and Docker/Podman images and volumes.
  ```

## Installation

To install you need to rebase from an existing atomic Fedora installation.

> [!WARNING]
> **Rebasing between different desktop environments may cause issues!**

- First rebase to the unsigned image, to get the proper signing keys and policies installed:
  ```
  rpm-ostree rebase ostree-unverified-registry:ghcr.io/arcdablid/phlos:latest
  ```
- Reboot to complete the rebase:
  ```
  systemctl reboot
  ```
- Rebasing to the signed image should happen automatically after the system comes up again. It might take a few depending on system/network performance. Manually, it can be done like so:
  ```
  rpm-ostree rebase ostree-image-signed:docker://ghcr.io/arcdablid/phlos:latest
  ```
- Reboot again to complete the installation
  ```
  systemctl reboot
  ```

## Verification

These images are signed with [Sigstore](https://www.sigstore.dev/)'s [cosign](https://github.com/sigstore/cosign). You can verify the signature by downloading the `cosign.pub` file from this repo and running the following command:

```bash
cosign verify --key cosign.pub ghcr.io/arcdablid/phlos
```
