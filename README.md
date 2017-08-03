dotfiles
========

Installation
--------
Clone repository, then from ~, run
```zsh
for x in `ls .dotfiles -A`; do rm $x; ln -s .dotfiles/$x $x; done
```
to symlink all the files into place (may print error messages if you don't already have the files in ~).

If you want configurations to be specific to computer, consider using `uname -n` to distinguish.
