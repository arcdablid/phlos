# Install all phlos curated apps
phlos-install: phlos-install-brews phlos-install-vscode-extentions


# Install only Homebrews
phlos-install-brews:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Installing Homebrew Formulae..."
    brew bundle --file /usr/share/phlos/brewfile
    echo "Homebrew formulae installation complete."

# Setup Ghostty terminal configuration
phlos-install-vscode-extentions:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Installing VSCode Extentions..."
    # Read file lines without inline comments
    xargs -a <( awk -F ' # ' '{print $1}' /usr/share/phlos/vscode_extentions ) code --install-extension
    echo "Flatpaks installation complete."

# Setup shell configurations (zsh, bash)
phlos-setup-dotfiles:
    #!/usr/bin/env bash
    set -euo pipefail

    # Setup Bash configuration
    echo "Setting up Bash configuration..."
    cp -f "/etc/arcdablid/.bashrc" "${HOME}/.bashrc"
    cp -f "/etc/arcdablid/.bash_profile" "${HOME}/.bash_profile"
    cp -f "/etc/arcdablid/.bash_logout" "${HOME}/.bash_logout"
    echo "Bash configuration complete."

    echo "Shell configurations setup complete."

# Clean up old packages and Docker/Podman images and volumes
phlos-clean:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Cleaning up system..."
    docker system prune -af
    podman system prune -af
    flatpak uninstall --unused
    rpm-ostree cleanup -bm
    # nix-collect-garbage -d
    sudo docker system prune -af
    sudo podman system prune -af
    # sudo -i nix-collect-garbage -d
