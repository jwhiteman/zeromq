require "openssl"
require "ffi-rzmq"

def spawn_worker(n)
  Thread.new do
    context = ZMQ::Context.new
    dealer  = context.socket(ZMQ::DEALER)
    ident   = OpenSSL::Random.
              random_bytes(2).
              each_byte.
              map { |b| sprintf("%02X", b) }.
              join(":")

    dealer.identity = ident
    dealer.connect("tcp://localhost:5555")

    dealer.send_string("#{n}:OK")

    loop do
      dealer.recv_strings(m = [])

      puts "ROUTER ASKED WORKER #{n}: #{m.inspect}"
      work = m[-1].split.last.to_i
      resl = 2 ** work
      sleep rand * 3

      dealer.send_string("#{n}: 2 ** #{work} is #{resl}.")
    end
  end
end

context = ZMQ::Context.new
router  = context.socket(ZMQ::ROUTER)
router.bind("tcp://*:5555")

5.times.map do |n|
  spawn_worker(n)
end

loop do
  router.recv_strings(m = [])

  puts "\tWORKER REPLIED: #{m.inspect}"

  m[-1] = "What is 2 ** #{rand(128)}?"

  router.send_strings(m)
end
