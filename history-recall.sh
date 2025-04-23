# History configuration
# c.f. http://www.catonmat.net/blog/the-definitive-guide-to-bash-command-line-history/
shopt -s histappend
shopt -s histreedit

# Set the title of a Terminal window
function history_settitle() {
  if [ -n "$DISPLAY" ] ; then
    if [ -n "$STY" ] ; then         # We are in a screen session
      echo "Setting screen titles to $@"
      printf "\033k%s\033\\" "$@"
      screen -X eval "at \\# title $@" "shelltitle $@"
    else
      printf "\033]0;%s\007" "$@"
    fi
  fi
}

# We will store all of our history files in ~/.history, and we
# will record information about our active terminals in ~/.terminal.
mkdir -p $HOME/.history
mkdir -p $HOME/.terminal

# HIST_TTY records the tty that this history session is associated with,
# and HIST_IDENTIFIER identifies the host and user this history belongs to.
# Note that the user is only included if it is not already implied from $HOME
# (e.g. after `sudo bash` $HOME will be /home/origuser and $USER will be root,
# so the history file will be stored in /home/origuser/.history/bash_HOST_root_dev_pts_N)
export HIST_TTY=$(tty | tr / _)
HIST_IDENTIFIER=$(hostname -s)
# If this terminal session was initiated via an ssh session, then we will use
# the first word from '$SSH_CLIENT' instead of hostname -s in the history filename.
if [ -n "$SSH_CLIENT" ] ; then
  HIST_IDENTIFIER="${SSH_CLIENT%% *}"
fi
if [ "$(basename $HOME)" != "$USER" ]
then
  HIST_IDENTIFIER="${HIST_IDENTIFIER}_$USER"
fi
export HIST_IDENTIFIER
# If $HISTFILE is in the home directory, then make a new history file unique to this tty
if [ $(dirname "$HISTFILE") == "$HOME" ]
then
  export HISTFILE="$HOME/.history/bash_${HIST_IDENTIFIER}${HIST_TTY}"
  # If we are logged in as some other user (e.g. root), try to make
  # our histfile accessible to the user that owns $HOME.
  if [ "$(basename $HOME)" != "$USER" ]
  then
    touch "$HISTFILE"
    chgrp $(basename $HOME) "$HISTFILE"
    chmod g+rw "$HISTFILE"
  fi
  if [ -f "$HISTFILE" ]
  then
    history -r
  fi
fi

#trap "history_settitle $HIST_TTY; exit" 0
export HISTORY_TITLE="${HIST_IDENTIFIER}${HIST_TTY}"
#history_settitle "$HISTORY_TITLE"
if [ -n "$DISPLAY" ] && [ -n "$(which wmctrl 2>/dev/null)" ] ; then
  # It takes a bit before wmctrl will see the result of the settitle;
  # once we have the window title, write the window id into the
  # corresponding .terminal file.
  sleep 0.1
  w=$(wmctrl -l | grep "${HIST_IDENTIFIER}${HIST_TTY}" | sed -e 's/ .*//')
  echo $w > "$HOME/.terminal/${HIST_IDENTIFIER}${HIST_TTY}"
fi

# Ignore a couple common commands, and any command that begins with space
export HISTIGNORE="&:[ ]*:ls:hist.*:exit"

# if $PROMPT_COMMAND does not contain 'history', then add our
# time-formatted history -a customization to it
if [ "$PROMPT_COMMAND" == "${PROMPT_COMMAND/history/}" ]
then
  if [ -n "$PROMPT_COMMAND" ]
  then
    if [ "${PROMPT_COMMAND: -1}" == ';' ] || [ "${PROMPT_COMMAND: -2}" == '; ' ] ; then
      export PROMPT_COMMAND="${PROMPT_COMMAND} "
    else
      export PROMPT_COMMAND="${PROMPT_COMMAND}; "
    fi
  fi
  export PROMPT_COMMAND="$PROMPT_COMMAND"'HISTTIMEFORMAT="[%m/%d@%H:%M:%S] " history -a;'
