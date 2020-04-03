# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/yui_tang/google-cloud-sdk/path.fish.inc' ]; . '/Users/yui_tang/google-cloud-sdk/path.fish.inc'; end

# set up alias for hub as git
eval (hub alias -s)
set -g fish_user_paths "/usr/local/opt/bzip2/bin" $fish_user_paths
