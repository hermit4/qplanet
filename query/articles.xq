(:: extract articles from agregated data ::)
declare variable $aggregated as xs:anyURI external; 
declare variable $numOfWanted as xs:integer := 30;

declare function 
local:extractPubDates($src as element()*) as xs:date*
{
    for $i in $src/pubdate
    let $date := xs:date(xs:dateTime($i))
    order by $date descending
    return $date
};

declare function
local:extractArticles($src as element()*, $targetDate as xs:date*) as element()
{
    element {"articles"}
    {
        for $date in $targetDate
        return element {"pubdate"}
               {
                   attribute {"date"}{$date},
                   for $i in $src
                   let $dt := xs:dateTime($i/pubdate)
                   where xs:date($dt) = $date
                   order by $dt
                   return element {"article"}
                          {
                              $i/../title,
                              element{"url"}{$i/../link/text()},
                              $i/../feed,
                              $i/../author,
                              $i/*
                          }
               }
    }
};

let $items := doc($aggregated)/aggregate/channel/item
let $targetDates := distinct-values(
                        local:extractPubDates($items)[position() <= $numOfWanted])
return local:extractArticles($items, $targetDates)

