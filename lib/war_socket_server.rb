require 'socket'
require_relative "war_game"

class WarSocketServer

  attr_accessor :pending_clients, :game_clients, :server, :games
  attr_reader :port_number

  CLIENTS_PER_GAME = 2

  def initialize
    @pending_clients = []
    @game_clients = {}
    @server = nil
    @port_number = 3336

  end

  def start
    self.server = TCPServer.new(port_number)
  end

  def clients
    pending_clients + games.flat_map { |game| game_clients[game] }
  end

  def games
    game_clients.keys
  end

  def setup_client(player_name)
    {
      socket: server.accept_nonblock, #TCP SOCKET CLASS
      name: player_name,
      ready: false,
      message_given: false
    }
  end

  def add_new_client(player_name = "random_player") #This is adding a third player?
    client = setup_client(player_name)
    pending_clients << client
    
    send_output([client], "Welcome to War!")
    client

  rescue IO::WaitReadable, Errno::EINTR
  end

  def new_game_if_possible

    return unless pending_clients.count == CLIENTS_PER_GAME
    selected_clients = [pending_clients[0], pending_clients[1]]
    create_game(selected_clients)
    
  end

  def create_game(selected_clients)
    send_output(selected_clients, "War is starting...")
    names = selected_clients.map { |client| client[:name] }
    game = WarGame.new(*names)
    game_clients[game] = selected_clients
    game.start
    game
  end

  def get_input(client)
    sleep(0.2)
    socket = client[:socket]
    socket.read_nonblock(1000)
  rescue
    nil
  end

  def send_output(client_list, string)
    Array(client_list).each do |client|
      client[:socket].puts string
    end
  end

  def run_game(game)

    until game_over?(game)
      run_round(game)
    end

    stop

  end

  def run_round(game)
    if ready?(game)
      puts(game.play_round)
      selected_clients = game_clients[game]
      selected_clients.each do |client|
        client[:ready] = false
        client[:message_given] = false
      end
    end
  end

  def ready?(game)

    selected_clients = game_clients[game]
    selected_clients.each do |client|
      send_output([client], "Are you ready:") unless client[:message_given]
      client[:message_given] = true

      next if get_input(client).nil?
      client[:ready] = true
      send_output([client], "Confirmation received!")

    end

    return selected_clients.all? { |h| h[:ready] == true }
  end

  def game_over?(game)
    return false unless game.winner

    selected_clients = game_clients[game]
    send_output(selected_clients, "#{game.winner.name} is the winner!")
    true
  end

  def stop
    @server.close if @server
  end

end
