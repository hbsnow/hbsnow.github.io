<header class="main__header"><div class="content-header"><div class="container"><h1 class="content-header__title" id="content-title">PostCSS の設定ファイル</h1><div class="content-header__metadata"><div class="content-header__date"><span class="content-header__data"><time class="content-header__published" datetime="2018-04-08">2018-04-08</time></span><hr class="content-header__sepalate"><span class="content-header__data"><time class="content-header__modified" datetime="2018-05-29">2018-05-29</time>
に更新</span></div></div></div></div></header><div class="main__body"><div class="content-body"><div class="container"><p>PostCSS のビルドでは <a href="https://github.com/postcss/postcss-cli">PostCSS CLI</a> を使わず、gulp-postcss を使います。理由は後述。</p>
<div class="codeblock"><div class="codeblock__title">gulpfile.js</div><pre class="codeblock__content js"><code class="codeblock__code codeblock__code--js">const gulp = require('gulp')
const postcss = require('gulp-postcss')
const filter = require('gulp-filter')
const pump = require('pump')

gulp.task('build:css', cb =&gt; {
  pump(
    [
      gulp.src('src/**/*.css'),
      postcss({ modules: true }),
      filter(['**', '!**/_*.css']),
      gulp.dest('docs')
    ],
    cb
  )
})
</code></pre>
</div>
<p>Sass のように <code>@import</code> されるファイルには prefix として <code>_</code> をつけて、出力しないような処理をしています。</p>
<p>出力したいファイルを <code>src/main.css</code> のように決め打ちしてしまうと、<code>@import</code> したファイルを <a href="https://github.com/anandthakker/doiuse">doiuse</a> や <a href="https://github.com/stylelint/stylelint">stylelint</a> にかけることができません。<a href="https://github.com/postcss/postcss-import">postcss-import</a> で結合後に LINT を実行することは可能ですが、結合してしまったあとでは、レポートされる行数が当然結合後の行数を示すことになり、使い物になりません。PostCSS CLI を使わないのはこれが理由です。</p>
<div class="codeblock"><div class="codeblock__title">.postcssrc.js</div><pre class="codeblock__content js"><code class="codeblock__code codeblock__code--js">const path = require('path')

module.exports = ctx =&gt; {
  const file = path.parse(ctx.file.path)

  // ファイル名が `_` から始まるものを判定し、
  // trueであればpostcss-import以降を実行しない
  const isPartial = file.name.startsWith('_')

  return {
    map: ctx.env !== 'production',
    plugins: Object.assign(
      {},
      {
        doiuse: {
          // なぜか一つ設定をいれておかないと.browserslistrcを読み込まない
          ignore: []
        },
        stylelint: {},
        'postcss-reporter': {
          clearReportedMessages: true
        }
      },
      isPartial
        ? {}
        : {
            'postcss-import': {},
            'postcss-flexbugs-fixes': {},
            'postcss-gap-properties': {},
            autoprefixer: {
              grid: true
            },
            cssnano: {
              'postcss-discard-unused': true,
              'postcss-merge-idents': true,
              'postcss-reduce-idents': true,
              'z-index': true
            }
          }
    )
  }
}
</code></pre>
</div>
<p>使用するプラグインは以下の通り。</p>
<ul>
<li><a href="https://github.com/anandthakker/doiuse">doiuse</a></li>
<li><a href="https://github.com/stylelint/stylelint">stylelint</a></li>
<li><a href="https://github.com/postcss/postcss-reporter">postcss-reporter</a></li>
<li><a href="https://github.com/postcss/postcss-import">postcss-import</a></li>
<li><a href="https://github.com/luisrudge/postcss-flexbugs-fixes">postcss-flexbugs-fixes</a></li>
<li><a href="https://github.com/postcss/autoprefixer">autoprefixer</a></li>
<li><a href="http://cssnano.co/">cssnano</a></li>
</ul>
<p>フォーマッタには <a href="https://github.com/prettier/prettier">prettier</a> を使うので、PostCSS ではフォーマットをしていません。</p>
<p>doiuse についてはコメントアウトでも書いていますが、何故か一つでも何かしらの設定がないと、<code>.browserslistrc</code> の設定を読み込んでくれないので注意が必要です(そのうち修正されると思いますが……)。</p>
</div></div></div>