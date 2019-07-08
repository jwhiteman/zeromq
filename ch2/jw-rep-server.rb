require "ffi-rzmq"

context = ZMQ::Context.new

responder = context.socket(ZMQ::REP)
responder.connect("tcp://localhost:5555")

subscriber = context.socket(ZMQ::SUB)
subscriber.connect("tcp://localhost:5558")
subscriber.setsockopt(ZMQ::SUBSCRIBE, "")

poller = ZMQ::Poller.new
poller.register(responder, ZMQ::POLLIN)
poller.register(subscriber, ZMQ::POLLIN)

loop do
  poller.poll(:blocking)

  poller.readables.each do |socket|
    if socket == responder
      responder.recv_string(from = "")
      responder.recv_string(request = "")

      print "Received a request: #{request} from #{from}\n"

      reply = 2 ** request.to_i

      responder.send_string(from, ZMQ::SNDMORE)
      responder.send_string(reply.to_s)
    elsif socket == subscriber
      print "#$$ (server shutting down)\n"

      exit
    else
      # no-op
    end
  end
end
