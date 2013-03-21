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
  property :meta, String
  #property :last_modified, DateTime
  belongs_to :user, :child_key => [:modified_by]
  belongs_to :board_template, :child_key => [:template_id]
end

### BoardTemplate
class BoardTemplate
  include DataMapper::Resource
  include StandardProperties
  extend Validations

  property :name, String
  property :cells, String
  belongs_to :board_set, :child_key => [:set_id]
end

### BoardSet
class BoardSet
  include DataMapper::Resource
  include StandardProperties
  extend Validations

  property :name, String
  property :desc, String
  property :reqs, String
  has n, :board_templates
end

### User
class User
  include DataMapper::Resource
  include StandardProperties
  extend Validations

  property :name, String
  property :exp, Integer
  has n, :user_games
end

### UserGame
class UserGame
  include DataMapper::Resource
  include StandardProperties
  extend Validations

  belongs_to :user, :child_key => [:user_id]
  belongs_to :board, :child_key => [:board_id]
  belongs_to :piece_set, :child_key => [:piece_set_id]
  belongs_to :piece, :child_key => [:next_piece_id]
end

### Piece
class Piece
  include DataMapper::Resource
  include StandardProperties
  extend Validations

  property :name, String
  property :icon_id, Integer
  belongs_to :piece_set, :child_key => [:set_id]
  belongs_to :rule, :child_key => [:rule_id]
end

### PieceSet
class PieceSet
  include DataMapper::Resource
  include StandardProperties
  extend Validations

  property :name, String
  has n, :pieces
end

### Rule
class Rule
  include DataMapper::Resource
  include StandardProperties
  extend Validations

end


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
  DataMapper.setup(:default, "mysql://itemboard:password@localhost/itemboard")
else
  DataMapper.setup(:default, "sqlite3:#{ENV["RACK_ENV"]}.db")
end

## create schema if necessary
DataMapper.auto_upgrade!
