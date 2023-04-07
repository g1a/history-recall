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

> $ hgrep &lt;regex&gt;  

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

> $ terminal &lt;number&gt;  

The terminal command will switch to the desktop containing the terminal
window attached to the specified tty and activate it.

    $ terminal 9

This command will switch to the window containing the terminal
where 'apt-get install chromium-browser' was executed in the
last example.

### 'note', 'notes' and 'recall': Write a note into history ###

> $ note &lt;command&gt; // &lt;comment&gt;  
> $ notes  
> $ recall &lt;comment&gt;  

The 'note' command will execute the given command and will
write it, allong with the provided command and all of its
command output into the command history. The 'notes' command
will list all of the notes taken, but only from those in
the current terminal.  The 'recall' command will print out the
information saved information later.  Note that 'recall' will
find notes that were entered in any terminal.

    $ note ls // initial contents
    historyrc
    README.md
    $ notes
    [Thu Nov  8 15:29:52 PST 2012]$ ls // initial contents
    $ recall "initial contents"
    # Thu Nov  8 15:29:52 PST 2012
    $ ls // initial contents
    historyrc
    README.md

### 'task' and 'finished': Create a named task for history ###

> $ task &lt;label&gt;  
> $ finished  

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

```
$ cd $HOME/persistent/install/location
$ git clone https://github.com/g1a/history-recall.git
$ cd history-recall
$ source history-install.sh
```

The `history-install.sh` script will create a `$HOME/.historyrc` file that sources the history recall script. This file will be sourced from your ~/.bash_profile or ~/.bashrc file. This will install history-recall in the active terminal window, but it will not be available in other windows.

Manual installation is also an option; all that you need to do is source the history-recall.sh script from ~/.bash_profile or ~/.bashrc (or other startup script).

Once you have manually installed History Recall, you must either re-source
your .bashrc file or close and re-open your terminal windows.
Once you do this, your bash history will be saved in a separate file
for each terminal window, and your history will persist across reboots.

Nifty.


[1]: http://en.wikipedia.org/wiki/George_Santayana
[2]: http://www.catonmat.net/blog/the-definitive-guide-to-bash-command-line-history/
[3]: http://github.com/greg-1-anderson/utiliscripts
