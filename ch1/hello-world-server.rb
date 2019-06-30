require "ffi-rzmq"

context = ZMQ::Context.new

puts "Starting the Hello World server..."

socket = context.socket(ZMQ::REP)
socket.bind("tcp://*:5555")

loop do
  request = ""

  socket.recv_string(request)

  puts "Received request. Data: #{request.inspect}"

  socket.send_string("world")
end
