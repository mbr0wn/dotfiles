#!/bin/bash

function check_and_backup {
	if [ -e ~/.$1 ]; then
		echo "Moving ~/.$1 to ~/$1.ORIG"
		mv ~/.$1 ~/$1.ORIG
	fi
}


# Check we're running from the right dir
if [ ! -x ./init_home.sh ]; then
	echo "Cannot find init_home.sh -- are you running from the repo dir?"
	exit 1
fi

CWD=`pwd`

## Symlink dotfiles
echo "== Symlinking dotfiles to home dir..."
HOME_SYMLINK_FILES=`(cd home_symlink; ls)`
for i in ${HOME_SYMLINK_FILES}
do
	check_and_backup $i
	echo "Linking $i to ~/.$i ..."
	ln -s ${CWD}/home_symlink/$i ~/.$i
done

## Copy dotfiles
echo "== Copying other dotfiles to home dir..."
HOME_COPY_FILES=`(cd home_copy; ls)`
for i in ${HOME_COPY_FILES}
do
	check_and_backup $i
	echo "Copying $i to ~/.$i ..."
	cp ${CWD}/home_copy/$i ~/.$i
done

## Clone important repos
cd ~
echo "== Cloning vim config..."
check_and_backup .vim
check_and_backup .vimrc
git clone --recursive git@github.com:mbr0wn/vimrc.git .vim
ln -s .vim/vimrc .vimrc
(cd ~/.vim/bundle/fzf && ./install --all)

echo "== Cloning zsh config..."
check_and_backup .oh-my-zsh
git clone --recursive git@github.com:mbr0wn/oh-my-zsh.git .oh-my-zsh
if [ -x /bin/zsh ]; then
	echo "Selecting zsh as default shell (will ask for password)..."
	chsh -s /bin/zsh
else if [ -x /usr/bin/zsh ]; then
	echo "Selecting zsh as default shell (will ask for password)..."
	chsh -s /usr/bin/zsh
else
	echo "zsh not found/installed. Not running chsh."
fi

echo "== Cloning tmux plugins..."
check_and_backup .tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
echo "To install tmux plugins, hit prefix + I in a tmux session."
