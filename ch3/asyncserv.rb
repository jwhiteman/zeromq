# socket.identity=()
# poller.register_readable()
# socket.recv_strings
# poller.poll(msecs) => int
# poller for async reading from a single socket
# rand(n..m)
# rand() # bare
# ZMQ::Device.create()
# ZMQ::QUEUE
# poller sans poll in the server routine
# ensure fucks up interrupts ?
require "ffi-rzmq"
require "openssl"
require "pry"

def hex_ident
  OpenSSL::Random.random_bytes(4).
                  bytes.
                  map { |b| sprintf("%02X", b) }.
                  join("-")
end

# threads acting as separate processes
def client
  context         = ZMQ::Context.new
  socket          = context.socket(ZMQ::DEALER)
  socket.identity = hex_ident
  socket.connect("tcp://localhost:5570")
  print("Client #{socket.identity} started\n")

  poller          = ZMQ::Poller.new
  poller.register(socket, ZMQ::POLLIN)

  reqs = 0
  loop do
    reqs = reqs + 1
    socket.send_string("Request ##{reqs += 1}")
    puts "C1"

    5.times do
      socket.recv_string(message = "")
      puts "C2"

      puts "#{socket.identity}: #{message.last}"
      $stdout.flush
    end
  end
end

def worker(context)
  loop do
    wsocket = context.socket(ZMQ::DEALER)

    if wsocket.nil?
      puts "Worker failed to connect. Retrying..."
      sleep 1
    else
      wsocket.connect("inproc://backend")
      puts "Worker connected."

      loop do
        puts "W1"
        wsocket.recv_strings(message = [])
        puts "WORKER: I received #{message.inspect}"

        rand(1..4).times do
          sleep rand

          wsocket.send_strings(message)
        end
      end
    end

    if wsocket
      wsocket.close
      break
    else
      # no-op, repeat
    end
  end
end

clients = 5.times.map do
  Thread.new { client }
end

context  = ZMQ::Context.new

raise "STOP" unless context

frontend = context.socket(ZMQ::ROUTER)
frontend.setsockopt(ZMQ::ROUTER_MANDATORY, 1)
frontend.bind("tcp://*:5570")

backend  = context.socket(ZMQ::DEALER)
backend.bind("inproc://backend")

workers = 5.times.map do
  Thread.new { worker(context) }
end

#ZMQ::Device.create(ZMQ::QUEUE, frontend, backend)
#workers.each(&:join)

#
poller = ZMQ::Poller.new
poller.register(frontend, ZMQ::POLLIN)
poller.register(backend, ZMQ::POLLIN)

loop do
  poller.poll

  poller.readables do |readable|
    if readable == frontend
      puts "Readable on frontend"
    elsif readable == backend
      puts "Readable on backend"
    else
      puts "unknown"
    end
  end
end
