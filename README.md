<h1>ACM Digital LibraryのデータからUIPediaページを作成</h1>

<ul>
  <li>ACMやCiNiiからRefer型式のデータを取得して変換している</li>
  <li><a href="https://uipedia.herokuapp.com/">Heroku</a>で運用</li>
  <li>
    以下のブックマークを利用<br>
    <code>javascript:window.open(`http://uipedia.herokuapp.com/${escape(location.href)}`)</code>
  </li>
</ul>
