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
  mock_client.provide_input(name)
  server.add_new_client()
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

  it "client factory creates client properly" do
      mock_client = MockWarSocketClient.new(@server.port_number)
      # mock_client.provide_input("Bob")
      @server.add_new_client
      binding.irb
      server_client = @server.client[0]

      expect(server_client).to be_a(Hash)
      expect(server_client).to match(
        socket: be_a(TCPSocket),
        name: be_a(String),
        ready: be(false),
        message_given: be(false)
        )
  end

  it "is not listening on a port before it is started"  do
    @server.stop
    expect {MockWarSocketClient.new(@server.port_number)}.to raise_error(Errno::ECONNREFUSED)
  end

  describe "#add_new_client" do

    context "client factory runs" do
      it "creates a valid mock client" do
        client = client_factory("Jerry", @server)
        server_client = @server.clients[0]
        expect(@server.get_input(server_client)).to match(/jerry/i)
      end
    end


    context "when creating valid client" do
      it 'client gets a welcome message' do
        client = client_factory("Jerry", @server)
        expect(client.capture_output).to match(/welcome/i)
      end
    end

    context "when called" do
      it "gets name from client input" do

      end
      
    end

  end


  describe '#create_game' do
    it "notifies all clients when game starts" do
      clients = [client_factory("Tom", @server), client_factory("Jerry", @server)]
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
    let(:mock_clients) {[client_factory("Tom", @server), client_factory("Jerry", @server)]}
    let(:server_clients) {mock_clients; @server.clients}
    let(:game) { server_clients; @server.new_game_if_possible }

    context "when players are not ready" do
      it "returns" do
        expect(game).not_to receive(:play_round)
        @server.run_round(game)
      end
    end

    context "when players are ready" do
      it "runs play_round" do
        mock_clients.each {|client| client.provide_input("\n")}
        expect(game).to receive(:play_round)
        @server.run_round(game)
      end
    end
  end

  describe "#ready?" do
    let(:mock_clients) {[client_factory("Tom", @server), client_factory("Jerry", @server)]}
    let(:server_clients) {mock_clients; @server.clients}
    let(:game) { server_clients; @server.new_game_if_possible }

    context "run when clients are ready" do
      it "returns true" do
        server_clients.each {|client| client[:ready] = true}
        expect(@server.ready?(game)).to eq true
      end
    end

    context "a single clients is ready" do
      it "returns false" do
        server_clients.first[:ready] = true
        expect(@server.ready?(game)).to eq false
      end
    end

    context "when player is ready" do
      it "doesn't send another ready message" do
          mock_clients.first.capture_output
          2.times { @server.run_round(game)}
          expect(mock_clients.first.capture_output.chomp).to include("Are you ready:").once
      end
    end

  end

  describe "#game_over?" do
    let(:mock_clients) {[client_factory("Tom", @server), client_factory("Jerry", @server)]}
    let(:game) { mock_clients; @server.new_game_if_possible }

    context "when game has no winner" do
      it "returns false" do
        expect(@server.game_over?(game)).to eq false
      end
    end

    context "when game has a winner" do
      it "sends clients end messages" do
        game.winner = WarPlayer.new("Tom")
        @server.game_over?(game)
        expect(mock_clients.first.capture_output).to match(/winner/i)
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
        @server.send_output([server_client], "yo")
        expect(mock_client.capture_output.chomp).to match("yo")
      end
    end
  end

end