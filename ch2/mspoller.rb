# start the weather-server, ventilator, and sink in ch1
require "ffi-rzmq"

context = ZMQ::Context.new

# connect to weather service
subscriber = context.socket(ZMQ::SUB)
subscriber.connect("tcp://localhost:5556")
subscriber.setsockopt(ZMQ::SUBSCRIBE, "10001")

# connect to ventilator
receiver = context.socket(ZMQ::PULL)
receiver.connect("tcp://localhost:5557")

poller = ZMQ::Poller.new
poller.register(subscriber, ZMQ::POLLIN)
poller.register(receiver, ZMQ::POLLIN)

loop do
  poller.poll(:blocking)
  poller.readables.each do |socket|
    if socket == receiver
      socket.recv_string(message = "")
      puts "task: #{message}"
    elsif socket == subscriber
      socket.recv_string(message = "")
      puts "weather: #{message}"
    end
  end
end
