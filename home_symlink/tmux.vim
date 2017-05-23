# ~/.tmux.conf
# By Tyler Mulligan. Public domain.
#
# This configuration file binds many of the common GNU screen key bindings to
# appropriate tmux key bindings. Note that for some key bindings there is no
# tmux analogue and also that this set omits binding some commands available in
# tmux but not in screen.
#
# Note this is a good starting point but you should check out the man page for more
# configuration options if you really want to get more out of tmux

source-file ~/.tmux.keys

# History
set -g history-limit 10000

# start at 1
set -g base-index 1

# Use zsh
set -g default-shell /usr/bin/zsh

new-session

set -g @shell_mode 'vi'

# List of plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'tmux-plugins/tmux-yank'
set -g @plugin 'tmux-plugins/tmux-copycat'
set -g @plugin 'tmux-plugins/tmux-open'
set -g @plugin 'tmux-plugins/tmux-urlview'
set -g @plugin 'tmux-plugins/tmux-logging'
set -g @plugin 'tmux-plugins/tmux-pain-control'
set -g @plugin 'seebi/tmux-colors-solarized'

# Other examples:
# set -g @plugin 'github_username/plugin_name'
# set -g @plugin 'git@github.com/user/plugin'
# set -g @plugin 'git@bitbucket.com/user/plugin'

# Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
run '~/.tmux/plugins/tpm/tpm'
