require 'socket'
require_relative '../lib/war_player'
require_relative '../lib/war_socket_server'

class MockWarSocketClient
  attr_reader :socket
  attr_reader :output

  def initialize(port)
    @socket = TCPSocket.new('localhost', port)
  end

  def provide_input(text)
    @socket.puts(text)
  end

  def capture_output(delay=0.2)
    sleep(delay)
    @output = @socket.read_nonblock(1000) # not gets which blocks
  rescue IO::WaitReadable
    @output = ""
  end

  def close
    @socket.close if @socket
  end
end

def client_factory(name = "random_player", server)
  mock_client = MockWarSocketClient.new(server.port_number)
  server.add_new_client(name)
  return mock_client
end

describe WarSocketServer do

  before(:each) do
    @server = WarSocketServer.new
    @server.start
    sleep 0.2 # Ensure server is ready for clients
  end

  after(:each) do
    #Clients is not readable?
    @server.clients.each { |client| client[:socket].close }
    @server.stop
  end

  it "is not listening on a port before it is started"  do
    @server.stop
    expect {MockWarSocketClient.new(@server.port_number)}.to raise_error(Errno::ECONNREFUSED)
  end

  # I need to reorder my tests such that
  # I can declare the values at the top

  describe "#add_new_client" do
    context "when creating client" do

      it 'client gets a welcome message' do
        client = client_factory("Jerry", @server)
        expect(client.capture_output).to match(/welcome/i)
      end
    end
  end


  describe '#create_game' do
    it "notifies all clients when game starts" do
      clients = [client_factory("Tom", @server), client_factory("Jerry", @server)]
      clients.each { |client| client.capture_output }
      @server.new_game_if_possible
      clients.each do |client|
        expect(client.capture_output).to match(/starting/i)
      end
    end
  end

  describe "#get_input" do
    let(:mock_client) {client_factory("Tommy", @server)}
    let(:server_client) { mock_client; @server.clients[0]}
    
    context "when an input is not waiting" do
      it "returns nil" do
        expect(@server.get_input(server_client)).to be_nil
      end
    end
    context "when an input is waiting" do
      it "returns that input" do
        mock_client.provide_input("\n")
        expect(@server.get_input(server_client)).to_not be_nil
      end
    end
  end

  describe "#run_round" do
    let(:mock_client1) { client_factory("Tommy", @server) }
    let(:mock_client2) { client_factory("Jerry", @server) }
    let(:server_client1) { mock_client1; mock_client2; @server.clients[0] }
    let(:server_client2) { mock_client1; mock_client2; @server.clients[1] }
    let(:game) { server_client1; server_client2; @server.new_game_if_possible }

    context "when players are not ready" do
      it "returns" do
        expect(game).not_to receive(:play_round)
        @server.run_round(game)
      end
    end

    context "when players are ready" do
      it "runs play_round" do
        mock_client1.provide_input("\n")
        mock_client2.provide_input("\n")
        expect(game).to receive(:play_round)
        @server.run_round(game)
      end
    end
    
    context "when player is ready" do
      it "doesn't send another ready message" do
        
          game
          mock_client1.capture_output
          2.times { @server.run_round(game)}
          expect(mock_client1.capture_output.chomp).to eq "Are you ready:"
      end
    end

  end

  describe "#ready?" do
    let(:mock_client1) { client_factory("Tommy", @server) }
    let(:mock_client2) { client_factory("Jerry", @server) }
    let(:server_client1) { mock_client1; mock_client2; @server.clients[0] }
    let(:server_client2) { mock_client1; mock_client2; @server.clients[1] }
    let(:game) { server_client1; server_client2; @server.new_game_if_possible }
    
    context "run when clients are ready" do
      it "returns true" do
        server_client1[:ready] = true
        server_client2[:ready] = true
        expect(@server.ready?(game)).to eq true
      end
    end

    context "a single clients is ready" do
      it "returns false" do
        server_client1[:ready] = true
        expect(@server.ready?(game)).to eq false
      end
    end
  end

  describe "#game_over?" do

    context "when game has no winner" do
      it "returns false" do
        client_factory("Tommy", @server)
        client_factory("Jerry", @server)
        game = @server.new_game_if_possible
        expect(@server.game_over?(game)).to eq false
      end
    end

    context "when game has a winner" do
      it "sends clients end messages" do
        client1 = client_factory("Tommy", @server)
        client2 = client_factory("Jerry", @server)
        game = @server.new_game_if_possible
        game.winner = WarPlayer.new("Tommy")

        client1.capture_output
        @server.game_over?(game)
        expect(client1.capture_output.chomp).to eq "Tommy is the winner!"
      end
    end
  end

  describe "#run_game" do
    context "when ran if game is not over" do
      it "players flip cards or something" do

      end
    end

    context "when ran if game is over" do
      it "sends winner message to clients" do
      end
    end
  end

  describe "#send_output" do
    let(:mock_client) {client_factory("Tommy", @server)}
    let(:server_client) { mock_client; @server.clients.first}
    context "when a message is sent with one client" do
      it "receives it" do

        mock_client.capture_output
        @server.send_output([server_client], "yo")
        expect(mock_client.capture_output.chomp).to eq "yo"
      end
    end
  end

end