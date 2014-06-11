<?php echo '<?xml version="1.0" encoding="UTF-8"?>'; ?>
<html xmlns="http://www.w3.org/1999/xhtml">
    <body style="font-family: sans-serif; font-size: 75%;">
<?php
foreach ( array( 'xforms', 'xsltforms' ) as $dir ) {
    echo "<a name=\"$dir\"><h2>$dir</h2></a>\n";
    if ($dir != 'xsltforms') {
?>
        <p>
            To execute the forms below, you will need
            an XForms-capable browser, e.g.,
            <a href="http://www.x-smiles.org/">X-Smiles</a>,
            <br />
            or a suitable browser plugin, e.g.,
            <a href="https://addons.mozilla.org/en-US/firefox/addon/824">the XForms extension for Firefox 2.x and 3.x</a>
            or <a href="http://www.formsplayer.com/">formsPlayer for Internet Explorer</a>.
            <br />
            See also <a href="http://www.xml.com/pub/a/2003/09/10/xforms.html">Ten Favorite XForms Engines</a>
            and <a href="http://en.wikipedia.org/wiki/Xforms#Software_support">XForms Software Support</a>.
        </p>
<?php
    } else {
?>
        <p>
            The forms below make use of the
            <a href="http://www.agencexml.com/xsltforms">XSLTForms project</a>,
            which enables browsers with XSLT 1.0 support
            to convert XForms to XHTML+Javascript.
        </p>
<?php
    }
    $files = new ArrayObject();
    foreach (new RecursiveIteratorIterator(new RecursiveDirectoryIterator($dir)) as $entry) {
        if ($entry->isFile() and substr($entry, -6) == '.xhtml') {
            $files->append( $entry->getFileInfo() );
        }
    }

    // sort list of files ascending
    $sortBy = 'Path';
    $sortFunction = create_function('$a, $b', 'return strcmp( $a->get' . $sortBy . '(), $b->get' . $sortBy . '());');
    $files->uasort( $sortFunction );

    // iterate through files
    $iterator = $files->getIterator();
    while ($iterator->valid()) {
        $entry = $iterator->current();
        $relativeUrl = substr( $entry->getRealPath(), strlen( realpath( dirname( __FILE__ ) ) ) + 1 );
        $linkName = substr( $entry->getRealPath(), strlen( realpath( $dir ) ) + 1 );
        echo "<a href=\"$relativeUrl\">$linkName</a>\n";
        if ($dir == 'xforms') {
            echo "(<a href=\"/orbeon/xforms-jsp/wsdl2xforms/$linkName\">run in Orbeon</a>)\n";
        }
        echo "<br />\n";
        $iterator->next();
    }
}
?>
    </body>
<html>
