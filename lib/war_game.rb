require_relative '../lib/war_player'
require_relative '../lib/card_deck'
require_relative '../lib/playing_card'

class WarGame

  attr_reader :player1, :player2, :deck, :winner
  
  def initialize()
    @winner = nil
    @player1 = WarPlayer.new("Bob")
    @player2 = WarPlayer.new("Tom")
    @deck = CardDeck.new()
  end

  def start()
    @deck.shuffle
    deal_cards()
  end

  def play_round(pot_cards = nil)

    card1 = player1.hand.pop
    card2 = player2.hand.pop

    #TODO ask for advice on magic name
    #rw = Round Winner
    rw = nil

    result = card1.value <=> card2.value
    round_cards = [pot_cards, card1, card2]

    if result == 0
      return play_round(round_cards)
    else
      result == 1 ? rw = @player1 : rw = @player2
      rw.hand = ([round_cards].shuffle) + rw.hand
    end
  end

  def deal_cards()
    mid = CardDeck::FULL_COUNT
    @player1.hand = @deck.cards[0...(mid / 2 )]
    @player2.hand = @deck.cards[(mid / 2 )..-1]
  end

end