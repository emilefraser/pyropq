/**
LibPQPath:
    Places where LibPQ will search for modules.

    Local sources have priority over Web sources.
    Local and Web locations must be listed in the priority order: from
    high to lower priority.
**/

[
    Local = {
        /*"C:\ExtractLocation\LibPQ\Modules",
        "D:\ExtractLocation\LibPQ\Modules"*/
        "C:\Users\emile.fraser\Documents\CoreBI\5_Visualization\All PowerQuery(m)\Library\Modules"
    },
    // Change this to 
    // Local, Online, Database
    Web = {
       // "https://raw.githubusercontent.com/sio/LibPQ/master/Modules/",
       // "https://raw.githubusercontent.com/tycho01/pquery/master/"
    }
]