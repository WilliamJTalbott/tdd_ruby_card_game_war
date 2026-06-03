require 'socket'
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

  def capture_output(delay=0.1)
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
  server.accept_new_client(name)
  return mock_client
end

describe WarSocketServer do

  before(:each) do
    @clients = []
    @server = WarSocketServer.new
    @server.start
    sleep 0.1 # Ensure server is ready for clients
  end

  after(:each) do
    @server.clients.each { |client| client[:socket].close }
    @server.stop
  end

  it "is not listening on a port before it is started"  do
    @server.stop
    expect {MockWarSocketClient.new(@server.port_number)}.to raise_error(Errno::ECONNREFUSED)
  end

  it 'clients get a welcome message' do
    client = client_factory("Jerry", @server)
    @server.accept_new_client "Player 1"
    expect(client.capture_output).to match /welcome/i
  end

  it "All clients get a starting message when second client joins" do
    client1 = client_factory("Tommy", @server)
    client1.capture_output

    client2 = client_factory("Jerry", @server)
    client1.capture_output

    @server.create_game_if_possible

    expect(client1.capture_output).to match /starting/i
    expect(client2.capture_output).to match /starting/i
  end

  it "accepts new clients and starts a game if possible" do
    client1 = client_factory("Tommy", @server)
    @server.create_game_if_possible
    expect(@server.games.count).to be 0


    client2 = client_factory("Jerry", @server)
    @server.create_game_if_possible
    expect(@server.games.count).to be 1
  end


  it "clients have proper data" do
    client1 = client_factory("Tommy", @server)

    client = @server.clients.first
    expect(client).to be_a(Hash)
    expect(client).to match(
      socket: be_a(TCPSocket),
      name: be_a(String),
      ready: be(false),
      message_given: be(false)
    )
    
  end

  xit "stops game loops if both players aren't ready" do
    client1 = client_factory("Tommy", @server)
    client2 = client_factory("Jerry", @server)

    game = @server.create_game_if_possible

    expect(@server.run_game(game)).to_not eq "called play_round"
  end

  xit "ask 'ready' message sends to clients" do
    client1 = client_factory("Tommy", @server)
    client2 = client_factory("Jerry", @server)

    game = @server.create_game_if_possible
    client1.capture_output
    @server.run_game(game)

    expect(client1.capture_output).to include("Are you ready?")

  end

  xit "server recieves inputs" do
    client1 = client_factory("Tommy", @server)
    client2 = client_factory("Jerry", @server)

    @server.create_game_if_possible

    client1.provide_input("yo")
    expect(@server.get_input).to eq "yo"
  end

  xit "message send only once to each client once" do
    client1 = client_factory("Tommy", @server)
    client2 = client_factory("Jerry", @server)

    game = @server.create_game_if_possible
    client1.capture_output

    2.times { @server.run_game(game)}
    expect(client1.capture_output.chomp).to eq "Are you ready?"
  end

  it "run_game gets confirmation input" do
    client1 = client_factory("Tommy", @server)
    client2 = client_factory("Jerry", @server)
    game = @server.create_game_if_possible

    expect(@server.clients.first[:ready]).to eq false

    client1.provide_input("\n")
    @server.run_game(game)
    
    expect(@server.clients.first[:ready]).to eq true
  end

  xit "plays a single round" do
    client1 = client_factory("Tommy", @server)
    client2 = client_factory("Jerry", @server)

    game = @server.create_game_if_possible
    @server.run_game(game)

    client1.capture_output

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

  describe "#run_game" do
    let(:mock_client1) { client_factory("Tommy", @server) }
    let(:mock_client2) { client_factory("Jerry", @server) }
    let(:server_client1) { mock_client1; mock_client2; @server.clients[0] }
    let(:server_client2) { mock_client1; mock_client2; @server.clients[1] }
    let(:game) { server_client1; server_client2; @server.create_game_if_possible }

    context "when players are not ready" do
      it "returns" do
        expect(game).not_to receive(:play_round)
        @server.run_game(game)
      end
    end

    context "when players are ready" do
      it "runs play_round" do

        mock_client1.provide_input("\n")
        mock_client2.provide_input("\n")
        expect(game).to receive(:play_round)
        @server.run_game(game)
      end
    end

  end



  # Add more tests to make sure the game is being played
  # For example:
  #   √ make sure the mock client gets appropriate output (Client Case)
  #   √ make sure the next round isn't played until both clients say they are ready to play (Client Case)
  #   √ make sure players are asked if they are ready
  #   √ make sure clients can provide response
  #   √ make sure 
  #   make sure player game runs if players provide response
  #   
  #   add gameloop to WarSocketServer
  #   ( make sure both players are ready )
  #   ..

end

      # @server.clients.each do |client|
      #   expect(client[:ready]).to eq (true)
      # end