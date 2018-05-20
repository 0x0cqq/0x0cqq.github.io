#!/bin/sh

hexo clean
gulp clean
hexo g
gulp
gulp mv
hexo s