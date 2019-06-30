require "ffi-rzmq"

COUNT = 100

context = ZMQ::Context.new(1)

puts "Collecting weather updates..."

subscriber = context.socket(ZMQ::SUB)
subscriber.connect("tcp://localhost:5556")

filter = ARGV[0] || "10001 " # why the whitespace here?

subscriber.setsockopt(ZMQ::SUBSCRIBE, filter)

total_temp = 0
1.upto(COUNT) do |n|
  s = ""
  subscriber.recv_string(s)

  print "."

  zip, temp, hum = s.split(" ").map(&:to_i)

  total_temp =  total_temp += temp
end

puts "Average temperature for zipcode #{filter} was #{total_temp.to_f / COUNT}F"
