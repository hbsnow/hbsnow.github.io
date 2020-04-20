<header class="main__header"><div class="content-header"><div class="container"><h1 class="content-header__title" id="content-title">デザインパターンの学習メモ「Strategy パターン」</h1><div class="content-header__metadata"><div class="content-header__date"><span class="content-header__data"><time class="content-header__published" datetime="2018-09-27">2018-09-27</time></span><hr class="content-header__sepalate"><span class="content-header__data"><time class="content-header__modified" datetime="2019-05-04">2019-05-04</time>
に更新</span></div></div></div></div></header><div class="main__body"><div class="content-body"><div class="container"><p>GoF のデザインパターンのうちの一つ、Strategy パターンについて PHP のサンプルコードを交えて学習していきます。</p>
<p>Strategy パターンは、<a href="https://ja.wikipedia.org/wiki/Strategy_%E3%83%91%E3%82%BF%E3%83%BC%E3%83%B3">Wikipedia では以下のように解説</a>されています。</p>
<blockquote>
<p>Strategy パターンは、コンピュータープログラミングの領域において、アルゴリズムを実行時に選択することができるデザインパターンである。</p>
</blockquote>
<p>この一文ではわかりにくいのですが、Strategy パターンの目的についての解説は比較的わかりやすいかもしれません。</p>
<blockquote>
<p>Strategy パターンは、アプリケーションで使用されるアルゴリズムを動的に切り替える必要がある際に有用である。Strategy パターンはアルゴリズムのセットを定義する方法を提供し、これらを交換可能にすることを目的としている。Strategy パターンにより、アルゴリズムを使用者から独立したまま様々に変化させることができるようになる。</p>
</blockquote>
<p>実際に Strategy パターンがどういうものなのかを、サンプルコードを用いながら考えていきます。</p>
<h2>Strategy パターンを使用しない例</h2>
<p>ゲームの敵をサンプルとして用います。</p>
<div class="codeblock"><div class="codeblock__title">php</div><pre class="codeblock__content php"><code class="codeblock__code codeblock__code--php">&lt;?php
declare(strict_types=1);

interface Walkable
{
    public function walk(): string;
}

interface Flyable
{
    public function fly(): string;
}

class Monster
{
}

class Slime extends Monster implements Walkable
{
    public function walk(): string
    {
        return 'ゆっくり歩く';
    }
}

class Goblin extends Monster implements Walkable
{
    public function walk(): string
    {
        return '歩く';
    }
}

class Dragon extends Monster implements Walkable, Flyable
{
    public function walk(): string
    {
        return '歩く';
    }

    public function fly(): string
    {
        return '飛ぶ';
    }
}

$Slime = new Slime();
$Goblin = new Goblin();
$Dragon = new Dragon();

echo &lt;&lt;&lt; EOT
Slime
{$Slime-&gt;walk()}

Goblin
{$Goblin-&gt;walk()}

Dragon
{$Dragon-&gt;walk()}
{$Dragon-&gt;fly()}
EOT;
</code></pre>
</div>
<p>Monser という具象クラスがあって、それぞれのモンスター</p>
<ul>
<li>Slime (ゆっくり歩ける)</li>
<li>Goblin (歩ける)</li>
<li>Dragon (歩ける・飛べる)</li>
</ul>
<p>は Monser クラスを継承しています。モンスターの行動「歩く」と「飛ぶ」についてはインターフェースを作成してそれぞれの継承先のクラスに実装しました。</p>
<p>問題はインターフェースが実装をもたないことから、Goblin と Dragon の「歩く」という同じコードの再利用ができていないために保守性が損なわれています。</p>
<h2>Strategy パターンを使用する例</h2>
<div class="codeblock"><div class="codeblock__title">php</div><pre class="codeblock__content php"><code class="codeblock__code codeblock__code--php">&lt;?php
declare(strict_types=1);

interface WalkInterface
{
    public function walk();
}

class NormalWalk implements WalkInterface
{
    public function walk()
    {
        return &quot;歩く&quot;;
    }
}

class SlowWalk implements WalkInterface
{
    public function walk()
    {
        return &quot;ゆっくり歩く&quot;;
    }
}

interface FlyInterface
{
    public function fly();
}

class NormalFly implements FlyInterface
{
    public function fly()
    {
        return &quot;飛ぶ&quot;;
    }
}

class NoFly implements FlyInterface
{
    public function fly()
    {
        // 飛べないので何もしない
    }
}

class Monster
{
    private $walkBehavior;
    private $flyBehavior;

    public function __construct(
        WalkInterface $walkBehavior,
        FlyInterface $flyBehavior
    ) {
        $this-&gt;walkBehavior = $walkBehavior;
        $this-&gt;flyBehavior = $flyBehavior;
    }

    public function walk()
    {
        return $this-&gt;walkBehavior-&gt;walk();
    }

    public function fly()
    {
        return $this-&gt;flyBehavior-&gt;fly();
    }
}

class Goblin extends Monster
{
}

class Slime extends Monster
{
}

class Dragon extends Monster
{
}

$normalWalk = new NormalWalk();
$slowWalk = new SlowWalk();
$normalFly = new NormalFly();
$noFly = new NoFly();

$Goblin = new Goblin($normalWalk, $noFly);
$Slime = new Slime($slowWalk, $noFly);
$Dragon = new Dragon($normalWalk, $normalFly);

echo &lt;&lt;&lt; EOT
Slime
{$Slime-&gt;walk()}

Goblin
{$Goblin-&gt;walk()}

Dragon
{$Dragon-&gt;walk()}
{$Dragon-&gt;fly()}
EOT;
</code></pre>
</div>
<p>上記のサンプルでは「歩く」と「飛ぶ」の 2 つの振る舞いに対してプログラミングしています。そのため例えばドラゴンをゆっくり歩かせたくなった場合、 <code>new Dragon($normalWalk, $normalFly)</code> とインスタンスの生成部分にある <code>$normalWalk</code> を <code>$slowWalk</code> と交換することにより変更が可能です。</p>
<h2>開放/閉鎖原則</h2>
<p>このパターンについては Open-Closed Principle (開放/閉鎖原則) を知っているとより理解しやすいかもしれません。開放/閉鎖原則は理解しにくいのですが、下記の動画がとてもわかりやすいのでおすすめです。</p>
<ul>
<li><a href="https://www.youtube.com/watch?v=cUV1nXPfjFY">「SOLID の原則ってどんなふうに使うの？オープン・クローズドの原則編 拡大版」　 後藤英宣</a></li>
</ul>
</div></div></div>