# Wired

About
---
This gem is for internal use and heavily based on (you might even say mostly copy-pasted from) Suspenders, if you found this gem you will probably want to check them out: [Suspenders by Thoughtbot](http://github.com/thoughtbot/suspenders).

Requirements
---
* [Heroku toolbelt](https://toolbelt.heroku.com)
* [Hub](https://github.com/defunkt/hub)

Installation
---
`gem install wired`

Usage
---
`wired APP_NAME --generator GENERATOR_NAME`

Params additional to the default rails generator params are:

* --generator GENERATOR _uses the specified generator, can be: [facebook]_
* --with-heroku _Adds the creation of the Heroku apps_
* --with-github _Adds the creation of a Github repository_

For a complete list of options check `wired --help`.
