#!/bin/sh

export DOTFILES_HOME="${HOME}/.dotfiles"

check_requirements() {
    # Die if dotfiles directory exists
    if [ -d "${DOTFILES_HOME}" ]; then
        echo "dotfiles exist in ${DOTFILES_HOME}"
        read -p "Do you wish to re-install dotfiles? [Y]es/[N]o: " prompt_yes_or_no
        case $prompt_yes_or_no in 
            [Yy]*) 
                echo "Removing existing dotfiles directory.."
                rm -rf "${DOTFILES_HOME}"
                echo "Cloning dotfiles.."
                clone_dotfiles
                sh "${DOTFILES_HOME}/INSTALL.sh"
                ;;
            [Nn]*)
                die_on_warning "dotfiles not installed."
                ;;
            *)
                die "Enter 'Yes' or 'No'"
                ;;
        esac
    fi
}

clone_dotfiles() {
    echo "Cloning dotfiles to ${DOTFILES_HOME}.."
    if hash git >/dev/null 2>&1; then
        /usr/bin/env git clone --quiet --recursive git@github.com:melvynkim/dotfiles.git ${DOTFILES_HOME}
    else
        die "git is not installed."
    fi    
}

add_symbolic_links() {
    # zsh
    ln -s "${DOTFILES_HOME}/zshrc.git" "${HOME}/.zsh"
    ln -s "${DOTFILES_HOME}/zshrc.git/.zshrc" "${HOME}/.zshrc"

    # vim
    ln -s "${DOTFILES_HOME}/vimrc.git" "${HOME}/.vim"
    ln -s "${DOTFILES_HOME}/vimrc.git/.vimrc" "${HOME}/.vimrc"

    # git
    ln -s "${DOTFILES_HOME}/git/.gitignore_global" "${HOME}/.gitignore_global"
    ln -s "${DOTFILES_HOME}/git/.gitconfig" "${HOME}/.gitconfig"
    ln -s "${DOTFILES_HOME}/git/.gitattributes" "${HOME}/.gitattributes"

    # spaceship-prompt for zsh
    ln -s "${DOTFILES_HOME}/zshrc.git/spaceship-prompt/spaceship.zsh-theme" "${DOTFILES_HOME}/zshrc.git/ohmyzsh/themes/spaceship.zsh-theme"
}

install_neobundle_vim() {
    # install NeoBundle for Vim
    echo "Installing NeoBundle for Vim..."
    if hash curl >/dev/null 2>&1; then
        curl -s https://raw.githubusercontent.com/Shougo/neobundle.vim/master/bin/install.sh | sh
    else
        die "curl is not installed."
    fi
}

install_zsh_bin() {
    echo "Installing zsh bin..."
    BIN_PATH="${DOTFILES_HOME}/zshrc.git/bin/**/*"
    for bin_file in $BIN_PATH; do
        if [ -f ${bin_file} ] && [ ! -d ${bin_file} ]; then
            ln -s ${bin_file} /usr/local/bin/
        fi
    done
}

die_on_warning() {
    echo "WARNING: $1"
    exit 2
}

die() {
    echo "ERROR: $1"
    echo "Report issues at http://github.com/melvynkim/dotfiles"
    exit 1
}

check_requirements
clone_dotfiles
add_symbolic_links
install_neobundle_vim
install_zsh_bin
