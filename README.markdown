SimplisticNotes
===============

A small Sinatra application that implements the [Simplenote][simplenote] API.

[simplenote]: http://simplenoteapp.com/

SimpliticNotes was written to allow development of an iOS Simplenote client
without Internet access on my train commute to and from work.

Installation
------------

You will need a couple of RubyGems to run SimplisticNotes:

* sinatra
* json

To run the tests you will also need:

* rake
* rack-test

These can be installed as follows:

    gem install sinatra json

Running
-------

To start the SimplisticNotes server, run the following:

    rackup config.ru

The server will now be running on `localhost:9292` and should respond as per the
Simplenote API documentation. There is only one user account. It's details are:

    email    : test@example.com
    password : Simplenote

Status
------

SimplisticNotes is not yet complete in its implementation of the Simplenote
API. More complete support will come as my iOS client develops.

Running the Tests
-----------------

SimplisticNotes includes a small test suite. This can be run using the test
rake task:

    rake test

The test suite has been tested on the following platforms:

* Mac OS X 10.6 Ruby MRI 1.9.1
