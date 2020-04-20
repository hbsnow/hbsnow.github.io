<header class="main__header"><div class="content-header"><div class="container"><h1 class="content-header__title" id="content-title">デザインパターンの学習メモ「State パターン」</h1><div class="content-header__metadata"><div class="content-header__date"><span class="content-header__data"><time class="content-header__published" datetime="2019-05-05">2019-05-05</time></span></div></div></div></div></header><div class="main__body"><div class="content-body"><div class="container"><p>GoF のデザインパターンのうちの一つ、State パターンについて PHP のサンプルコードを交えて学習していきます。</p>
<p>State パターンは、<a href="https://ja.wikipedia.org/wiki/State_%E3%83%91%E3%82%BF%E3%83%BC%E3%83%B3">Wikipedia では以下のように解説</a>されています。</p>
<blockquote>
<p>このパターンはオブジェクトの状態（state）を表現するために用いられる。ランタイムでそのタイプを部分的に変化させるオブジェクトを扱うクリーンな手段となる。</p>
</blockquote>
<p>この説明ではなにもわからないので、サンプルコードを用いながら考えていきます。</p>
<h2>State パターンを使用しない例</h2>
<p>アクション RPG におけるキャラクターの状態変化をサンプルとして用います。</p>
<div class="codeblock"><div class="codeblock__title">php</div><pre class="codeblock__content php"><code class="codeblock__code codeblock__code--php">&lt;?php
declare(strict_types=1);

class Hero
{
    const WAIT = 0;
    const WALK = 1;
    const FIGHT = 2;

    public $state = self::WAIT;

    public function wait(): string
    {
        switch ($this-&gt;state) {
            case self::WAIT:
                return '休憩';
            case self::WALK:
                $this-&gt;state = self::WAIT;
                return '待機';
            case self::FIGHT:
                $this-&gt;state = self::WAIT;
                return '待機';
        }
    }

    public function walk(): string
    {
        switch ($this-&gt;state) {
            case self::WAIT:
                $this-&gt;state = self::WALK;
                return '歩く';
            case self::WALK:
                return '走る';
            case self::FIGHT:
                $this-&gt;state = self::WALK;
                return '逃げる';
        }
    }

    public function fight(): string
    {
        switch ($this-&gt;state) {
            case self::WAIT:
                $this-&gt;state = self::FIGHT;
                return '攻撃';
            case self::WALK:
                $this-&gt;state = self::FIGHT;
                return '攻撃';
            case self::FIGHT:
                return '連撃';
        }
    }
}

$hero = new Hero();
echo &lt;&lt;&lt; EOT
{$hero-&gt;walk()}
{$hero-&gt;walk()}
{$hero-&gt;wait()}
{$hero-&gt;fight()}
{$hero-&gt;fight()}
{$hero-&gt;walk()}
{$hero-&gt;wait()}
{$hero-&gt;wait()}
EOT;
</code></pre>
</div>
<p>仕様変更で Hero に防御の行動が追加されたらどうなるかを考えると、このコードは開放/閉鎖原則に違反していることがわかります。</p>
<h2>State パターンを使用する例</h2>
<div class="codeblock"><div class="codeblock__title">php</div><pre class="codeblock__content php"><code class="codeblock__code codeblock__code--php">&lt;?php
declare(strict_types=1);

interface StateInterface
{
    public function wait(): string;
    public function walk(): string;
    public function fight(): string;
}

class Hero
{
    public $waitState;
    public $walkState;
    public $fightState;

    public $state;

    public function __construct()
    {
        $this-&gt;waitState = new WaitState($this);
        $this-&gt;walkState = new WalkState($this);
        $this-&gt;fightState = new FightState($this);

        $this-&gt;state = $this-&gt;waitState;
    }

    public function wait(): string
    {
        return $this-&gt;state-&gt;wait();
    }

    public function walk(): string
    {
        return $this-&gt;state-&gt;walk();
    }

    public function fight(): string
    {
        return $this-&gt;state-&gt;fight();
    }
}

class WaitState implements StateInterface
{
    public $hero;

    public function __construct(Hero $hero)
    {
        $this-&gt;hero = $hero;
    }

    public function wait(): string
    {
        return '休憩';
    }

    public function walk(): string
    {
        $this-&gt;hero-&gt;state = $this-&gt;hero-&gt;walkState;
        return '歩く';
    }

    public function fight(): string
    {
        $this-&gt;hero-&gt;state = $this-&gt;hero-&gt;fightState;
        return '攻撃';
    }
}

class WalkState implements StateInterface
{
    private $hero;

    public function __construct(Hero $hero)
    {
        $this-&gt;hero = $hero;
    }

    public function wait(): string
    {
        $this-&gt;hero-&gt;state = $this-&gt;hero-&gt;waitState;
        return '待機';
    }

    public function walk(): string
    {
        return '走る';
    }

    public function fight(): string
    {
        $this-&gt;hero-&gt;state = $this-&gt;hero-&gt;fightState;
        return '攻撃';
    }
}

class FightState implements StateInterface
{
    private $hero;

    public function __construct(Hero $hero)
    {
        $this-&gt;hero = $hero;
    }

    public function wait(): string
    {
        $this-&gt;hero-&gt;state = $this-&gt;hero-&gt;waitState;
        return '待機';
    }

    public function walk(): string
    {
        $this-&gt;hero-&gt;state = $this-&gt;hero-&gt;walkState;
        return '逃げる';
    }

    public function fight(): string
    {
        return '連撃';
    }
}

$hero = new Hero();

echo &lt;&lt;&lt; EOT
{$hero-&gt;walk()}
{$hero-&gt;walk()}
{$hero-&gt;wait()}
{$hero-&gt;fight()}
{$hero-&gt;fight()}
{$hero-&gt;walk()}
{$hero-&gt;wait()}
{$hero-&gt;wait()}
EOT;
</code></pre>
</div>
<p>State パターンを使用すると開放/閉鎖原則に違反のないコードになっていることがわかります。</p>
</div></div></div>