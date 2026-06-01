require_relative '../lib/playing_card'

class CardDeck
  attr_reader :cards_left, :cards, :FULL_COUNT
  FULL_COUNT = 52

  def initialize

    @cards = PlayingCard::SUITS.flat_map do |suit|
      PlayingCard::RANKS.map do |rank|
        PlayingCard.new(rank, suit)
      end
    end
  end

  def deal
    @cards.pop
  end

  def cards_left
    @cards.length
  end

  def shuffle
    shuffled = @cards.dup
    shuffled.shuffle! until shuffled != @cards
    @cards = shuffled
  end

end