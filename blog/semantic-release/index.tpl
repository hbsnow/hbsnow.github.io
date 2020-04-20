<header class="main__header"><div class="content-header"><div class="container"><h1 class="content-header__title" id="content-title">semantic-release による npm publish と ChangeLog 出力の自動化</h1><div class="content-header__metadata"><div class="content-header__date"><span class="content-header__data"><time class="content-header__published" datetime="2017-09-03">2017-09-03</time></span><hr class="content-header__sepalate"><span class="content-header__data"><time class="content-header__modified" datetime="2019-06-09">2019-06-09</time>
に更新</span></div></div></div></div></header><div class="main__body"><div class="content-body"><div class="container"><p>npm にパッケージの公開、あるいはその更新をするとき、その手順であったり、そもそも手順どころか <code>npm publish</code> すること自体忘れるということがあります。ここではこの自動化に <a href="https://www.npmjs.com/package/semantic-release">semantic-release</a> を使った方法を紹介します。</p>
<h2>環境設定</h2>
<div class="codeblock"><div class="codeblock__title">bash</div><pre class="codeblock__content bash"><code class="codeblock__code codeblock__code--bash">npm install -g semantic-release-cli
semantic-release-cli setup
</code></pre>
</div>
<p>設定は <a href="https://www.npmjs.com/package/semantic-release-cli">semantic-release-cli</a> によって、対話的に作成することができます。環境の設定以外にも、すでに package.json のあるプロジェクトに必要な <code>script</code> の記述の追加や、.travis.yml の生成しもてくれます。</p>
<p>また、単にリリースする以外にも ChangeLog の出力や Tag をつけてくれたりといったことも自動化してくれます。</p>
<h2>使い方</h2>
<p>バージョンを自動であげるには、コミットログの形式が <a href="https://github.com/angular/angular.js/blob/master/DEVELOPERS.md#type">AngularJS Commit Message Conventions</a> であり、デフォルトの設定では以下の <code>&lt;Type&gt;</code> である必要があります。</p>
<table>
<tr>
<th>
<p>Type</p>
</th>
<th>
<p>Release type</p>
</th>
</tr>
<tr>
<td>
<p>fix</p>
</td>
<td>
<p>Patch Release</p>
</td>
</tr>
<tr>
<td>
<p>feat</p>
</td>
<td>
<p>Feature Release</p>
</td>
</tr>
<tr>
<td>
<p>perf</p>
</td>
<td>
<p>Breaking Release</p>
</td>
</tr>
</table>
<h2>Scoped Packages</h2>
<p>公開するパッケージが <a href="https://docs.npmjs.com/getting-started/scoped-packages">Scoped Packages</a> である場合、<code>access</code> が <code>public</code> である必要があるため、package.json に以下を追加してください。</p>
<div class="codeblock"><div class="codeblock__title">package.json</div><pre class="codeblock__content json"><code class="codeblock__code codeblock__code--json">{
  ...
  &quot;publishConfig&quot;: {
    &quot;access&quot;: &quot;public&quot;
  }
}
</code></pre>
</div>
<h2>正しく動作しないケース</h2>
<p>package.json に files を指定していて、かつそのディレクトリが .gitignore されているとき、正しく動作しなかったので semantic-release を使うのをやめた。よくわからないが、一度 semantic-release でリリースしたものについては、いくら手動で <code>npm publish</code> しても files に指定したものが publish されなかった。</p>
<h3>手動で更新する方法</h3>
<p>手動で <code>npm publish</code> する場合、以下のコマンドを叩くとバージョンが更新される。</p>
<table>
<tr>
<th>
<p>Command</p>
</th>
<th>
<p>Release type</p>
</th>
</tr>
<tr>
<td>
<p><code>npm version patch</code></p>
</td>
<td>
<p>Patch Release</p>
</td>
</tr>
<tr>
<td>
<p><code>npm version minor</code></p>
</td>
<td>
<p>Feature Release</p>
</td>
</tr>
<tr>
<td>
<p><code>npm version major</code></p>
</td>
<td>
<p>Breaking Release</p>
</td>
</tr>
</table>
<ul>
<li><a href="https://docs.npmjs.com/cli/version">npm-version</a></li>
</ul>
<p>リリースの手順としては</p>
<ol>
<li><code>npm version TYPE</code></li>
<li><code>git push origin TAG_NAME</code></li>
<li><code>npm publish</code></li>
</ol>
<p>となる。</p>
</div></div></div>