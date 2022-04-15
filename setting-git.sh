#!/bin/env bash

git config --global user.name "XcaLiBuR75"
git config --global user.email "ghernan75@gmail.com"
ssh-keygen -t rsa -b 2048 -C "ghernan75@gmail.com"

printf "\e[1;32mDone! Copy your ~/.ssh/id_rsa.pub key in your github settings account, in the SSH and GPG keys section and run the command ssh -T git@github.com to check is the verification is ok.\e[0m"
