require './app'
require 'rack/coffee'

use Rack::Coffee

run Datascope

