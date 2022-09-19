#!/usr/bin/env bash

git clone --bare https://github.com/XcaliBuR75/dotfiles.git $HOME/.cfg

echo ".cfg" >> $HOME/.gitignore

function config {
    /usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME $@
}

config checkout
while [ $? -ge 0 ]
do
    config checkout &> /dev/null
    if [ $? -eq 0 ]
    then
        echo "Checked out config."
        config config status.showUntrackedFiles no
        break
    fi
    echo "Removing up pre-existing dot files."
    config checkout 2>&1 | grep -E "\s+\." | awk {'print $1'} | xargs -I{} rm -rvf {}
    config checkout &> /dev/null
done

#config remote add origin git@github.com:XcaliBuR75/dotfiles.git
