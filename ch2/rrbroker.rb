require "ffi-rzmq"

context = ZMQ::Context.new

frontend = context.socket(ZMQ::ROUTER)
backend  = context.socket(ZMQ::DEALER)

frontend.bind("tcp://*:5559")
backend.bind("tcp://*:5560")

poller = ZMQ::Poller.new
poller.register(frontend, ZMQ::POLLIN)
poller.register(backend, ZMQ::POLLIN)

loop do
  poller.poll(:blocking)
  poller.readables.each do |socket|
    if socket == frontend
      socket.recv_strings(messages = [])
      backend.send_strings(messages)
      print "."
    elsif socket == backend
      socket.recv_strings(messages = [])
      frontend.send_strings(messages)
      print "*"
    else
      puts "some other readable thing is ready somehow"
    end
  end
end
