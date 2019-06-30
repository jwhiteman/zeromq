require "ffi-rzmq"

context = ZMQ::Context.new(1)
pusher  = context.socket(ZMQ::PUSH)

pusher.connect("tcp://localhost:3000")

print "Push Enter when ready: "

gets

pusher.send_string("push it!")
