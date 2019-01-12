brew update
brew upgrade

FORMULAS=(
   git
   hub
   vim
   tmux
   python
   go
   carthage
)

brew install ${FORMULAS[@]}

CASKS=(
   pycharm-ce
   miniconda
   1password
   spectacle
   google-chrome
   iterm2
   dropbox
   atom
   docker
)

brew cask install ${CASKS[@]}
