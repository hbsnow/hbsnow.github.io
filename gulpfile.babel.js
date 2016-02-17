'use strict';

import gulp from 'gulp';
import gulpLoadPlugins from 'gulp-load-plugins';
import runSequence from 'run-sequence';
import del from 'del';
import path from 'path';
import slash from 'slash';
import rename from 'rename';
import autoprefixer from 'autoprefixer';

const $ = gulpLoadPlugins();

const paths = {
  'src': 'source',
  'tmp': 'tmp',
  'build': 'public'
};

gulp.task('build:jade', () => {
  return gulp.src(paths.src + '/site/index.jade')
    .pipe($.jade())
    .pipe(gulp.dest(paths.build));
});

gulp.task('build:components-jade', () => {
  return gulp.src(paths.src + '/components/**/*.jade')
    .pipe($.cached('components-jade'))
    .pipe($.plumber({
      errorHandler(err) {
        console.log(err);
        this.emit('end');
      }
    }))
    .pipe(gulp.dest(paths.tmp + '/components'))
    .pipe($.tap((file) => {
      const jadeDir = slash(path.dirname(file.relative));
      const jadePath = slash(file.relative);
      const srcPath = slash(path.join(paths.tmp, 'components', jadePath));
      const buildPath = slash(path.join(paths.build, 'components', jadeDir));

      if(path.basename(file.relative) === 'components.jade') {
        gulp.src(srcPath)
          .pipe($.jade())
          .pipe(gulp.dest(buildPath))
          .pipe($.rename({basename:'import'}))
          .pipe(gulp.dest(paths.build + '/components'));
      } else {
        gulp.src(srcPath)
          .pipe($.jade())
          .pipe(gulp.dest(buildPath));
      }
    }));
});

gulp.task('build:components-css', () => {
  return gulp.src(paths.src + '/components/**/*.css')
    .pipe($.cached('components-css'))
    .pipe($.plumber({
      errorHandler(err) {
        console.log(err);
        this.emit('end');
      }
    }))
    .pipe($.postcss([
      autoprefixer()
    ]))
    .pipe(gulp.dest(paths.tmp + '/components'))
    .pipe($.tap((file) => {
      // CSSに変更があった場合、それをincludeしているJadeも変換する
      const jadeDir = slash(path.dirname(file.relative));
      const jadePath = slash(rename(file.relative, {extname:'.jade'}));

      gulp.src(path.join(paths.tmp, 'components', jadePath))
        .pipe($.jade())
        .pipe(gulp.dest(path.join(paths.build, 'components', jadeDir)));
    }));
});

gulp.task('build:components-js', () => {
  return gulp.src(paths.src + '/components/**/*.js')
    .pipe($.cached('components-js'))
    .pipe($.plumber({
      errorHandler(err) {
        console.log(err);
        this.emit('end');
      }
    }))
    .pipe($.uglify())
    .pipe(gulp.dest(paths.build + '/components'));
});

gulp.task('build:components-assets',() => {
  const svg = gulp.src(paths.src + '/components/**/*.svg')
    .pipe($.changed(paths.tmp + '/components'))
    .pipe(gulp.dest(paths.tmp + '/components'));

  return svg;
});

gulp.task('copy:bower', () => {
  return gulp.src('bower_components/**/*')
    .pipe($.changed(paths.build + '/bower_components'))
    .pipe(gulp.dest(paths.build + '/bower_components'));
});

gulp.task('copy:asset', () => {
  return gulp.src(paths.src + '/assets/**/*')
    .pipe($.changed(paths.build))
    .pipe(gulp.dest(paths.build));
});

gulp.task('serve', () => {
  return gulp.src(paths.build)
    .pipe($.webserver());
});

gulp.task('watch', ['serve', 'build'], () => {
  gulp.watch(paths.src + '/site/**/*.jade', ['build:jade']);
  gulp.watch(paths.src + '/components/**/*.css', ['build:components-css']);
  gulp.watch(paths.src + '/components/**/*.jade', ['build:components-jade']);
  gulp.watch(paths.src + '/components/**/*.js', ['build:components-js']);
});

gulp.task('build', (cb) => {
  runSequence(
    'clean:watch',
    'build:components-assets',
    [
      'build:jade',
      'build:components-css',
      'build:components-js', 
      'copy:bower',
      'copy:asset'
    ],
    'build:components-jade',
    cb
  )
});

gulp.task('clean:watch', () => {
  return del([
    paths.tmp,
    paths.build,
    '!' + paths.build + '/bower_components'
  ]);
});

// vulcanize後にimport済みの使用しないファイルを削除する
gulp.task('clean:build', () => {
  return del([
    paths.tmp,
    paths.build + '/bower_components',
    paths.build + '/components/**/*',
    '!' + paths.build + '/components/import.html'
  ]);
});