# Install all phlos curated apps
phlos-setup-all: phlos-setup-dotfiles phlos-setup-flatpaks phlos-setup-homebrew phlos-setup-vscode-extensions phlos-setup-cargo-pkgs phlos-setup-pip-pkgs

export PHLOS_INDEX := "/usr/share/phlos/index.yml"

#------------------------------------------------------------------------------
# ANSI escape code variables.
# ------------------------------------------------------------------------------

# Usage: printf "I ${Red}love${Color_Off} Stack Overflow\n"
# If you are using the echo command, be sure to use the -e flag to allow backslash escapes.
# echo -e "I ${Red}love${Color_Off} Stack Overflow"

# Reset
export Color_Off := '\033[0m'       # Text Reset

# Regular Colors
export Black := '\033[0;30m'        # Black
export Red := '\033[0;31m'          # Red
export Green := '\033[0;32m'        # Green
export Yellow := '\033[0;33m'       # Yellow
export Blue := '\033[0;34m'         # Blue
export Purple := '\033[0;35m'       # Purple
export Cyan := '\033[0;36m'         # Cyan
export White := '\033[0;37m'        # White

# Bold
export BBlack := '\033[1;30m'       # Black
export BRed := '\033[1;31m'         # Red
export BGreen := '\033[1;32m'       # Green
export BYellow := '\033[1;33m'      # Yellow
export BBlue := '\033[1;34m'        # Blue
export BPurple := '\033[1;35m'      # Purple
export BCyan := '\033[1;36m'        # Cyan
export BWhite := '\033[1;37m'       # White

# Underline
export UBlack := '\033[4;30m'       # Black
export URed := '\033[4;31m'         # Red
export UGreen := '\033[4;32m'       # Green
export UYellow := '\033[4;33m'      # Yellow
export UBlue := '\033[4;34m'        # Blue
export UPurple := '\033[4;35m'      # Purple
export UCyan := '\033[4;36m'        # Cyan
export UWhite := '\033[4;37m'       # White

# Background
export On_Black := '\033[40m'       # Black
export On_Red := '\033[41m'         # Red
export On_Green := '\033[42m'       # Green
export On_Yellow := '\033[43m'      # Yellow
export On_Blue := '\033[44m'        # Blue
export On_Purple := '\033[45m'      # Purple
export On_Cyan := '\033[46m'        # Cyan
export On_White := '\033[47m'       # White

# High Intensity
export IBlack := '\033[0;90m'       # Black
export IRed := '\033[0;91m'         # Red
export IGreen := '\033[0;92m'       # Green
export IYellow := '\033[0;93m'      # Yellow
export IBlue := '\033[0;94m'        # Blue
export IPurple := '\033[0;95m'      # Purple
export ICyan := '\033[0;96m'        # Cyan
export IWhite := '\033[0;97m'       # White

# Bold High Intensity
export BIBlack := '\033[1;90m'      # Black
export BIRed := '\033[1;91m'        # Red
export BIGreen := '\033[1;92m'      # Green
export BIYellow := '\033[1;93m'     # Yellow
export BIBlue := '\033[1;94m'       # Blue
export BIPurple := '\033[1;95m'     # Purple
export BICyan := '\033[1;96m'       # Cyan
export BIWhite := '\033[1;97m'      # White

# High Intensity backgrounds
export On_IBlack := '\033[0;100m'   # Black
export On_IRed := '\033[0;101m'     # Red
export On_IGreen := '\033[0;102m'   # Green
export On_IYellow := '\033[0;103m'  # Yellow
export On_IBlue := '\033[0;104m'    # Blue
export On_IPurple := '\033[0;105m'  # Purple
export On_ICyan := '\033[0;106m'    # Cyan
export On_IWhite := '\033[0;107m'   # White

# ##############################################################################

