require "ffi-rzmq"

context = ZMQ::Context.new(1) # not sure what the 1 does here.

publisher = context.socket(ZMQ::PUB)

publisher.bind("tcp://*:5556")
# publisher.bind("ipc://weather.ipc") # ?

loop do
  zip  = rand(100_000)
  temp = rand(215) - 80
  hum  = rand(50) + 10

  update = "%05d %d %d" % [zip, temp, hum]

  publisher.send_string(update)
end
