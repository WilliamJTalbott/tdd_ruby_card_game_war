require_relative 'war_socket_server'

server = WarSocketServer.new
server.start
while true do
  begin 
  
  server.add_new_client
  game = server.new_game_if_possible
  if game
    server.run_game(game)
  end
  rescue
    server.stop
  end
end
