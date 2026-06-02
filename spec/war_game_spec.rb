require_relative '../lib/war_game'
require_relative '../lib/card_deck'
require_relative '../lib/war_player'
require_relative '../lib/playing_card'

describe 'WarGame' do
  let(:game) {WarGame.new()}
  let(:players) {game.players}

  describe 'initialize' do
    it "setups players" do
      expect(players).to be_a Array
      expect(players.length).to eq 2
      players.each do |player|
        expect(player).to be_a WarPlayer
      end
    end

    it "sets up deck" do
      expect(game.deck).to be_a CardDeck
    end

  end

  describe 'start' do
    describe 'deal_cards' do
      it "deals cards to equally to each players hand" do
        amount = CardDeck::FULL_COUNT / players.length

        game.start()
        players.each do |player|
          expect(player.hand.length).to eq (amount)
        end
      end
    end
  end

  describe 'play_round' do

    it "player1 wins with higher card" do
      players[0].hand = [PlayingCard.new("3", "Clubs")]
      players[1].hand = [PlayingCard.new("2", "Clubs")]

      game.play_round()
      expect(players[1].hand.empty?).to eq true
    end


    it "players[1] wins with higher card" do
      players[0].hand = [PlayingCard.new("5", "Clubs")]
      players[1].hand = [PlayingCard.new("A", "Clubs")]

      game.play_round()
      expect(players[0].hand.empty?).to eq true
    end

    it "Outputs text on a win" do
      players[0].hand = [PlayingCard.new("7", "Clubs")]
      players[1].hand = [PlayingCard.new("Q", "Diamonds")]
      output = game.play_round
      text = "#{players[1].name} wins the round!"
      expect(output).to end_with text
    end

    it "outputs text on tie" do
      players[0].hand = [PlayingCard.new("K", "Clubs")]
      players[1].hand = [PlayingCard.new("K", "Diamonds")]
      output = game.play_round
      expect(output).to end_with " It's a tie!"
    end

    it "always outputs played cards" do
      players[0].hand = [PlayingCard.new("K", "Clubs")]
      players[1].hand = [PlayingCard.new("A", "Diamonds")]
      output = game.play_round
      expect(output).to start_with "K vs A."
    end

    it "stores cards on tie" do
      cards = [PlayingCard.new("K", "Clubs"), PlayingCard.new("K", "Diamonds")]
      players[0].hand = [cards.first]
      players[1].hand = [cards.last]
      game.play_round

      expect(game.table).to eq cards
    end

    it "stored cards go to next winner" do
      players[0].hand = [PlayingCard.new("K", "Clubs"), PlayingCard.new("K", "Diamonds")]
      players[1].hand = [PlayingCard.new("Q", "Clubs"), PlayingCard.new("K", "Diamonds")]
      game.play_round
      game.play_round
      expect(players[0].hand.length).to eq 4
    end

    it "a winner is selected on clear victory" do
      players[0].hand = [PlayingCard.new("A", "Clubs")]
      players[1].hand = [PlayingCard.new("5", "Clubs")]

      game.play_round()
      expect(game.winner).to eq players[0]
    end

    it "a winner is selected if last round is a tie" do
      players[0].hand = [PlayingCard.new("A", "Hearts"), PlayingCard.new("5", "Hearts")]
      players[1].hand = [PlayingCard.new("5", "Clubs")]

      game.play_round()
      expect(game.winner).to eq players[0]
    end

    it "redeal if both players run out of cards" do
      players[0].hand = [PlayingCard.new("A", "Clubs")]
      players[1].hand = [PlayingCard.new("A", "Hearts")]
      expect(game).to receive(:redeal)
      game.play_round()
    end

  end

end
