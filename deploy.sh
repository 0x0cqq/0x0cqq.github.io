rm -rf docs/
git add .
git commit -m "Update site on $(date +'%Y-%m-%d')"
hugo --minify
git add .
git commit -m "Build site on $(date +'%Y-%m-%d')"
git push
echo "[[Finish Deploy]]"