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

    it "player1 wins with higher card" do
      game = WarGame.new
      game.player1.hand = [PlayingCard.new("3", "Clubs")]
      game.player2.hand = [PlayingCard.new("2", "Clubs")]

      game.play_round()
      expect(game.player2.hand.empty?).to eq true
    end


    it "player2 wins with higher card" do
      game = WarGame.new
      game.player1.hand = [PlayingCard.new("5", "Clubs")]
      game.player2.hand = [PlayingCard.new("A", "Clubs")]

      game.play_round()
      expect(game.player1.hand.empty?).to eq true
    end

    it "Outputs text on a win" do
      game = WarGame.new
      game.player1.hand = [PlayingCard.new("7", "Clubs")]
      game.player2.hand = [PlayingCard.new("Q", "Diamonds")]

      expect(game.play_round).to eq "7 vs Q. Tom wins the round!"
    end

    it "outputs text on tie" do
      game = WarGame.new
      game.player1.hand = [PlayingCard.new("K", "Clubs")]
      game.player2.hand = [PlayingCard.new("K", "Diamonds")]

      expect(game.play_round).to eq "K vs K. It's a tie!"
    end

    it "stores cards on tie" do
      game = WarGame.new
      cards = [PlayingCard.new("K", "Clubs"), PlayingCard.new("K", "Diamonds")]
      game.player1.hand = [cards.first]
      game.player2.hand = [cards.last]
      game.play_round

      expect(game.table = cards)
    end

    it "a winner is selected" do
      game = WarGame.new
      game.player1.hand = [PlayingCard.new("A", "Clubs")]
      game.player2.hand = [PlayingCard.new("5", "Clubs")]

      game.play_round()
      expect(game.winner).to eq game.player1
    end

  end

end
