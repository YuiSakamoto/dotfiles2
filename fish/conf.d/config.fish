###
### peco settings
###

function fish_user_key_bindings
  bind \cr peco_select_history
end


###
### bobthefish default variables
###

set -g theme_display_git yes
#     set -g theme_display_git_dirty no
set -g theme_display_git_untracked yes
#     set -g theme_display_git_ahead_verbose yes
#     set -g theme_display_git_dirty_verbose yes
#     set -g theme_display_git_stashed_verbose yes
#     set -g theme_display_git_master_branch yes
#     set -g theme_git_worktree_support yes
#     set -g theme_display_vagrant yes
set -g theme_display_docker_machine yes
#     set -g theme_display_k8s_context yes
set -g theme_display_hg no
#     set -g theme_display_virtualenv no
#     set -g theme_display_ruby no
#     set -g theme_display_user ssh
#     set -g theme_display_hostname ssh
#     set -g theme_display_vi yes
#     set -g theme_display_nvm yes
#     set -g theme_avoid_ambiguous_glyphs yes
set -g theme_powerline_fonts yes
#     set -g theme_nerd_fonts yes
#     set -g theme_show_exit_status yes
#     set -g default_user your_normal_user
#     set -g theme_color_scheme dark
set -g fish_prompt_pwd_dir_length 8
set -g theme_project_dir_length 8
set -g theme_newline_cursor yes
set GHQ_SELECTOR peco
