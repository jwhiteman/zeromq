python ppqueue.py &
for i in 1 2 3 4; do
    python ppworker.py &
    sleep 1
done
python lpclient.py &
