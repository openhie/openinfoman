This testsuite is based on PHPUnit.

To be able run it, install PHP (cli), PEAR, and PHPUnit by following these tutorials:
http://www.php.net/manual/en/install.php
http://pear.php.net/manual/en/installation.getting.php
http://www.phpunit.de/manual/current/en/installation.html

Then simply type 'php WSDL2XFormsTest.php' to execute the test suite.

Hint: To see a colorized version of the differences you can pipe the output of
PHPUnit through colordiff like this 'php WSDL2XFormsTest.php | colordiff'.


At the moment (revision 24) the test suite tests weather the output of
WSDL2XForms remains the same based on simple string comparison
with the SVN base of the working copy.
While this approach helps to detect regression during refactoring more
sophisticated functional tests have to be added in the future, e.g., using
XML diffs or sending the generated instances to the Web Services.
