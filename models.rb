## model
### helper modules
#### StandardProperties
module StandardProperties
  def self.included(other)
    other.class_eval do
      property :id, other::Serial
      # property :created_at, DateTime
      # property :updated_at, DateTime
    end
  end
end

#### Validations
module Validations
  def valid_id?(id)
    id && id.to_s =~ /^\d+$/
  end
end

### Thing
class Thing
  include DataMapper::Resource
  include StandardProperties
  extend Validations

  property :name, String, :required => true
  property :status, String
end

### Board
class Board
  include DataMapper::Resource
  include StandardProperties
  extend Validations

  property :name, String
  property :tags, String
  property :cells, String
  property :status, String, :required => true
  #property :last_modified, DateTime
  belongs_to :user, :child_key => [:modified_by]
end

### User
class User
  include DataMapper::Resource
  include StandardProperties
  extend Validations

  property :name, String
  property :exp, Integer
end

### UserGame
class UserGame
  include DataMapper::Resource
  include StandardProperties
  extend Validations

end

### Piece
class Piece

end


### PieceSet

### BoardSet

### BoardTemplate


## set up db
env = ENV["RACK_ENV"]
puts "RACK_ENV: #{env}"
if env.to_s.strip == ""
  abort "Must define RACK_ENV (used for db name)"
end

case env
when "test"
  DataMapper.setup(:default, "sqlite3::memory:")
when "development"
  DataMapper.setup(:default, "mysql://itemboard:unos1pw@localhost/itemboard")
else
  DataMapper.setup(:default, "sqlite3:#{ENV["RACK_ENV"]}.db")
end

## create schema if necessary
DataMapper.auto_upgrade!