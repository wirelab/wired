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
`wired app_name`

Params additional to the default rails generator params are:

* -SH (--skip-heroku) _Skips the creation of the Heroku apps_
* -SG (--skip-github) _Skips the creation of a Github repository_

For a complete list of options check `wired --help`.
