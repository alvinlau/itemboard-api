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
require_relative 'routes/things.rb'
require_relative 'routes/board.rb'
require_relative 'routes/user.rb'
require_relative 'routes/usergame.rb'

class ItemboardApp < Sinatra::Base
  set :methodoverride, true

  ## helpers

  def self.put_or_post(*a, &b)
    put *a, &b
    post *a, &b
  end

  helpers do
    def json_status(code, reason)
      status code
      {
        :status => code,
        :reason => reason
      }.to_json
    end

    def accept_params(params, *fields)
      h = { }
      fields.each do |name|
        h[name] = params[name] if params[name]
      end
      h
    end
  end

  # misc handlers: error, not_found, etc.
  get "*" do
    status 404
  end

  put_or_post "*" do
    status 404
  end

  delete "*" do
    status 404
  end

  not_found do
    json_status 404, "Not found"
  end

  error do
    json_status 500, env['sinatra.error'].message
  end
end

