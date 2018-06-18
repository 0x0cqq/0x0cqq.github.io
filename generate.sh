#!/bin/sh

cd "/Users/chenqq/Documents/Github/ChenQiqian.github.io/"

hexo clean
gulp clean
hexo g
gulp
gulp mv