require_relative '../lib/war_player'
require_relative '../lib/card_deck'
require_relative '../lib/playing_card'

class WarGame

  attr_accessor :winner, :players, :deck, :table
  
  def initialize(name1 = "Bob", name2 = "Tom")
    @winner = nil
    @players = [WarPlayer.new(name1), WarPlayer.new(name2)]
    @deck = CardDeck.new()
    @table = []
  end

  def start()
    @deck.shuffle
    deal_cards()
  end

  def play_round()

    card1 = players[0].play_card
    card2 = players[1].play_card

    round_winner = nil

    result = card1.value <=> card2.value
    round_cards = [*@table, card1, card2]
    prefix = "#{card1.rank} vs #{card2.rank}. "
    suffix = ""

    if result == 0
      @table = round_cards
      suffix = "It's a tie!"
    else
      result == 1 ? round_winner = players[0] : round_winner = players[1]
      round_winner.win_cards(round_cards)
      @table = []
      suffix = "#{result == 1 ? players[0].name : players[1].name} wins the round!"
    end

    if players.all? { |player| player.hand.empty?}
      redeal()
    else
      players.each_index do |i|
        if players[i].hand.empty?
          i == 0 ? @winner = players[1] : @winner = players[0]
        end
      end
    end

    return prefix + suffix

  end

  def redeal()
    
  end

  def deal_cards()
    amount = CardDeck::FULL_COUNT / players.length

    @players.each do |player|
      player.hand = @deck.cards.pop(amount)
    end
  end

end