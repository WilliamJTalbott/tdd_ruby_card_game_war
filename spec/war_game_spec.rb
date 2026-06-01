require_relative '../lib/war_game'
require_relative '../lib/card_deck'
require_relative '../lib/war_player'
require_relative '../lib/playing_card'

describe 'WarGame' do

  describe 'initialize' do
    it "setups players" do
      game = WarGame.new()
      expect(game.player1).to be_a WarPlayer
      expect(game.player2).to be_a WarPlayer
    end

    it "sets up deck" do
      game = WarGame.new()
      expect(game.deck).to be_a CardDeck
    end

  end

  describe 'start' do
    describe 'deal_cards' do
      it "deals cards to each players hand" do
        game = WarGame.new()
        mid = CardDeck::FULL_COUNT
        game.start()
        expect(game.player1.hand.length).to eq (mid / 2)
        expect(game.player2.hand.length).to eq (mid / 2)
      end
    end
  end

  describe 'play_round' do

    it "higher card player gets all cards" do
      game = WarGame.new
      game.player1.hand = [PlayingCard.new("3", "Clubs")]
      game.player2.hand = [PlayingCard.new("2", "Clubs")]

      game.play_round()
      expect(game.player2.hand.empty?).to eq true
    end

    it "repeats on a tie until there is a winner" do
      game = WarGame.new
      game.player1.hand = [PlayingCard.new("3", "Hearts"), PlayingCard.new("A", "Hearts")]
      game.player2.hand = [PlayingCard.new("2", "Clubs"), PlayingCard.new("A", "Clubs")]

      game.play_round()
      expect(game.player2.hand.empty?).to eq true
    end

  end

end
