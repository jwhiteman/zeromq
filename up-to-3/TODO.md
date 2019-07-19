# http://api.zeromq.org/3-2:zmq-socket

REQ:
  out: round robin
   in: last peer
  msg: inserts empty frame
  pat: send, recv, send, recv

ROUTER:
  out: ...
   in: fair-queued
  msg: inserts id frame ontop of req
  pat: unrestricted

REP:
  out: last peer
   in: fair queued
  msg: assumes {id, "", body} ?
  pat: recv, send, recv, send

DEALER:
  out: round robin
   in: fair-queued
  msg: ...
  pat: unrestricted

experiments:
  ~> reqs => router|dealer => reps
    - see if you can view incoming/outgoing strategies
  ~> reqs => router|router => reqs
    - ditto. how is this different than above?

  note: in both, don't use a ZMQ::Proxy to handle things

  DEALER and REP (take care, REP assumes a null frame)
    rep connects

  forked, fair-queued workers
  job queue with pipelines

  DEALER and ROUTER
  DEALER and DEALER
  ROUTER and ROUTER
```
require "ffi-rzmq"
require "pry"

context = ZMQ::Context.new
client = context.socket(ZMQ::REQ)
client.connect("tcp://localhost:5555")

require "ffi-rzmq"
require "pry"

context = ZMQ::Context.new
server = context.socket(ZMQ::REP)
server.bind("tcp://*:5555")

require "ffi-rzmq"
require "pry"

context = ZMQ::Context.new
client = context.socket(ZMQ::REQ)
client.connect("tcp://localhost:5555")

require "ffi-rzmq"
require "pry"

context = ZMQ::Context.new
server = context.socket(ZMQ::ROUTER)
server.bind("tcp://*:5555")
```
