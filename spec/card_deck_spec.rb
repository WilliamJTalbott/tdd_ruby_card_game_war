require_relative '../lib/card_deck'
require_relative'../lib/playing_card'
require 'timeout'

describe 'CardDeck' do
  it 'Should have 52 cards when created' do
    deck = CardDeck.new
    expect(deck.cards_left).to eq 52
  end

  it 'deal gives a unique card each time' do
    deck = CardDeck.new
    card1 = deck.deal
    card2 = deck.deal

    expect(card1 != card2).to eq true
  end

  it 'should deal the top card' do
    deck = CardDeck.new
    card = deck.deal
    expect(card).to_not be_nil
    expect(deck.cards_left).to eq 51
  end

  describe 'shuffle' do
    it "deck can be shuffled" do
      base_deck = CardDeck.new()
      shuffled_deck = CardDeck.new()
      shuffled_deck.shuffle
      expect(shuffled_deck.cards).to_not eq base_deck.cards
    end

  #   it "deck is shuffled until it is not the same as before" do
  #     deck = CardDeck.new()
  #     deck.cards = [PlayingCard.new("A", "Hearts"), PlayingCard.new("A", "Hearts")]

  #     expect {
  #       Timeout.timeout(1) do
  #         deck.shuffle
  #       end
  #     }.not_to raise_error
  #   end
  end

end
