# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/yui_tang/google-cloud-sdk/path.fish.inc' ]; . '/Users/yui_tang/google-cloud-sdk/path.fish.inc'; end

# set up alias for hub as git
eval (hub alias -s)

# Load anyenv automatically by adding
# the following to ~/.config/fish/config.fish:

status --is-interactive; and source (anyenv init -|psub)
