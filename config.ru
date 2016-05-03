require './lib/racker'
require 'bundler'
Bundler.require

use Rack::Static, urls: ['/stylesheets', '/javascripts'], root: 'public'

use Rack::Session::Cookie,  key: 'rack.session',
                            path: '/',
                            expire_after: 2592000,
                            secret: 'codebreaker_rack'
run Racker
