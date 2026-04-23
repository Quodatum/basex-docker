(: maven download :)
import module namespace build = 'urn:quodatum:build:1' at "build.xqm";
declare variable $base:=file:parent(static-base-uri());
declare variable $custom:="/srv/basex/lib/custom/";

let $maven:=file:resolve-path("maven.txt",$base)
let $gradles:=build:maven-lines($maven)
return build:maven-download($gradles,$custom)