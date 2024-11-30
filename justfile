build msg:
    stack exec site rebuild
    git add .
    git commit -m {{msg}}
    git push
