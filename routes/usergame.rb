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

  ## GET /board/:id - create a new game by cloning a board template
  get "/usergame/new/:userid/:boardtempid/:piecesetid", :provides => :json do
    content_type :json

    # check that :id param is an integer
    if Board.valid_id?(params[:id])
      if board = Board.first(:id => params[:id].to_i)
        board.to_json
      else
        json_status 404, "Board Not found"
      end
    else
      # TODO: find better error for this (id not an integer)
      json_status 404, "Invalid ID"
    end
  end

end
