## requires
require 'sinatra'
require 'json'
require 'time'
require 'pp'

### datamapper requires
require 'datamapper'
require 'dm-types'
require 'dm-timestamps'
require 'dm-validations'


## logger
def logger
  @logger ||= Logger.new(STDOUT)
end

require_relative 'models.rb'
require_relative 'helpers.rb'


require_relative 'board.rb'
require_relative 'things.rb'