## Thing
# RESTful API example
# - manages single resource called Thing /thing
# - all results (including error messages) returned as JSON (Accept header)

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
require_relative 'helpers.rb'

## The Application
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

  ## GET /thing - return all things
  get "/thing/?", :provides => :json do
    content_type :json

    if things = Thing.all
      things.to_json
    else
      json_status 404, "Not found"
    end
  end

  ## GET /thing/:id - return thing with specified id
  get "/thing/:id", :provides => :json do
    content_type :json

    # check that :id param is an integer
    if Thing.valid_id?(params[:id])
      if thing = Thing.first(:id => params[:id].to_i)
        thing.to_json
      else
        json_status 404, "Not found"
      end
    else
      # TODO: find better error for this (id not an integer)
      json_status 404, "Not found"
    end
  end

  ## POST /thing/ - create new thing
  post "/thing/?", :provides => :json do
    content_type :json

    new_params = accept_params(params, :name, :status)
    thing = Thing.new(new_params)
    if thing.save
      headers["Location"] = "/thing/#{thing.id}"
      # http://www.w3.org/Protocols/rfc2616/rfc2616-sec9.html#sec9.5
      status 201 # Created
      thing.to_json
    else
      json_status 400, thing.errors.to_hash
    end
  end

  ## PUT /thing/:id/:status - change a thing's status
  put_or_post "/thing/:id/status/:status", :provides => :json do
    content_type :json

    if Thing.valid_id?(params[:id])
      if thing = Thing.first(:id => params[:id].to_i)
        thing.status = params[:status]
        if thing.save
          thing.to_json
        else
          json_status 400, thing.errors.to_hash
        end
      else
        json_status 404, "Not found"
      end
    else
      json_status 404, "Not found"
    end
  end

  ## PUT /thing/:id - change or create a thing
  put "/thing/:id", :provides => :json do
    content_type :json

    new_params = accept_params(params, :name, :status)

    if Thing.valid_id?(params[:id])
      if thing = Thing.first_or_create(:id => params[:id].to_i)
        thing.attributes = thing.attributes.merge(new_params)
        if thing.save
          thing.to_json
        else
          json_status 400, thing.errors.to_hash
        end
      else
        json_status 404, "Not found"
      end
    else
      json_status 404, "Not found"
    end
  end

  ## DELETE /thing/:id - delete a specific thing
  delete "/thing/:id/?", :provides => :json do
    content_type :json

    if thing = Thing.first(:id => params[:id].to_i)
      thing.destroy!
      # http://www.w3.org/Protocols/rfc2616/rfc2616-sec9.html#sec9.7
      status 204 # No content
    else
      # http://www.w3.org/Protocols/rfc2616/rfc2616-sec9.html#sec9.1.2
      # Note: section 9.1.2 states:
      #   Methods can also have the property of "idempotence" in that
      #   (aside from error or expiration issues) the side-effects of
      #   N > 0 identical requests is the same as for a single
      #   request.
      # i.e that the /side-effects/ are idempotent, not that the
      # result of the /request/ is idempotent, so I think it's correct
      # to return a 404 here.
      json_status 404, "Not found"
    end
  end
end