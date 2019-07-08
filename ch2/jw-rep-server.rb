require "ffi-rzmq"

context = ZMQ::Context.new

responder = context.socket(ZMQ::REP)
responder.bind("tcp://*:5555")

loop do
  responder.recv_string(from = "")
  responder.recv_string(request = "")

  puts "Received a request: #{request} from #{from}"

  reply = 2 ** request.to_i

  responder.send_string(from, ZMQ::SNDMORE)
  responder.send_string(reply.to_s)
end
