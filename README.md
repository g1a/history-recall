HISTORY RECALL PROJECT
======================

Manage bash history from multiple terminal windows in a sane and
rational way.

For a quick start, scroll down for installation and usage.


INTRODUCTION
------------

> "Those who forget the past are doomed to retype it."
>      - [George Santayana][1] (paraphrased)

The history recall project helps organize your bash history.
If you have ever been in the position where you are trying
to find the one terminal window that you used to enter an
obscure command so that you can use your bash history to
recall it, then you may be looking for a better way to manage
your history.

Aside:  Note that if you would like to share a single
bash history across *all* of your terminal windows, there
is a simple solution:

    $ unset HISTFILESIZE
    $ export PROMPT_COMMAND="history -a"
    $ shopt -s histappend

For more information on this, see [The Definitive Guide to
Bash Command Line History][2].  If, however, you are accustomed
to doing different tasks in different terminals, and in general
*like* the fact that your history is segregated by terminal window,
then a more complicated solution may meet your needs better.
History Recall is just such a solution.


USAGE
-----

### 'hgrep': Search history in all terminal windows ###

    $ hgrep <regex>

The hgrep command works just like `history | grep <regex>`, save
for the fact that the later searches only the history of the current
terminal window, whereas hgrep searches history in all windows.

    $ hgrep apt-get
    bash_nagai_dev_pts_9:sudo apt-get install chromium-browser
    bash_nagai_dev_pts_5:sudo apt-get install rdesktop
    bash_nagai_dev_pts_5:sudo apt-get install traceroute
    bash_nagai_dev_pts_0:sudo apt-get remove gnome-session-fallback
    bash_nagai_dev_pts_0:sudo apt-get install php-doc

By default, the history files are named after the tty attached to
the terminal window they are running in.  (You can see the tty
of the current window using the 'tty' command.) The history file that
is associated with the current window will be shown last, at the bottom
of all of the output.

### 'termial': Bring the given terminal number frontmost ###

    $ terminal <number>

The terminal command will switch to the desktop containing the terminal
window attached to the specified tty and activate it.

    $ terminal 9

This command will switch to the window containing the terminal
where 'apt-get install chromium-browser' was executed in the
last example.

### 'note' and 'recall': Write a note into history ###

    $ note <command> // <comment>
    $ recall <comment>

The 'note' command will execute the given command and will
write it, allong with the provided command and all of its
command output into the command history. The 'recall' command
will print out the saved information later.

    $ note ls // initial contents
    historyrc
    README.md
    $ recall "initial contents"
    # Thu Nov  8 15:29:52 PST 2012
    $ ls // initial contents
    historyrc
    README.md

### 'task' and 'finished': Create a named task for history ###

    $ task <label>
    $ finished

The 'task' and 'finished' commands

    $ task Install whizzy-fu pro
    begin task: Install whizzy-fu pro
    $ sudu apt-get install whizzyfu libwhizzyfu-dev
    $ ... lots of other stuff
    $ finished
    finished task: Install whizzy-fu pro

... a few days later, in a different terminal:

    $ recall whizzy
    # Fri Oct 12 11:06:43 PDT 2012
    recalled task: Install whizzy-fu pro
    $ ^Rapt-get
    (reverse-i-search)`sudo apt-get': sudo apt-get install whizzyfu libwhizzyfu-dev

INSTALLATION
------------

The History Recall commands are all implemented as bash functions
defined in a single historyrc file.  To install, all that you need
to do is source this file.  If you are using the [utiliscripts][3]
project, history-recall is installed automatically via the move-in
script.  To use history-recall without running move-in, you can follow
the installation instructions below.

First, clone the project from github:

    cd ~/local
    git clone https://github.com/greg-1-anderson/history-recall

Then source the file when your bash shell starts up.

In ~/.bashrc:

    source ~/local/history-recall/historyrc

Once you have installed History Recall, you must either re-source
your .bashrc file or close and re-open your terminal windows.
Once you do this, your bash history will be saved in a separate file
for each terminal window, and your history will persist across reboots.

Nifty.


[1]: http://en.wikipedia.org/wiki/George_Santayana
[2]: http://www.catonmat.net/blog/the-definitive-guide-to-bash-command-line-history/
[3]: http://github.com/greg-1-anderson/utiliscripts
