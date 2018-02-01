// npm install gulp-shell gulp-clean gulp-minify-html gulp-minify-css gulp-uglify gulp-notify --save-dev   
var gulp = require('gulp'),
    clean = require('gulp-clean'),
    minifyCss = require('gulp-minify-css'),
    minifyHtml = require('gulp-minify-html'),
    uglify = require('gulp-uglify'),
    notify = require('gulp-notify'),
    shell = require('gulp-shell');
//清空dest文件夹
gulp.task("clean",function() {
    return gulp.src("./dst/*")
    .pipe(clean());
});
// 压缩css文件，已压缩文件不用再压缩
gulp.task("css",function() {
    return gulp.src(["public/**/*.css","!public/**/*.min.css"])
    .pipe(minifyCss({compatibility: "ie8"}))
    .pipe(gulp.dest("./dst/"));   
});
// 压缩js文件
gulp.task("js",function() {
    return gulp.src(["public/**/*.js","!public/**/*.min.js"])
    .pipe(uglify())
    .pipe(gulp.dest("./dst/"));
});
// 压缩html文件
gulp.task("html",function() {
    return gulp.src("public/**/*.html")
    .pipe(minifyHtml())
    .pipe(gulp.dest("./dst/"));
});
// 设置默认任务，command line下输入gulp执行
// clean任务执行完成了才会去运行其他的任务，在gulp.start()里的任务执行的顺序是不确定的，所以将要在它们之前执行的任务写在数组里面
gulp.task("default",['clean'],function() {
    gulp.start('css', 'js', 'html');
});
// dst文件复制到public
gulp.task("mv",function() {
    return gulp.src("./dst/*")
    .pipe(shell([
        "cp -r ./dst/* ./public/"
    ]));
});