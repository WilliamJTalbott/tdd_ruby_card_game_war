class WarPlayer
  attr_accessor :name, :hand

  class InvalidName < StandardError; end

  def initialize(name)
    raise InvalidName unless name.is_a?(String)

    @name = name
    @hand = []
  end

  def play_card()
    hand.pop
  end

  def win_cards(cards)
    @hand = (cards.shuffle) + hand
  end

end