# Setup dotfiles.
phlos-setup-dotfiles:
    #!/usr/bin/env bash
    set -euo pipefail

    # ------------------------------------------------------------------------------

    executor="${0##*/}"
    executor_path="${BASH_SOURCE}"
    while [ -L "${executor_path}" ]; do
        executor_dir="$(cd -P "$(dirname "${executor_path}")" >/dev/null 2>&1 && pwd)"
        executor_path="$(readlink "${executor_path}")"
        [[ ${executor_path} != /* ]] && executor_path="${executor_dir}/${executor_path}"
    done
    executor_path="$(readlink -f "${executor_path}")"
    executor_dir="$(cd -P "$(dirname -- "${executor_path}")" >/dev/null 2>&1 && pwd)"

    declare -a required_cmds=( "expand_path" "print_msg" "print_divider" "deploy" "yq" )

    fail=false
    for rc in "${required_cmds[@]}"; do
        if ! command -v "${rc}" &> /dev/null ; then
            printf "[${executor}] [ERROR] Command '${rc}' unavailable!?"
            fail=true
        fi
    done
    [[ "${fail}" == true ]] && exit 1

    # ------------------------------------------------------------------------------

    print_msg -x "${executor}" -g -b "Installing dotfiles..."

    declare -a errors=()

    while IFS=$'\t' read -r dst src _; do

        if [[ ! -e "$( expand_path "${src}" )" ]]; then
            errors+=( "${src}" )
        else
            print_divider -g -f '-' -r 80
            deploy -s "${src}" -d "${dst}"
        fi
    done < <( yq e '.deployables[] | [.dst, .src] | @tsv' "${PHLOS_INDEX}" )

    if [[ ${#errors[@]} -gt 0 ]]; then
        print_divider -g -f '!' -r 80
        print_msg -x "${executor}" -g -b "${#errors[@]} errors detected!"
        print_msg -x "${executor}" -e "${errors[@]}"
    fi

# ##############################################################################

# Install only Flatpak apps.
phlos-setup-flatpaks:
    #!/usr/bin/env bash
    set -euo pipefail

    # ------------------------------------------------------------------------------

    executor="${0##*/}"
    executor_path="${BASH_SOURCE}"
    while [ -L "${executor_path}" ]; do
        executor_dir="$(cd -P "$(dirname "${executor_path}")" >/dev/null 2>&1 && pwd)"
        executor_path="$(readlink "${executor_path}")"
        [[ ${executor_path} != /* ]] && executor_path="${executor_dir}/${executor_path}"
    done
    executor_path="$(readlink -f "${executor_path}")"
    executor_dir="$(cd -P "$(dirname -- "${executor_path}")" >/dev/null 2>&1 && pwd)"

    declare -a required_cmds=( "print_divider" "print_msg" "flatpak" "yq" )

    fail=false
    for rc in "${required_cmds[@]}"; do
        if ! command -v "${rc}" &> /dev/null ; then
            printf "[${executor}] [ERROR] Command '${rc}' unavailable!?"
            fail=true
        fi
    done
    [[ "${fail}" == true ]] && exit 1

    # ------------------------------------------------------------------------------

    print_divider -g -f '=' -r 80
    mapfile -t flatpaks_user < <( yq eval '.flatpaks.user[]' "${PHLOS_INDEX}" )
    if [[ ${#flatpaks_user[@]} -gt 0 ]]; then
        print_msg -x "${executor}" -g -b "Installing user Flatpak apps..."
        declare -a errors=()
        flatpak remote-modify --user --default-branch=stable flathub
        for f_u in "${flatpaks_user[@]}"; do
            print_msg -x "${executor}" -i "Installing '${f_u}'"
            flatpak install --user --noninteractive "${f_u}" || errors+=("${pip_pkg}")
        done

        if [[ ${#errors[@]} -gt 0 ]]; then
            print_divider -g -f '!' -r 80
            print_msg -x "${executor}" -g -b "${#errors[@]} errors detected!"
            print_msg -x "${executor}" -e "${errors[@]}"
        fi
    else
        print_msg -x "${executor}" -i "Nothing to install"
    fi

    print_divider -g -f '=' -r 80
    mapfile -t flatpak_system < <( yq eval '.flatpaks.system[]' "${PHLOS_INDEX}" )
    if [[ ${#flatpak_system[@]} -gt 0 ]]; then
        print_msg -x "${executor}" -g -b "Installing system Flatpak apps..."
        declare -a errors=()
        flatpak remote-modify --system --default-branch=stable flathub
        for f_s in "${flatpak_system[@]}"; do
            print_msg -x "${executor}" -i "Installing '${f_s}'"
            flatpak install --system --noninteractive "${f_s}" || errors+=("${pip_pkg}")
        done

        if [[ ${#errors[@]} -gt 0 ]]; then
            print_divider -g -f '!' -r 80
            print_msg -x "${executor}" -g -b "${#errors[@]} errors detected!"
            print_msg -x "${executor}" -e "${errors[@]}"
        fi
    else
        print_msg -x "${executor}" -i "Nothing to install"
    fi

# ##############################################################################

# Install only Homebrew taps & formulae.
phlos-setup-homebrew:
    #!/usr/bin/env bash
    set -euo pipefail

    # ------------------------------------------------------------------------------

    executor="${0##*/}"
    executor_path="${BASH_SOURCE}"
    while [ -L "${executor_path}" ]; do
        executor_dir="$(cd -P "$(dirname "${executor_path}")" >/dev/null 2>&1 && pwd)"
        executor_path="$(readlink "${executor_path}")"
        [[ ${executor_path} != /* ]] && executor_path="${executor_dir}/${executor_path}"
    done
    executor_path="$(readlink -f "${executor_path}")"
    executor_dir="$(cd -P "$(dirname -- "${executor_path}")" >/dev/null 2>&1 && pwd)"

    declare -a required_cmds=( "print_divider" "print_msg" "brew" "yq" )

    fail=false
    for rc in "${required_cmds[@]}"; do
        if ! command -v "${rc}" &> /dev/null ; then
            printf "[${executor}] [ERROR] Command '${rc}' unavailable!?"
            fail=true
        fi
    done
    [[ "${fail}" == true ]] && exit 1

    # ------------------------------------------------------------------------------

    print_divider -g -f '=' -r 80
    mapfile -t homebrew_taps < <( yq eval '.homebrew.taps[]' "${PHLOS_INDEX}" )
    if [[ ${#homebrew_taps[@]} -gt 0 ]]; then
        print_msg -x "${executor}" -g -b "Installing Homebrew Taps..."
        declare -a errors=()
        for h_t in "${homebrew_taps[@]}"; do
            print_msg -x "${executor}" -i "Tapping '${h_t}'"
            brew tap "${h_t}" || errors+=("${pip_pkg}")
        done

        if [[ ${#errors[@]} -gt 0 ]]; then
            print_msg -x "${executor}" -e "${errors[@]}"
        fi
    else
        print_msg -x "${executor}" -i "Nothing to install"
    fi

    print_divider -g -f '=' -r 80
    mapfile -t homebrew_formulae < <( yq eval '.homebrew.formulae[]' "${PHLOS_INDEX}" )
    if [[ ${#homebrew_formulae[@]} -gt 0 ]]; then
        print_msg -x "${executor}" -g -b "Installing Homebrew Formulae..."
        declare -a errors=()
        for h_f in "${homebrew_formulae[@]}"; do
            print_msg -x "${executor}" -i "Installing '${h_f}'"
            brew install --formula "${h_f}" || errors+=("${pip_pkg}")
        done

        if [[ ${#errors[@]} -gt 0 ]]; then
            print_divider -g -f '!' -r 80
            print_msg -x "${executor}" -g -b "${#errors[@]} errors detected!"
            print_msg -x "${executor}" -e "${errors[@]}"
        fi
    else
        print_msg -x "${executor}" -i "Nothing to install"
    fi

# ##############################################################################

# Setup only VSCode extensions.
phlos-setup-vscode-extensions:
    #!/usr/bin/env bash
    set -euo pipefail

    # ------------------------------------------------------------------------------

    executor="${0##*/}"
    executor_path="${BASH_SOURCE}"
    while [ -L "${executor_path}" ]; do
        executor_dir="$(cd -P "$(dirname "${executor_path}")" >/dev/null 2>&1 && pwd)"
        executor_path="$(readlink "${executor_path}")"
        [[ ${executor_path} != /* ]] && executor_path="${executor_dir}/${executor_path}"
    done
    executor_path="$(readlink -f "${executor_path}")"
    executor_dir="$(cd -P "$(dirname -- "${executor_path}")" >/dev/null 2>&1 && pwd)"

    declare -a required_cmds=( "print_divider" "print_msg" "code" "yq" )

    fail=false
    for rc in "${required_cmds[@]}"; do
        if ! command -v "${rc}" &> /dev/null ; then
            printf "[${executor}] [ERROR] Command '${rc}' unavailable!?"
            fail=true
        fi
    done
    [[ "${fail}" == true ]] && exit 1

    # ------------------------------------------------------------------------------

    print_divider -g -f '=' -r 80
    mapfile -t vscode_extensions < <( yq eval '.vscode_extensions[]' "${PHLOS_INDEX}" )
    if [[ ${#vscode_extensions[@]} -gt 0 ]]; then
        print_msg -x "${executor}" -g -b "Installing VSCode Extensions..."
        declare -a errors=()
        for v_e in "${vscode_extensions[@]}"; do
            print_msg -x "${executor}" -i "Installing '${v_e}'"
            code --install-extension "${v_e}" || errors+=("${pip_pkg}")
        done

        if [[ ${#errors[@]} -gt 0 ]]; then
            print_divider -g -f '!' -r 80
            print_msg -x "${executor}" -g -b "${#errors[@]} errors detected!"
            print_msg -x "${executor}" -e "${errors[@]}"
        fi
    else
        print_msg -x "${executor}" -i "Nothing to install"
    fi

# ##############################################################################

# Setup only Cargo pkgs.
phlos-setup-cargo-pkgs:
    #!/usr/bin/env bash
    set -euo pipefail

    # ------------------------------------------------------------------------------

    executor="${0##*/}"
    executor_path="${BASH_SOURCE}"
    while [ -L "${executor_path}" ]; do
        executor_dir="$(cd -P "$(dirname "${executor_path}")" >/dev/null 2>&1 && pwd)"
        executor_path="$(readlink "${executor_path}")"
        [[ ${executor_path} != /* ]] && executor_path="${executor_dir}/${executor_path}"
    done
    executor_path="$(readlink -f "${executor_path}")"
    executor_dir="$(cd -P "$(dirname -- "${executor_path}")" >/dev/null 2>&1 && pwd)"

    declare -a required_cmds=( "print_divider" "print_msg" "cargo" "yq" )

    fail=false
    for rc in "${required_cmds[@]}"; do
        if ! command -v "${rc}" &> /dev/null ; then
            printf "[${executor}] [ERROR] Command '${rc}' unavailable!?"
            fail=true
        fi
    done
    [[ "${fail}" == true ]] && exit 1

    # ------------------------------------------------------------------------------

    print_divider -g -f '=' -r 80
    mapfile -t cargo_pkgs < <( yq eval '.cargo[]' "${PHLOS_INDEX}" )
    if [[ ${#cargo_pkgs[@]} -gt 0 ]]; then
        print_msg -x "${executor}" -g -b "Installing cargo packages..."
        declare -a errors=()
        for cargo_pkg in "${cargo_pkgs[@]}"; do
            print_msg -x "${executor}" -g -i "Installing '${cargo_pkg}'"
            if [[ $cargo_pkg == "--git"* ]]; then
                cargo install ${cargo_pkg} || errors+=("${cargo_pkg}")
            else
                cargo install --locked "${cargo_pkg}" || errors+=("${cargo_pkg}")
            fi
        done

        if [[ ${#errors[@]} -gt 0 ]]; then
            print_divider -g -f '!' -r 80
            print_msg -x "${executor}" -g -b "${#errors[@]} errors detected!"
            print_msg -x "${executor}" -e "${errors[@]}"
        fi
    else
        print_msg -x "${executor}" -i "Nothing to install"
    fi

# ##############################################################################

# Setup only Python pkgs.
phlos-setup-pip-pkgs:
    #!/usr/bin/env bash
    set -euo pipefail

    # ------------------------------------------------------------------------------

    executor="${0##*/}"
    executor_path="${BASH_SOURCE}"
    while [ -L "${executor_path}" ]; do
        executor_dir="$(cd -P "$(dirname "${executor_path}")" >/dev/null 2>&1 && pwd)"
        executor_path="$(readlink "${executor_path}")"
        [[ ${executor_path} != /* ]] && executor_path="${executor_dir}/${executor_path}"
    done
    executor_path="$(readlink -f "${executor_path}")"
    executor_dir="$(cd -P "$(dirname -- "${executor_path}")" >/dev/null 2>&1 && pwd)"

    declare -a required_cmds=( "print_divider" "print_msg" "pip" "yq" )

    fail=false
    for rc in "${required_cmds[@]}"; do
        if ! command -v "${rc}" &> /dev/null ; then
            printf "[${executor}] [ERROR] Command '${rc}' unavailable!?"
            fail=true
        fi
    done
    [[ "${fail}" == true ]] && exit 1

    # ------------------------------------------------------------------------------

    print_divider -g -f '=' -r 80
    mapfile -t pip_pkgs < <( yq eval '.pip[]' "${PHLOS_INDEX}" )
    if [[ ${#pip_pkgs[@]} -gt 0 ]]; then
        print_msg -x "${executor}" -g -b "Installing Python packages..."
        declare -a errors=()
        for pip_pkg in "${pip_pkgs[@]}"; do
            print_msg -x "${executor}" -i "Installing '${pip_pkg}'"
            pip install -U "${pip_pkg}" || errors+=("${pip_pkg}")
        done

        if [[ ${#errors[@]} -gt 0 ]]; then
            print_divider -g -f '!' -r 80
            print_msg -x "${executor}" -g -b "${#errors[@]} errors detected!"
            print_msg -x "${executor}" -e "${errors[@]}"
        fi
    else
        print_msg -x "${executor}" -i "Nothing to install"
    fi

# ##############################################################################

# Clean up old packages and Docker/Podman images and volumes.
phlos-clean:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Cleaning up system..."
    flatpak uninstall --unused
    rpm-ostree cleanup -bm
    docker system prune -af
    sudo docker system prune -af
    podman system prune -af
    sudo podman system prune -af
    # nix-collect-garbage -d
    # sudo -i nix-collect-garbage -d

# ##############################################################################

# Shortcut to add SMB/CIFS shares.
phlos-add-rfs:
    /usr/bin/rfs

# ##############################################################################

# Shortcut to remove SMB/CIFS shares.
phlos-remove-rfs:
    /usr/bin/rfs -r

# ##############################################################################

# Add vboxusers group to system if not there already and current user to it.
phlos-vboxusers-add-current-user:
    #!/usr/bin/env bash
    set -euo pipefail

    sudo groupadd -f vboxusers
    sudo usermod -aG vboxusers $USER

    echo "Reboot system for VirtualBox to pick up the group."

# ##############################################################################

# Add syncthing for current user via a quadlet.
phlos-setup-podman-syncthing:
    #!/usr/bin/env bash
    set -euo pipefail

    # ------------------------------------------------------------------------------

    executor="${0##*/}"
    executor_path="${BASH_SOURCE}"
    while [ -L "${executor_path}" ]; do
        executor_dir="$(cd -P "$(dirname "${executor_path}")" >/dev/null 2>&1 && pwd)"
        executor_path="$(readlink "${executor_path}")"
        [[ ${executor_path} != /* ]] && executor_path="${executor_dir}/${executor_path}"
    done
    executor_path="$(readlink -f "${executor_path}")"
    executor_dir="$(cd -P "$(dirname -- "${executor_path}")" >/dev/null 2>&1 && pwd)"

    declare -a required_cmds=( "print_msg" "podman" )

    fail=false
    for rc in "${required_cmds[@]}"; do
        if ! command -v "${rc}" &> /dev/null ; then
            printf "[${executor}] [ERROR] Command '${rc}' unavailable!?"
            fail=true
        fi
    done
    [[ "${fail}" == true ]] && exit 1

    # ------------------------------------------------------------------------------

    read -e -p "Enter config location:" -i "$HOME/.config/syncthing" config_location
    read -e -p "Enter shares location:" -i "$HOME/Syncthing" shares_location

    # $( whoami ) or $( id -un ) for current user
    local_user_uid=$( id -u ) # or $( id -u <username> ) for any other user than current
    local_user_gid=$( id -g ) # or $( id -g <username> ) for any other user than current


    QUADLET="
    [Unit]
    Description=Podman syncthing.service
    Wants=network-online.target
    After=network-online.target

    [Service]
    Restart=on-failure
    TimeoutStartSec=900

    [Container]
    Image=docker.io/syncthing/syncthing:latest
    AutoUpdate=registry
    Network=host
    UserNS=keep-id:uid=${local_user_uid},gid=${local_user_gid}
    Volume=${config_location}:/var/syncthing/config:Z

    # Folders to share
    Volume=${shares_location}:/var/syncthing/shares:Z

    [Install]
    WantedBy=default.target
    "

    print_msg -x "${executor}" -i "Creating directories..."
    # printf "[${executor}] ${BBlue}INFO${Color_Off} - Creating directories...\n"
    mkdir -pv "${config_location}"
    mkdir -pv "${shares_location}"

    print_msg -x "${executor}" -i "Creating quadlet..."
    # printf "[${executor}] ${BBlue}INFO${Color_Off} - Creating quadlet...\n"
    echo "${QUADLET}" | tee ~/.config/containers/systemd/syncthing.container > /dev/null

    print_msg -x "${executor}" -i "Enabling & starting quadlet..."
    # printf "[${executor}] ${BBlue}INFO${Color_Off} - Enabling & starting quadlet...\n"
    systemctl --user daemon-reload
    systemctl --user start syncthing

    print_msg -x "${executor}" -i "Enabling automatic updates & start on boot..."
    # printf "[${executor}] ${BBlue}INFO${Color_Off} - Enabling automatic updates & start on boot...\n"

    # 'AutoUpdate=registry' in the systemd definition allows the container to be auto-updated,
    # manually by calling 'podman auto-update'
    # or automatically by enabling the relative systemd service:
    systemctl enable --user --now podman-auto-update.timer

    # Start user services even when not logged in
    loginctl enable-linger $USER

# ##############################################################################

# Setup teamviewer background service & launch teamviewer
phlos-setup-teamviewer:
    sudo teamviewer daemon enable
    sudo systemctl enable --now teamviewerd.service
    teamviewer
