#!/bin/bash

#
# history-recall install script
#
# To install:
#
# $ source history-install.sh
#

HISTORYRC="$HOME/.historyrc"

# Get the path to the directory this script was ran from
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Presume that we will install to .bash_profile. If it looks like
# .bash_profile is including .bashrc, then we will install to .bashrc.
INSTALL_TO=".bash_profile"
if [ ! -f "$INSTALL_TO" ] || grep -q bashrc "$HOME/$INSTALL_TO" ; then
  INSTALL_TO=".bashrc"
fi

# Parse options
while [ $# -gt 0 ] ; do
  option=$1
  shift

  case "$option" in
    --bashrc )
      INSTALL_TO=".bashrc"
      ;;

    --bash_profile )
      INSTALL_TO=".bash_profile"
      ;;

    --profile )
      INSTALL_TO=".profile"
      ;;
  esac
done

# Do not overwrite existing installations
if [ -f "$HISTORYRC" ] ; then
  echo "history-recall is already installed (~/.historyrc file exists)"
  return
fi

# Write our .historyrc file
cat <<- __EOF__ > $HISTORYRC
	#!/bin/bash

	#
	# Configuration file for history-recall script
	# See: https://github.com/g1a/history-recall
	#

	# Source history-recall script.
	source "$SCRIPT_DIR/history-recall.sh"
__EOF__

echo 'Created new ~/.historyrc configuration file.'

# If it looks like the fdrc file is already being sourced, then exit.
if grep -q historyrc "$HOME/$INSTALL_TO" ; then
  echo "~/.historyrc configuration file is already sourced from ~/$INSTALL_TO)"
  return
fi

cat <<- __EOF__ >> "$HOME/$INSTALL_TO"

	# Source the history-recall configuration file.
	# See: https://github.com/g1a/history-recall
	source "$HOME/.historyrc"
__EOF__

echo "Installed 'source ~/.historyrc' in ~/$INSTALL_TO"

# Source history-recall so that it is available in this shell.
source ~/.historyrc
