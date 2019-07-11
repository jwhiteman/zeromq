require "pry"
require "ffi-rzmq"

def s_dump(sock)
  puts "------------------------------------"
  # Build an array to hold all the parts
  messages = []
  sock.recvmsgs(messages)
  # messages is an array of ZMQ::Message objects
  messages.each do |msg|
    if msg == messages[0]
      # identity - Naive implementation
      # msg.size == 17 ? puts("Identity: #{msg.copy_out_string.unpack('H*')[0]}") : puts("Identity: #{msg.copy_out_string}")
      # puts [msg.copy_out_string].pack("m0")
    else
      # body
      # puts "Data: #{msg.copy_out_string}"
    end

    puts msg.copy_out_string
  end
end

context = ZMQ::Context.new
uri = "inproc://example"

sink = context.socket(ZMQ::ROUTER)
sink.setsockopt(ZMQ::ROUTER_MANDATORY, 1)
sink.bind(uri)

anonymous = context.socket(ZMQ::REQ)
anonymous.connect(uri)

# how is this different than send_string ?
anon_message = ZMQ::Message.new("ROUTER uses a generated 5-byte identity")
anonymous.sendmsg(anon_message)

s_dump(sink)

identified = context.socket(ZMQ::REQ)
identified.setsockopt(ZMQ::IDENTITY, "PEER2")
identified.connect(uri)

identified_message = ZMQ::Message.new("ROUTER uses our pre-configured ident")
identified.sendmsg(identified_message)

s_dump(sink)
