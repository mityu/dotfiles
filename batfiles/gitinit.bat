if not exist ".\.git" (
    git init
    git branch -m main
    git commit --allow-empty -m "Initial commit"
)
