require_relative '../lib/playing_card'

class CardDeck
  attr_reader :cards_left

  def initialize

    @cards = PlayingCard::SUITS.flat_map do |suit|
      PlayingCard::RANKS.map do |rank|
        PlayingCard.new(rank, suit)
      end
    end
  end

  def deal
    @cards.shift
  end

  def cards_left
    @cards.length
  end
end
