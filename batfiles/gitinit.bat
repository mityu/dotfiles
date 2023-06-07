@echo off
if not exist ".\.git" (
    git init --initial-branch main
    git commit --allow-empty -m "Initial commit"
)
