require 'rubygems'
require 'ffi-rzmq'

def worker_routine(context)
  receiver = context.socket(ZMQ::REP)
  receiver.connect("inproc://workers")

  loop do
    receiver.recv_string(string = '')
    puts "Received request: [#{string}]"
    # Do some 'work'
    sleep(1)
    # Send reply back to client
    receiver.send_string("world")
  end
end

context = ZMQ::Context.new

puts "Starting Hello World server…"

clients = context.socket(ZMQ::ROUTER)
clients.bind("tcp://*:5555")

workers = context.socket(ZMQ::DEALER)
workers.bind("inproc://workers")

# Launch pool of worker threads
5.times do
  Thread.new{worker_routine(context)}
end

# Connect work threads to client threads via a queue
ZMQ::Device.new(clients, workers)
