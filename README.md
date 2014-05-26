LDAP Password Update Webapp
===========================

For users for self maintenance of their LDAP password record. This can be done
from the browser at any place where you have access to this app. No need to move
your physical body to the sysad, welcome to the '90ties!


Development
-----------

    bundle install
    cp config.yml.example config.yml
    edit config.yml
    foreman start
    open http://localhost:5000

Production deploy
-----------------

    to be defined


Testing
-------

Project is prepped with a travis.yml script for continous testing on github. 

For TDD style it contains a Guardfile. Start with:

  $ bundle exec guard


Meta
----

Created by Dirk Lüsebrink/art+com AG
Released under the MIT License: http://www.opensource.org/licenses/mit-license.php
