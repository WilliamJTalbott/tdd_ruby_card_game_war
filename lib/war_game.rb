require_relative '../lib/war_player'
require_relative '../lib/card_deck'
require_relative '../lib/playing_card'

class WarGame

  attr_accessor :winner, :player1, :player2, :deck, :table
  
  def initialize()
    @winner = nil
    @player1 = WarPlayer.new("Bob")
    @player2 = WarPlayer.new("Tom")
    @deck = CardDeck.new()
    @table = []
  end

  def start()
    @deck.shuffle
    deal_cards()
  end

  def play_round()

    card1 = player1.play_card
    card2 = player2.play_card
    round_winner = nil
    round_loser = nil

    result = card1.value <=> card2.value
    round_cards = [*@table, card1, card2]
    prefix = "#{card1.rank} vs #{card2.rank}. "
    suffix = ""

    if result == 0
      @table = round_cards
      suffix = "It's a tie!"
    else
      result == 1 ? round_winner = @player1 : round_winner = @player2
      round_winner.win_cards(round_cards)
      @table = []
      suffix = "#{result == 1 ? @player1.name : @player2.name} wins the round!"
    end

    round_winner == @player1 ? round_loser = @player2 : round_loser = @player1
    @winner = round_winner if round_loser.hand.empty?

    return prefix + suffix

  end

  def deal_cards()
    mid = CardDeck::FULL_COUNT
    @player1.hand = @deck.cards[0...(mid / 2 )]
    @player2.hand = @deck.cards[(mid / 2 )..-1]
  end

end