fi

# Print command history including execution times, for this run of 'history' only
alias h='HISTTIMEFORMAT="$(tput setaf 2)%m-%d %H:%M$(tput sgr0) " history'
alias histt=h

# Make a note in command history
# Usage:
#   $ note COMMAND // comment
#   command output
#   $ recall comment
#   command output
# The 'note' command embeds the output of the supplied command
# into the bash history file. This command output may be printed
# out again verbatim later with the 'recall' command.
function note {
  t=$(date "+%s")
  p=();
  c=false
  for a in "$@";
  do
    if $c || [ "x$a" == "x//" ]
    then
      c=true
    else
      p[${#p[@]}]="$a";
    fi
  done
  echo "#$t >>" $* >> "$HISTFILE"
  COLUMNS=$((COLUMNS-5-${#t})) "${p[@]}" | sed -e "s/^/#$t :: /" | tee -a "$HISTFILE" | sed -e 's/^#[^:]*:: //'
}

# Begin a new task: switch to a new command history
# file, and make a note in it.  We'll copy existing
# history over, just in case we did some stuff relevant
# to the current task before declaring it.
# Usage:
#   $ start-task Install whizzy-fu pro
#   begin task: Install whizzy-fu pro
#   $ sudu apt-get install whizzyfu libwhizzyfu-dev
#   $ ... lots of other stuff
#   $ finish-task
#   finished task: Install whizzy-fu pro
#
#   ... a few days later, in a different terminal:
#   $ recall whizzy
#   # Fri Oct 12 11:06:43 PDT 2012
#   recalled task: Install whizzy-fu pro
#   $ ^Rapt-get
#   (reverse-i-search)`sudo apt-get': sudo apt-get install whizzyfu libwhizzyfu-dev
function start-task {
  t=$(date "+%s")
  task=$(echo $* | tr A-Z a-z | sed -e 's/ /_/g' -e 's/[^a-z0-9_]//g')
  taskfile="$HOME/.history/task_${HIST_IDENTIFIER}_$task"
  histpush "$taskfile"
  note echo "begin task: $*" // $HISTFILE
  echo "HISTFILE is now $HISTFILE"
}

# Complete a task and go back to previous HISTFILE.  Optional.
function finish-task {
  l=$(grep "^#[0-9]\+ :: begin task:" "$HISTFILE" | tail -n 1)
  if [ -z "$l" ]
  then
    echo "finished: no task in progress"
  else
    m=$(echo $l | sed -e 's/^#[^>]*:: begin/finished/')
    echo $m
    histpop
  fi
}

# Show all active tasks nested in this terminal
function tasklist {
  # $HISTFILES contains the stack of active tasks for this terminal
  for f in "$HISTFILE" $(echo $HISTFILES | tr : ' ') ; do
    if [ ${f:0:1} != '/' ]
    then
      f="$HOME/.history/$f"
    fi
    l=$(grep -Hm 1 "^#[0-9]\+ >>.*$*" $f)
    if [ -n "$l" ]
    then
      t=$(echo $l | sed -e 's/^[^#]*#\([0-9]\+\).*/\1/')
      c=$(echo $l | sed -e 's/^[^>]*>> *//')
      d=$(date --date="@$t")
      n=${c#*:}
      sn=${n%% //*}
      echo "$(basename $f):$sn // $d"
    fi
  done
}

# Show all tasks that are not finished
function tasks {
  for h in $(ls $HOME/.history/task_*) ; do
    if [ -z "$(grep "^finished$" $h)" ] ; then
      l=$(head -n 1 $h)
      t=$(echo $l | sed -e 's/^[^#]*#\([0-9]\+\).*/\1/')
      c=$(echo $l | sed -e 's/^[^>]*>> *//')
      d=$(date --date="@$t")
      n=${c#*:}
      sn=${n%% //*}
      echo "[$d]\$ $c"
    fi
  done
}

# Show all notes entered in the active terminal window
function notes {
  OLDIFS="$IFS"
  IFS=$'\n'
  for l in $(grep -H "^#[0-9]\+ >>.*$*" "$HISTFILE") ; do
    t=$(echo $l | sed -e 's/^[^#]*#\([0-9]\+\).*/\1/')
    c=$(echo $l | sed -e 's/^[^>]*>> *//')
    d=$(date --date="@$t")
    n=${c#*:}
    sn=${n%% //*}
    echo "[$d]\$ $c"
  done
  IFS="$OLDIFS"
}

# grep all history files for a command pattern
function hgrep {
  (
    cd $HOME/.history
    grep $* $(ls -rt | grep -v "$(basename "$HISTFILE")") "$(basename "$HISTFILE")"  | grep -v '^[^:]*:#'
  )
}

# Focus on the terminal specified by the user.
function terminal() {
  p="${HIST_IDENTIFIER}"'_.*_'"$1"
  t=$(ls "$HOME/.terminal" | grep "$p")
  if [ -f "$HOME/.terminal/$t" ] ; then
    w=$(cat "$HOME/.terminal/$t")
  else
    w=$(wmctrl -l | grep "$p"'$' | sed -e 's/ .*//')
  fi
  if [ -n "$w" ] ; then
    wmctrl -i -a "$w"
  else
    echo "Cound not find terminal $1; perhaps it is no longer open."
  fi
}

# Show the output of a command passed to 'note', or switch back to a
# task (and corresponding history file) from the past.
function recall {
  l=$(cd  $HOME/.history && grep "^#[0-9]\+ >>.*$*" $(ls -t) "$HISTFILE" | tail -n 1)
  if [ -z "$l" ]
  then
    echo "recall: cannot find $*: No such note or task"
  else
    f=$(echo $l | sed -e 's/^\([^:]*\):#.*/\1/')
    if [ ${f:0:1} != '/' ]
    then
      f="$HOME/.history/$f"
    fi
    t=$(echo $l | sed -e 's/^[^#]*#\([0-9]\+\).*/\1/')
    c=$(echo $l | sed -e 's/^[^>]*>> *//')
    d=$(date --date="@$t")
    if [ "${c%%:*}" == "echo begin task" ]
    then
      n=${c#*:}
      if [ "$HISTFILE" == "$f" ]
      then
        echo "# $d"
        echo "${c#* }"
      else
        echo "# $d"
        echo "resume task: $n"
        histpush "$f"
        echo "HISTFILE is now $HISTFILE"
      fi
    else
      if [ "$HISTFILE" != "$f" ]
      then
        echo "recall: found note in $f"
      fi
      if [ "${c%% *}" == "echo" ]
      then
        echo "# $d"
        echo "${c#* }"
      else
        echo "# $d"
        echo "\$ $c"
        grep "#$t :: " $f | sed -e 's/^#[0-9]* :: //'
      fi
    fi
  fi
}

# Start using a new history file.  Keep a stack of previous
# history files so they may be returned to at a later time.
function histpush {
  if [ -n "$1" ]
  then
    if [ -z "$HISTFILES" ]
    then
      export HISTFILES="$HISTFILE"
    else
      export HISTFILES="$HISTFILES:$HISTFILE"
    fi
    history -a
    export HISTFILE="$1"
    history -r
  fi
}

# Resume using a history file that was in use in the past.
function histpop {
  if [ -n "$HISTFILES" ]
  then
    history -a
    export HISTFILE="${HISTFILES%%:*}"
    history -r
    if [ "${HISTFILES/:/}" == "$HISTFILES" ]
    then
      export HISTFILES=
    else
      export HISTFILES="${HISTFILES#*:}"
    fi
    echo "HISTFILE restored to $HISTFILE"
  else
    echo "histpop: HISTFILES is empty"
  fi
}
