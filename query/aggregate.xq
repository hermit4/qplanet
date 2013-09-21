declare namespace content="http://purl.org/rss/1.0/modules/content/";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace rss="http://purl.org/rss/1.0/";
declare namespace dc="http://purl.org/dc/elements/1.1/";
declare namespace atom="http://www.w3.org/2005/Atom";
declare variable $months := ('jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec');

declare function local:toISODate($origdate as xs:string) as xs:string
{
    let $dateTokens := tokenize($origdate,' ')
    let $month := string(index-of($months,lower-case($dateTokens[3])))
    let $date  := concat($dateTokens[4],'-',
                         if (string-length($month)=1) then concat('0',$month) else $month,
                         '-',$dateTokens[2])
    let $time  := string($dateTokens[5])
    let $zone  := normalize-space($dateTokens[6])
    let $zone  := if ($zone = 'GMT') then
                      'Z' 
                  else if (matches($zone, "[0-9]{4}")) then
                      concat(substring($zone,1,3),":",substring($zone,4,2))
                  else 
                      string($zone)
    return string(concat($date,'T',$time, $zone))
};

declare function local:convDate($date as xs:string) as xs:dateTime
{
    if (matches($date, "[0-9]{4}-[0-9]{2}-[0-9]{2}")) then
        adjust-dateTime-to-timezone(xs:dateTime($date), xs:dayTimeDuration("PT9H"))
    else
        adjust-dateTime-to-timezone(xs:dateTime(local:toISODate($date)), xs:dayTimeDuration("PT9H"))
};

declare function local:convertRss10($doc) as element(channel)
{
    element {"channel"}
    {
        element {"title"}{data($doc/rdf:RDF/rss:channel/rss:title)},
        element {"link"}{data($doc/rdf:RDF/rss:channel/rss:link)},
        for $i in $doc/rdf:RDF/rss:item
        return element {"item"}
               {
                   element {"subject"}{data($i/rss:title)},
                   element {"pubdate"}{local:convDate(data($i/dc:date))},
                   element {"link"}{data($i/rss:link)},
                   element {"contents"}
                   {
                       attribute{"type"}{"html"},
                       if (count($i/content:encoded) > 0 ) then
                           data($i/content:encoded)
                       else
                           data($i/rss:description)
                   }
               }
    }
};

declare function local:convertRss20($doc) as element(channel)
{
    element {"channel"}
    {
        element {"title"}{data($doc/rss/channel/title)},
        element {"link"}{data($doc/rss/channel/link)},
        for $i in $doc/rss/channel/item
        return element {"item"}
               {
                   element {"subject"}{data($i/title)},
                   element {"pubdate"}{local:convDate(data($i/pubDate))},
                   element {"link"}{data($i/link)},
                   element {"contents"}
                   {
                       attribute{"type"}{"html"},
                       if (count($i/content:encoded) > 0 ) then
                           data($i/content:encoded)
                       else
                           data($i/description)
                   }
               }
    }
};

declare function local:convertAtom10($doc) as element(channel)
{
    element {"channel"}
    {
        element {"title"}{data($doc/atom:feed/atom:title)},
        element {"link"}{string($doc/atom:feed/atom:link[@rel = 'alternate']/@href)},
        for $i in $doc/atom:feed/atom:entry
        return element {"item"}
               {
                   element{"subject"}{data($i/atom:title)},
                   element {"pubdate"}{local:convDate(data($i/atom:published))},
                   element {"link"}{$i/atom:link[@rel = 'alternate']/@href/string()},
                   element {"contents"}
                   { 
                       attribute{"type"}{"html"},
                       data($i/atom:content) 
                   }
               }
    }
};

declare function local:toPlanet($url as xs:string, $author as xs:string) as element(channel)
{
    let $doc as document-node() := doc($url)
    let $data as element(channel) := 
                 if ( count($doc/atom:feed) > 0 ) then
                     local:convertAtom10($doc)
                 else if ( count($doc/rss) > 0) then
                     local:convertRss20($doc)
                 else
                     local:convertRss10($doc)
    return element {node-name($data)}
                   {
                       element{"feed"}{$url},
                       element{"author"}{$author},
                       $data/*
                   }
};

declare function
local:aggregate() as element()
{
    element {"aggregate"}
    {
        for $i in doc($registrant)/regist/blog
        return if (doc-available(string($i/feed/@href))) then
                   local:toPlanet(string($i/feed/@href), data($i/author))
               else
                   ()
    }
};

let $aggregate as element() := local:aggregate()
return $aggregate
