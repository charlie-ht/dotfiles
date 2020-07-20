# When you've forgotten everything again, git help -ag is useful to
# see all the stuff you need to read again...
alias gith='git help -w'
alias git_clean_whitespace='git diff --cached --no-color > stage.diff && git apply --index -R stage.diff && git apply --index --whitespace=fix stage.diff && rm -f stage.diff'

c_git_find_reviewers () {
    git blame --line-porcelain $1 | sed -n 's/^author //p' | sort | uniq -c | sort -rn
}

c_git_ignore_untracked_files () {
    git status --porcelain | grep '^??' | cut -c4- >> .gitignore
}
