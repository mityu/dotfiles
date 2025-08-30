function fish_prompt --description 'Write out the prompt'
  set -l last_status $status
  set -l vcs_color_name brblack
  set -l normal (set_color normal)
  set -l status_color (set_color brgreen)
  set -l cwd_color (set_color yellow)
  set -l vcs_color (set_color $vcs_color_name)
  set -l prompt_status ""

  set -g __fish_git_prompt_showcolorhints true
  set -g __fish_git_prompt_showdirtystate true
  set -g __fish_git_prompt_showuntrackedfiles true
  set -g __fish_git_prompt_showstashstate true
  set -g __fish_git_prompt_show_informative_status true
  set -g __fish_git_prompt_showupstream name verbose
  set -g __fish_git_prompt_char_dirtystate "*"
  set -g __fish_git_prompt_char_upstream_prefix " →"
  set -g __fish_git_prompt_char_upstream_equal ""
  set -g __fish_git_prompt_color $vcs_color_name
  set -g __fish_git_prompt_color_dirtystate magenta
  set -g __fish_git_prompt_color_untrackedfiles red
  set -g __fish_git_prompt_color_stashstate cyan

  # Since we display the prompt on a new line allow the directory names to be longer.
  set -q fish_prompt_pwd_dir_length
  or set -lx fish_prompt_pwd_dir_length 0

  # Color the prompt differently when we're root
  set -l suffix '$'
  if functions -q fish_is_root_user; and fish_is_root_user
    if set -q fish_color_cwd_root
      set cwd_color (set_color $fish_color_cwd_root)
    end
    set suffix '#'
  end

  # Color the prompt in red on error
  if test $last_status -ne 0
    set status_color (set_color $fish_color_error)
  end
  set prompt_status $status_color "#" $last_status $normal

  set -l prompt_loginuser ''
  if set -q SSH_TTY
    set prompt_loginuser "$(set_color $fish_color_host_remote)SSH$(set_color normal):$(prompt_login) "
  end

  echo -s (set_color magenta) "fish " $normal $prompt_loginuser $prompt_status ' ' $cwd_color (prompt_pwd) $vcs_color (fish_vcs_prompt) $normal
  echo -n -s $suffix ' '
end
