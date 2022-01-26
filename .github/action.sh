# modified from https://github.com/mhausenblas/mkdocs-deploy-gh-pages
#!/bin/bash

set -e

function print_info() {
    echo -e "\e[36mINFO: ${1}\e[m"
}

for package in ${EXTRA_PACKAGES}
do
    apk add --no-cache "${package}"
done

if [ -n "${GITHUB_TOKEN}" ]; then
    print_info "setup with GITHUB_TOKEN"
    remote_repo="https://x-access-token:${GITHUB_TOKEN}@${GITHUB_DOMAIN:-"github.com"}/${GITHUB_REPOSITORY}.git"
elif [ -n "${PERSONAL_TOKEN}" ]; then
    print_info "setup with PERSONAL_TOKEN"
    remote_repo="https://x-access-token:${PERSONAL_TOKEN}@${GITHUB_DOMAIN:-"github.com"}/${GITHUB_REPOSITORY}.git"
else
    print_info "no token found; linting"
fi

if ! git config --get user.name; then
    git config --global user.name "${GITHUB_ACTOR}"
fi

if ! git config --get user.email; then
    git config --global user.email "${GITHUB_ACTOR}@users.noreply.${GITHUB_DOMAIN:-"github.com"}"
fi

git remote rm origin
git remote add origin "${remote_repo}"

git checkout -b gh-pages
git checkout gh-pages
rm -r !\(docs\)
mv ./docs/* .
rm -r docs

git add .
git commit -m "Build site on $(date +'%Y-%m-%d')"
git push
echo "[[Finish Deploy]]"
