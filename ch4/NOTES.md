# lazy pirate
- all client side
  - user poller, with a timeout + a counter
    - when we timeout, increment the counter
    - when maxretries is reached, exit
  - for a retry, you'll need to kill the socket/connection and create them new
    ...because REQ forces a strict req/rep cycle

