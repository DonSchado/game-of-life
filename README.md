# Conway's Game of Life

This is a variation of the Game of Life, implemented with Ruby on Rails, where each generation is requested via AJAX and gets entirely computed and rendered server-side so that the browser only needs to replace the grid in the DOM. On top I sprinkled some *Stimulus.js* to add just enough behavior to make it shine. If you look very closely you will also see *Turbolinks* in action. Oh... and by the way: the Asset Pipeline was exchanged for a complete Webpack setup, so no Sprockets have been harmed in delivering JavaScript and Stylesheets.

[Read more](https://game-of-life-turbo.herokuapp.com)

## Setup the application

1. Clone this repo with `git clone git@github.com:DonSchado/game-of-life.git`
2. Run `bundle install`
3. Run `yarn install`
4. Create a database with `rails db:setup`
5. Run the rails server `rails s -p 9000` (because it will be so turbo)
5. Navigate your browser to `localhost:9000`

_Since this is not a setup tutorial and for some reason something does "not work",
please refer to the amazingly detailed [rails guides](https://guides.rubyonrails.org/development_dependencies_install.html)._


## Some notes on what I did (the webpack way):

I created a fresh project with: 
```
rails _5.2.1.rc1_ new turbo-game-of-life --webpack=stimulus -JSCT -d sqlite3
```

_(For the heroku deployment I switched to postgresql, but at the moment the app does not need a database...)_

`-JSCT` expands to:
* --skip-javascript
* --skip-sprockets 
* --skip-action-cable (for no reason I kept action-mailer and active-storage...)
* --skip-test (:scream:)


This brought me in the position to start moving away from the asset pipeline and go all-in webpack:

```ruby
# config/application.rb
# if you use rails generators set:
config.generators.assets = false
```

And then `rm -rf app/assets` :wave:.

I renamed the webpack folder from ambiguous _javascript_ to _webpack_ `mv app/javascript app/webpack`, but the folder structure is totally up to you (but this requires to change the `source_path` in _webpacker.yml_ to `app/webpack`). 

Remove the line with `stylesheet_link_tag` in app/views/layouts/application.html.erb

```erb
<%= stylesheet_pack_tag 'stylesheets', 'data-turbolinks-track': 'reload' %>
<%= javascript_pack_tag 'application', 'data-turbolinks-track': 'reload', defer: true %>
```

The `webpack/packs/stylesheets.scss` just imports bootstrap

```scss
@import '../src/stylesheets/variables';
@import '../src/stylesheets/bootstrap';
```

add `src/bootstrap.scss`
```scss
@import '~bootstrap/scss/bootstrap';
```

Then edit the Gemfile to add the turbolinks gem for having "javascript redirect support" in the controller:

```ruby
gem 'turbolinks', '~> 5'
```

And since there is no asset pipeline anymore I need to add rails-ujs etc to the package.json:
```
yarn add rails-ujs turbolinks bootstrap
```

In `packs/application.js` I replaced `console.log('Hello World from Webpacker')` with:

```js
import Rails from 'rails-ujs';
import Turbolinks from 'turbolinks';
import { Application } from "stimulus"
import { definitionsFromContext } from "stimulus/webpack-helpers"
```

start all the things!

```js
Rails.start();
Turbolinks.start();
Turbolinks.setProgressBarDelay(50)

const application = Application.start()
const context = require.context("../src/javascript/controllers", true, /.js$/)
application.load(definitionsFromContext(context))
```

Now start the webpack dev server `./bin/webpack-dev-server`
=> webpack compiles successfully

:tada:


I hope that's clear. 
If you have any questions, don't hesistate to ask.

Until then, have a nice day! :)
