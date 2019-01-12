echo "Using ZSH"
chsh -s /bin/zsh

echo "Installing Homebrew"
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

echo "Setting up Homebrew"
./Scripts/homebrew.sh

echo "Creating Go Workspace"
mkdir -p $HOME/Code/go/src && mkdir $HOME/Code/go/bin
