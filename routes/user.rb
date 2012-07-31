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

class ItemboardApp < Sinatra::Base
  set :methodoverride, true

  def self.put_or_post(*a, &b)
    put *a, &b
    post *a, &b
  end

  ## helpers
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


end