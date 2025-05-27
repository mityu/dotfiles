function fish_should_add_to_history --description 'Decide whether a command should be recorded to the history'
  if test (string trim $argv) = "cd"
    return 1
  end
  return 0
end
