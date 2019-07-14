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
  socket.connect("tcp://localhost:5555")

  poller          = ZMQ::Poller.new
  poller.register_readable(socket)

  request_num     = 0
  loop do
    100.times do |tick|
      if poller.poll(10) == 1 # ?
        puts "XXX"
        socket.recv_strings(message = [])

        puts "#{socket.identity}: #{message.last}"
      end
    end

    puts "..."
    socket.send_string("Request ##{request_num += 1}")
  end
ensure
  socket.close if socket
  context.terminate
end

def worker(context)
  socket = context.socket(ZMQ::DEALER)
  socket.connect("inproc://backend")

  loop do
    puts "0"
    socket.recv_strings(message = [])
    puts "1"

    rand(1..4).each do
      sleep rand

      socket.send_strings(message)
    end
  end
ensure
  socket.close if socket
end

def server
  context  = ZMQ::Context.new

  frontend = context.socket(ZMQ::ROUTER)
  backend  = context.socket(ZMQ::DEALER)

  frontend.bind("tcp://*:5555")
  backend.bind("inproc://backend")

  poller = ZMQ::Poller.new
  poller.register_readable(frontend)
  poller.register_readable(backend)

  workers = 5.times.map do
    Thread.new { worker(context) }
  end

  ZMQ::Device.create(ZMQ::QUEUE, frontend, backend)

  workers.each(&:join)
end

clients = 3.times.map do
  Thread.new { client }
end

Thread.new { server }.join

binding.pry
