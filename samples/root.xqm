module namespace _ = 'urn:quodatum:test';
declare %rest:GET %rest:path('') %output:method('text')
function _:root(){
"Hello, I'm a new text only front page"
};