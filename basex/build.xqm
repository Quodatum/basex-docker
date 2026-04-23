(:~ build utils for REPO packaging 

:)
module namespace build = 'urn:quodatum:build:1';
declare namespace bxpkg='http://www.basex.org/modules/pkg';
declare namespace pkg='http://expath.org/ns/pkg';

(:~ jar compress options :)
declare variable $build:archive-opts:= map { "format" : "zip", "algorithm" : "deflate" };

declare variable $build:base:= file:resolve-path("../",static-base-uri())=>trace("base ");

(:~ load "npm style" package.json :)
declare variable $build:PKG:=json:doc(file:resolve-path("package.json",$build:base),map{"format":"xquery"});

(:~ return binary for fat jar from jars in $input-dir 
keeping only META-INF from $manifest-jar 
:)
declare function build:fatjar-from-folder($input-dir as xs:string,$manifest-jar as xs:string)
as xs:base64Binary { 
    let $fold :=
function ($res as map (*), $jar as xs:string) { 
    let $bin :=file:read-binary($input-dir || $jar),
        $paths := archive:entries($bin)/string()
        [$jar eq $manifest-jar or not(starts-with( .,"META-INF/"))]
    return
        map { "name" : ($res? name, $paths), 
              "content" : ($res? content,archive:extract-binary($bin, $paths)) } 
}
let $res := file:list($input-dir, false(), "*.jar")
            =>fold-left( map { }, $fold)
return archive:create($res? name, $res? content,$build:archive-opts) 
};

(:~ create a fat jar with lib 
@remark 
:)
declare function build:fatjar-with-lib($input-dir as xs:string,$manifest-jar as xs:string)
 as xs:base64Binary{ 
 let $bin :=file:read-binary($input-dir || $manifest-jar)
  
 let $lib:=file:list($input-dir || "lib/", false(), "*.jar")!concat("lib/",.)
 let $name:= (archive:entries($bin)/string()
              ,$lib)
 let  $content:=(archive:extract-binary($bin,$name)
                ,$lib!file:read-binary($input-dir || .))
return  archive:create($name, $content,$build:archive-opts)
};

(:~ update-manifest :)
declare function build:update-manifest($jar  as xs:base64Binary,$main-class as xs:string)
as xs:base64Binary{
(: let $mf:=archive:extract-text($jar,"META-INF/MANIFEST.MF") :)

let $mf2:=concat("Manifest-Version: 1.0&#xD;&#xA;Main-Class: ",
                 $main-class,
                 "&#xD;&#xA;&#xD;&#xA;")
return archive:update($jar,"META-INF/MANIFEST.MF",$mf2)
};

(:~ update-manifest :)
declare function build:update($jar as xs:base64Binary,$name  as xs:string,$file as xs:string)
as xs:base64Binary{
archive:update($jar,$name,$file)
}; 

(:~ build basex.xml from package.json :)
declare function build:basex.xml()
as xs:string{
``[<package xmlns="http://www.basex.org/modules/pkg">
  `{  build:jars("name")!concat('<jar>',.,'</jar>') }`
   <class>`{ $build:PKG?expkg_zone58?main-class }`</class>
</package>
]``
 
};

(:~  expath-pkg.xml using package.json :)
declare function build:expath-pkg.xml()
as xs:string{
 ``[<package xmlns="http://expath.org/ns/pkg"
         name="`{$build:PKG?expkg_zone58?namespace}`"
         abbrev="`{$build:PKG?name}`"
         version="`{$build:PKG?version}`"
         spec="1.0">
   <title>`{$build:PKG?description}`</title>
   <dependency processor="basex" name="value"/>
   <xquery> 
     <namespace>`{$build:PKG?expkg_zone58?namespace}`</namespace>
     <file>`{$build:PKG?main=>replace("^.*/","")}`</file>
   </xquery>
</package>
 ]``

};

declare function build:xar-create()
as xs:base64Binary{
  let $_:=build:maven-download($build:PKG?expkg_zone58?maven2=>array:flatten(),$build:base || "jars/")
  let $entries:=
            build:xar-add(map{},build:jars("content"),build:jars("download")!build:content(.))
            =>build:xar-add("content/Pdfbox3.xqm",build:content("src/Pdfbox3.xqm"))
            =>build:xar-add("expath-pkg.xml",convert:string-to-base64(build:expath-pkg.xml()))
            =>build:xar-add("basex.xml",convert:string-to-base64(build:basex.xml()))
  return  archive:create($entries?name, $entries?content,$build:archive-opts)      
};

(:~ content as base64Binary of $path :)
declare function build:content($path as xs:string) 
as xs:base64Binary{
file:resolve-path($path,$build:base)=>file:read-binary()
};

(:~ add (name,content) pairs to archive data :)
declare function build:xar-add($map as map(*),$xar-path as xs:string*,$content as item()*)
as map(*){
  map{"name": ($map?name,$xar-path), "content": ($map?content,$content)}
}; 

(:~ path to created xar file :)
declare function build:xar-path()
as xs:string{
  let $a:=``[dist/pdfbox-`{$build:PKG?version}`.xar]``
  return  file:resolve-path($a,$build:base)
}; 

declare function build:jars($style as xs:string)
as xs:string*{
let $artifacts:=$build:PKG?expkg_zone58?maven2=>array:flatten()
let $names:= $artifacts!build:maven-slug(.)!file:name(.)
return switch($style)
case "name" return $names
case "download" return $names!concat("jars/",.)
case "content" return $names!concat("content/",.)
default return $names
};

(:~ download $files from $urls to  $destdir:)
declare variable $build:REPO as xs:string external :="https://repo1.maven.org/maven2/";

declare function build:maven-download($artifacts as xs:string*,$destdir as xs:string)
as empty-sequence(){
    file:create-dir($destdir),    
    for $id in $artifacts
    let $slug:=build:maven-slug($id)
    let $dest:=$destdir || file:name($slug) 
    where not(file:exists($dest))
    return build:write-binary($dest, fetch:binary(resolve-uri($slug,$build:REPO)
           =>trace("Download: ")))
};

(:~ non-rooted url for maven artifact :)
declare function build:maven-slug($artifact as xs:string)
as xs:string{
   
   let $parts:=if(matches($artifact,'[^:]+:[^:]+:[^:]+'))
               then tokenize($artifact,":")
               else error(xs:QName('build:maven-slug'),"invalid format required 'groupId:id:version'")
  
    return (
            translate($parts[1],".","/"),
            $parts[2],
            $parts[3],
            string-join(($parts[2] , "-" , $parts[3] ,
            if(3<count($parts)) then "-" || $parts[4] else (), (: classifier :)
             ".jar"),"")
    )=>string-join("/")
};

(:~ write-binary, creating dir if required :)
declare function build:write-binary($dest as xs:string,$contents as xs:base64Binary?)
as empty-sequence(){
file:create-dir(file:parent($dest)),
file:write-binary($dest,$contents)
};

(:~ extract gradle style requirements from $filepath
 non-blank lines before # from $file 
 :)
declare function build:maven-lines($filepath as xs:string) as xs:string*
{
unparsed-text-lines($filepath)
!substring-before(.||"#","#")
!normalize-space(.)[0<string-length(.)]
};