set -l add_completion complete -c update-nix

$add_completion -f  # Disable file completion

if test (uname) = 'Darwin'
  $add_completion --condition '__fish_use_subcommand' -a 'flake home system help'
  $add_completion --condition '__fish_use_subcommand' -l help -s h
else
  function __fishrc_update_nix_list_available_des
    set -l config_dir "$(path dirname (path dirname (path dirname (realpath (status current-filename)))))/nix"
    echo $(cd "$config_dir"; nix eval --json --extra-experimental-features nix-command --extra-experimental-features flakes .#list-des 2>/dev/null) | jq -r '.[]'
  end

  $add_completion --condition '__fish_use_subcommand' -a 'flake home system both all help'
  $add_completion --condition '__fish_seen_subcommand_from system' -a '(__fishrc_update_nix_list_available_des)'
  $add_completion --condition '__fish_seen_subcommand_from home' -a '(__fishrc_update_nix_list_available_des)'
  $add_completion --condition '__fish_use_subcommand' -l help -s h
end
