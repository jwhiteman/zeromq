require "ffi-rzmq"

context = ZMQ::Context.new

puts "Starting the Hello World server..."

socket = context.socket(ZMQ::REP)
socket.bind("tcp://*:5555")

loop do
  request = ""

  socket.recv_string(request)

  puts "Received request. Data: #{request.inspect}"

  sleep 5

  socket.send_string("world")

  sleep 5
end
