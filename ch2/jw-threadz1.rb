require "ffi-rzmq"

def worker(context)
  responder = context.socket(ZMQ::REP)
  responder.connect("inproc://workers")

  controller = context.socket(ZMQ::SUB)
  controller.setsockopt(ZMQ::SUBSCRIBE, "")
  controller.connect("inproc://messages")

  poller = ZMQ::Poller.new
  poller.register(responder, ZMQ::POLLIN)
  poller.register(controller, ZMQ::POLLIN)

  shutdown = false

  while !shutdown do
    poller.poll(:blocking)
    poller.readables.each do |socket|
      if socket == responder
        responder.recv_string(message = "")
        print "MESSAGE RECEIVED: #{message}\n"
        response = 2 ** message.to_i

        responder.send_string(response.to_s)
      elsif socket == controller
        print "^"

        shutdown = true
        break
      else
        # no-op
      end
    end
  end

  print "$"
end

def client(context)
  requester = context.socket(ZMQ::REQ)
  requester.connect("inproc://clients")

  5.times do
    n = rand(10) + 1

    requester.send_string(n.to_s)
    requester.recv_string(m = "")

    print "2 ** #{n} == #{m}\n"

    sleep 1
  end
end


context = ZMQ::Context.new

clients = context.socket(ZMQ::ROUTER)
clients.bind("inproc://clients")

workers = context.socket(ZMQ::DEALER)
workers.bind("inproc://workers")

controller = context.socket(ZMQ::PUB)
controller.bind("inproc://messages")

5.times do
  Thread.new { worker(context) }
end

5.times do
  Thread.new { client(context) }
end

trap(:INT) do
  print "Shutdown signal received..."

  controller.send_string("END")

  sleep 1

  clients.close
  workers.close
  controller.close

  sleep 1

  context.terminate

  print "Bye\n"
  exit
end

ZMQ::Proxy.new(clients, workers)
