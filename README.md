HISTORY RECALL PROJECT

Manage bash history from multiple terminal windows in a sane and
rational way.

For a quick start, scroll down for installation and usage.


INTRODUCTION

----------------------------------------------------
"Those who forget the past are doomed to retype it."
[George Santayana][1] (paraphrased)
----------------------------------------------------

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

Docs to-be-written.  See the script itself.


INSTALLATION

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
