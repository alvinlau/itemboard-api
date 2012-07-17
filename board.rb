## BoardResource
class BoardResource < Sinatra::Base
  set :methodoverride, true

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
    if board.valid_id?(params[:id])
      if board = board.first(:id => params[:id].to_i)
        board.to_json
      else
        json_status 404, "Not found"
      end
    else
      # TODO: find better error for this (id not an integer)
      json_status 404, "Not found"
    end
  end

  ## PUT /board/:id - change or create a board
  put "/board/:id", :provides => :json do
    content_type :json

    new_params = accept_params(params, :name, :status)

    if board.valid_id?(params[:id])
      if board = board.first_or_create(:id => params[:id].to_i)
        userid = params[:userid]
        pieceid = params[:pieceid]
        xy = params[:xy]

        board.attributes = board.attributes.merge(new_params)
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

end
