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

  ## GET /usergame/new/:userid/:boardtempid/:piecesetid
  ## create a new game by cloning a board template
  get "/usergame/new/:userid/:boardtempid/:piecesetid", :provides => :json do
    content_type :json

    # get the board template
    if BoardTemplate.valid_id?(params[:boardtempid])
      if boardtemp = BoardTemplate.first(:id => params[:boardtempid].to_i)
        # clone the board template into new board
        board = Board.new
        board.template_id = params[:boardtempid]
        unless board.save
          json_status 400, board.errors.to_hash
        end

        # create usergame record
        usergame = UserGame.new
        usergame.board_id = board[:id]
        unless usergame.save
          json_status 400, usergame.errors.to_hash
        end

        #response object
        usergame.to_json
      else
        json_status 404, "Board template not found"
      end
    else
      # TODO: find better error for this (id not an integer)
      json_status 404, "Invalid board template id"
    end
  end

  ## GET /usergame/:userid
  ## get a user's list of games
  get "/usergame/:userid", :provides => :json do
    content_type :json

    if User.valid_id?(params[:userid])
      if usergames = UserGame.all(:user_id => params[:userid])
        usergames.to_json
      else
        json_status 204, "User has no games"
      end
    else
      json_status 404, "Invalid user id"
    end

  end  

end
