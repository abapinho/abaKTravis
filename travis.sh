#!/bin/bash
abapmerge src/zabak.prog.abap > ../zabak.abap
wc -l ../zabak.abap
cd ..
git clone https://github.com/abapinho/abaK_build.git
ls -l
cp zabak.abap build/zabak.abap
cd build
git status
git config --global user.email "builds@travis-ci.com"
git config --global user.name "Travis CI"
git add zabak.abap
git commit -m "Travis build $TRAVIS_BUILD_NUMBER"
git push -q https://$GITHUB_API_KEY@github.com/abapinho/abaK_build.git > /dev/null 2>&1
