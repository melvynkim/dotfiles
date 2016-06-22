#!/bin/sh
export DOTFILES_HOME=""


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
                wget --quiet --no-check-certificate https://raw.github.com/melvynkim/dotfiles/master/INSTALL.sh -O - | sh
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
    hash git >/dev/null 2>&1 && /usr/bin/env git clone --quiet --recursive "https://github.com/melvynkim/dotfiles" ${DOTFILES_HOME} || 
    die "git is not installed."    
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
}

install_neobundle_vim() {
    # install NeoBundle
    # https://github.com/Shougo/neobundle.vim
    bash <(curl -s https://raw.githubusercontent.com/Shougo/neobundle.vim/master/bin/install.sh)
}

install_zsh_bin() {
# BIN_PATH includes:
# - directory
# - files without extension
#
# BIN_PATH doesn't include:
# - hidden files with prefix '.'
  BIN_PATH="${DOTFILES_HOME}/zshrc.git/bin/**/*"
  for bin_file in $BIN_PATH; do
	ln -s ${bin_file} /usr/local/bin/
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


DOTFILES_HOME="${HOME}/.dotfiles"
check_requirements
clone_dotfiles
add_symbolic_links
install_neobundle_vim
