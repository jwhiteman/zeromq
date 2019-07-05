require "ffi-rzmq"

def worker_routine(context)
  receiver = context.socket(ZMQ::REP)
  receiver.connect("inproc://workers")

  thread_id = Thread.current.object_id.to_s(36)

  loop do
    receiver.recv_string(m = "")
    puts "received message: #{m}"

    sleep 1

    receiver.send_string("WORLD! (from #{thread_id})")
  end
end

context = ZMQ::Context.new(1)

puts "Starting the hello world server"

clients = context.socket(ZMQ::ROUTER)
clients.bind("tcp://*:5555")

workers = context.socket(ZMQ::DEALER)
workers.bind("inproc://workers")

5.times.map do
  Thread.new { worker_routine(context) }
end

ZMQ::Proxy.new(clients, workers)
