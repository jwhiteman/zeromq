require "ffi-rzmq"

context = ZMQ::Context.new

requester = context.socket(ZMQ::REQ)
requester.connect("tcp://localhost:5556")

5.times do
  n = rand(100) + 1

  requester.send_string "#$$", ZMQ::SNDMORE
  requester.send_string(n.to_s)

  requester.recv_string(from = "")
  requester.recv_string(answer = "")

  puts "#$$ => #{from}: 2 ** #{n} == #{answer}"

  sleep 2
end
