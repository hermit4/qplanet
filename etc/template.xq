declare variable $articles as xs:anyURI external;
declare variable $subscriptions as xs:anyURI external;
declare variable $months := ('睦月','如月','弥生','卯月','皐月','水無月','文月','葉月','長月','神無月','霜月','師走');
declare function local:jpDate($date as xs:date) as element()*
{
    element {"span"}{attribute{"class"}{"month"},$months[month-from-date($date)]},
    element {"span"}{attribute{"class"}{"day"},day-from-date($date),"日"}
};

<html> 
  <head>
    <meta charset="utf-8" />
    <title>Planet Qt Japan</title>
    <link rel="stylesheet" type="text/css" href="normalize.css" />
    <link rel="stylesheet" type="text/css" href="style.css" />
  </head>
  <body>
  <header class="top-line">
    <div class="wrapper">
      <img src="./logo.gif" width="63" height="77" alt="logo" />
      <h1><a href="./">Planet Qt Japan</a></h1>
      <nav>
        <ul>
          <li><a href="http://qt-users.jp/index.html">HOME</a></li>
          <li><a href="http://qt-users.jp/download.html">ダウンロード</a></li>
          <li><a href="http://qt-users.jp/features.html">Qtの特徴</a></li>
          <li><a href="http://qt-users.jp/community.html">日本Qtユーザー会とは</a></li>
          <li><a href="http://workshop.qt-users.jp">勉強会</a></li>
          <li><a href="http://qt-users.jp/contact.html">お問い合わせ</a></li>
        </ul>
      </nav>
      <div class="clearfix"><!-- style hack --></div>
    </div>
  </header>
  <div class="contents">
    <div class="clearfix"><!-- style hack --></div>
    <div class="articles">
      {
          for $i in doc($articles)/articles/pubdate
          return element {"section"}
                 {
                     attribute {"class"}{"date"},
                     element {"h2"} 
                     {
                         element {"time"}
                         {
                             attribute{"datetime"}{string($i/@date)},
                             local:jpDate($i/@date)
                         }
                     },
                     for $j in $i/article
                     return element {"article"}
                            {
                                element {"h3"}
                                {
                                    attribute{"class"}{"title"},
                                    element{"a"}
                                    {
                                        attribute{"href"}{$j/link/text()},
                                        $j/subject/text()
                                    }
                                },
                                element {"h4"}
                                {
                                    attribute{"class"}{"info"},
                                    "by ", $j/author/text() , 
                                    "(",  
                                        element{"a"}
                                        {attribute{"href"}{$j/url/text()}, $j/title/text()},
                                    ")"
                                },
                                element {"div"}
                                {
                                    attribute{"class"}{"content"},
                                    $j/contents/string()
                                }
                            }
                 }
      }
    </div>
    <aside class="about">
      <h4>About Planet</h4>
      <p>Planet Qtは、Qtに関するブログ記事の集約サイトです。このページに掲載される各記事の見解は、各執筆者のものとなります。</p>
      <h4>参加方法</h4>
      <p>Planet Qt Japanは、日本語によるQtのブログをお持ちの方でRSSを配信している方、あるいは複数の話題をお持ちでも、Qtに関する記事のみのRSSを配信可能な方であれば、どなたでもご参加いただけます。</p>
      <p>参加をご希望の方は、<a href="mailtoa:administrator@qt-users.jp">Qt Users管理者</a>にメールいただくか、<a href="http://qt-users.jp/mailman/listinfo/qt-users">メーリングリスト</a>にてご連絡下さい。</p>
      <h4>参加者</h4>
      <ul>
        {
            for $i in doc($subscriptions)/aggregate/channel
            return element {"li"}
                   {
                       element {"a"}
                       {
                           attribute{"class"}{"xmlbutton"},
                           attribute{"href"}{$i/feed/text()},
                           element{"img"}
                           {
                               attribute{"src"}{"./icon-rss.png"},
                               attribute{"title"}{"Feed source"},
                               attribute{"alt"}{"Feed source"}
                           }
                       },
                       element {"a"}
                       {
                           attribute{"href"}{$i/link/text()},
                           $i/title/text()
                       }
                   }
        }
      </ul>
    </aside>
    <div class="clearfix"><!-- style hack --></div>
  </div>
  <footer class="bottom-line">
    <p>&amp;copy; 2011-2013 Japan Qt User's Group Hosting. Qt<sup>&amp;reg;</sup> and the Qt logo is a registered trade mark of Digia plc and/or its subsidiaries and is used pursuant to a license from Digia plc and/or its subsidiaries.</p>
  </footer>
  </body>
</html>
