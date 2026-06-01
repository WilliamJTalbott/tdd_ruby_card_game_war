class WarPlayer
  attr_accessor :name, :hand

  class InvalidName < StandardError; end

  def initialize(name)
    raise InvalidName unless name.is_a?(String)

    @name = name
    @hand = []
  end

end