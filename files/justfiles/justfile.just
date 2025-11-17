# Install all phlos curated apps
phlos-setup-all: phlos-setup-dotfiles phlos-setup-homebrew phlos-setup-vscode-extensions phlos-setup-cargo-pkgs phlos-setup-pip-pkgs

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

# ------------------------------------------------------------------------------

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

    declare -a required_cmds=( "cp" "mkdir" "rm" )

    fail=false
    for rc in "${required_cmds[@]}"; do
        if ! command -v "${rc}" &> /dev/null ; then
            printf "[${executor}] ${BRed}ERROR${Color_Off} - '${rc}' command not available!"
            fail=true
        fi
    done
    [[ "${fail}" == true ]] && exit 1

    # ------------------------------------------------------------------------------

    function print_divider {

        function print_usage {
            local usage="
            Usage:
            print_divider [OPTIONS]

            Options:
            -f <character/string> filler character or string, default is '-'
            -r <integer> repetitions of filler, default is current number of columns of terminal
            "
            printf '%s\n' "${usage}"
        }

        printf '\n'

        local filler="-"
        local repetitions="$(tput cols)"

        args=$(getopt -a -o hf:r: --long help,filler:,repetitions: -- "$@")
        if [[ $? -gt 0 ]]; then
            print_usage && exit 1
        fi

        eval set -- ${args}
        while :
        do
            case $1 in

                -h | --help         )   print_usage && exit 0
                                        shift ;;
                -f | --filler       )   filler="${2}"
                                        shift 2 ;;
                -r | --repetitions  )   repetitions="${2}"
                                        shift 2 ;;
                # -- means the end of the arguments; drop this, and break out of the while loop
                --  )   shift; break ;;
                *   )   printf "[print_divider] ERROR - Unsupported option: %s\n" "${1}"
                        print_usage
                        exit 1
                        ;;
            esac
        done


        # local filler=${1:-"-"}
        # local length=${2:-"$(tput cols)"}
        printf "%${repetitions}s" | sed "s/ /${filler}/g"
        printf '\n\n'
    }

    # ------------------------------------------------------------------------------

    function mkdcp {
        local src="$1"
        local dst="$2"

        print_divider -f '-' -r 80

        # remove old if there
        [[ -e "${dst}" ]] && rm -rfv "${dst}"

        # ensure parent exists regardless
        local dst_parent="$(dirname -- "$dst")"
        [[ ! -d "${dst_parent}" ]] && mkdir -pv -- "${dst_parent}"

        # add new
        cp -auv "${src}" "${dst}"
    }

    # ------------------------------------------------------------------------------

    echo "Installing dotfiles..."

    declare -a errors=()

    while IFS=$'\t' read -r dst src _; do
        if [[ ! -e "${src}" ]]; then
            errors+=( "${src}" )
        else
            mkdcp "${src}" "${dst}"
        fi
    done < <( yq e '.deployables[] | [.dst, .src] | @tsv' "${PHLOS_INDEX}" )

    if [[ ${#errors[@]} -gt 0 ]]; then
        print_divider -f '=' -r 80
        for e in "${errors[@]}"; do
            printf "[${executor}] ${BRed}ERROR${Color_Off} - Deployable '%s' not present!\n" "${e}"
        done
    fi

# Install only Homebrew taps & formulae.
phlos-setup-homebrew:
    #!/usr/bin/env bash
    set -euo pipefail

    if command -v brew &> /dev/null; then

        echo "Installing Homebrew Taps & Formulae..."

        mapfile -t homebrew_taps < <( yq eval '.homebrew.taps[]' "${PHLOS_INDEX}" )
        for h_t in "${homebrew_taps[@]}"; do
            brew tap "${h_t}"
        done

        mapfile -t homebrew_formulae < <( yq eval '.homebrew.formulae[]' "${PHLOS_INDEX}" )
        for h_f in "${homebrew_formulae[@]}"; do
            brew install --formula "${h_f}"
        done

    else
        printf "[${executor}] ${BRed}ERROR${Color_Off} - Unknown command 'brew'\n" "${e}"
    fi

# Setup only VSCode extensions.
phlos-setup-vscode-extensions:
    #!/usr/bin/env bash
    set -euo pipefail

    if command -v code &> /dev/null; then

        echo "Installing VSCode Extensions..."
        mapfile -t vscode_extensions < <( yq eval '.vscode_extensions[]' "${PHLOS_INDEX}" )
        for v_e in "${vscode_extensions[@]}"; do
            code --install-extension "${v_e}"
        done

    else
        printf "[${executor}] ${BRed}ERROR${Color_Off} - Unknown command 'code'\n" "${e}"
    fi

# Setup only Cargo pkgs.
phlos-setup-cargo-pkgs:
    #!/usr/bin/env bash
    set -euo pipefail

    if command -v cargo &> /dev/null; then

        echo "Installing cargo packages..."
        mapfile -t cargo_pkgs < <( yq eval '.cargo[]' "${PHLOS_INDEX}" )
        for cargo_pkg in "${cargo_pkgs[@]}"; do
            cargo install "${cargo_pkg}" --locked
        done

    else
        printf "[${executor}] ${BRed}ERROR${Color_Off} - Unknown command 'cargo'\n" "${e}"
    fi

# Setup only Python pkgs.
phlos-setup-pip-pkgs:
    #!/usr/bin/env bash
    set -euo pipefail

    if command -v pip &> /dev/null; then

        echo "Installing Python packages..."
        mapfile -t pip_pkgs < <( yq eval '.pip[]' "${PHLOS_INDEX}" )
        for pip_pkg in "${pip_pkgs[@]}"; do
            pip install -U "${pip_pkg}"
        done

    else
        printf "[${executor}] ${BRed}ERROR${Color_Off} - Unknown command 'pip'\n" "${e}"
    fi

# Clean up old packages and Docker/Podman images and volumes.
phlos-clean:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Cleaning up system..."
    docker system prune -af
    podman system prune -af
    flatpak uninstall --unused
    rpm-ostree cleanup -bm
    sudo docker system prune -af
    sudo podman system prune -af
    # nix-collect-garbage -d
    # sudo -i nix-collect-garbage -d

# Shortcut to add SMB/CIFS shares.
phlos-add-rfs:
    /usr/bin/rfs

# Shortcut to remove SMB/CIFS shares.
phlos-remove-rfs:
    /usr/bin/rfs -r

# Add vboxusers group to system if not there already and current user to it.
phlos-vboxusers-add-current-user:
    #!/usr/bin/env bash
    set -euo pipefail

    sudo groupadd -f vboxusers
    sudo usermod -aG vboxusers $USER

    echo "Reboot system for VirtualBox to pick up the group."
