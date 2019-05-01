export DEFAULT_USER=""

export EDITOR="vim"

export GOPATH=$HOME/Code/go
export PATH="$GOPATH:/usr/local/miniconda3/bin:$PATH"


CASE_INSENSITIVE="true"
HYPHEN_INSENSITIVE="true"

. /usr/local/miniconda3/etc/profile.d/conda.sh

for file (~/.zsh/*.zsh) source $file
