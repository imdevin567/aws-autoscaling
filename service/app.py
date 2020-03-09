from flask import Flask, request
from math import factorial
from threading import Thread
import signal
import time

# This class generates load by running math.factorial() over a period of time
class Load:
    should_stop = False

    def stop(self):
        should_stop = True

    def run(self, cpu_usage: float, seconds: float):
        if cpu_usage > 1.0:
            print('CPU usage cannot be above 100%!')
        else:
            start_time = time.time()
            while not self.should_stop:
                cycle_time = time.time()
                if cycle_time - start_time >= seconds:
                    self.should_stop = True
                while time.time() - cycle_time < cpu_usage:
                    factorial(100)
                time.sleep(1.0 - cpu_usage)
            self.should_stop = False

app = Flask(__name__)
load = Load()

# Endpoint to generate load
@app.route('/killme')
def killme():
    cpu_usage = float(request.args.get('usage', 0.8))
    length = float(request.args.get('time', 30))
    thread = Thread(target=load.run, args=(cpu_usage, length,))
    thread.daemon = True
    thread.start()
    return f'Creating CPU load of {cpu_usage * 100.0}% for {length} seconds in the background'

if __name__ == '__main__':
    app.run(host='0.0.0.0')
