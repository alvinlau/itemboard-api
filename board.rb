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

require_relative 'models.rb'

## logger
def logger
  @logger ||= Logger.new(STDOUT)
end

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

  ## GET /board/:id - return board with specified id
  get "/board/:id", :provides => :json do
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

  ## PUT /board/:id - place a piece on the board
  put "/board/:id/:userid/:pieceid/:x/:y", :provides => :json do
    content_type :json

    #new_params = accept_params(params, :name, :status)

    if Board.valid_id?(params[:id])
      if board = Board.first(:id => params[:id].to_i)
        userid = params[:userid]
        pieceid = params[:pieceid]
        x = params[:x]
        y = params[:y]

        cells = board.attributes.cells
        edit_cell(cells, x, y, pieceid)
        #board.attributes = board.attributes.merge(new_cells)
        if board.save
          board.to_json
        else
          json_status 400, board.errors.to_hash
        end
      else
        json_status 404, "Not found"
      end
    else
      json_status 404, "Not found"
    end
  end

  #sanity check for the cellstring
  def valid_cells?(cellstring)
    is_valid = cellstring.split(',').size == 36
    return is_valid
  end

  def edit_cell(cellstring, x, y, pieceid)
    cellarray = cellstring.split(',')
    cellarray[x+(y-1)*6] = pieceid
    cellstring = cellarray.join(',')
  end


  # misc handlers: error, not_found, etc.
  get "*" do
    puts "test"
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
