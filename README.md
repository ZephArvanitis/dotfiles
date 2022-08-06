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


Side note: setting up a new system
------
You'll want:

* karabiner-elements
* hammerspoon
* 1password
* iTerm2 (will require xcode developer tools)
* this repo (if you want to have the remote attached properly, will require either old ssh keys or that you upload a new one to GitHub)
* chrome + firefox
* homebrew

The rest you can mostly figure out on the fly.
