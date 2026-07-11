import time
import random
from flask import Flask
from prometheus_client import start_http_server, Counter, Histogram

app = Flask(__name__)

# Definizione delle metriche Prometheus
REQUEST_COUNT = Counter('app_requests_total', 'Total number of requests')
REQUEST_DURATION = Histogram('app_request_duration_seconds', 'Request duration in seconds')

@app.route('/')
def hello():
    REQUEST_COUNT.inc()
    with REQUEST_DURATION.time():
        # Simula un tempo di risposta variabile
        time.sleep(random.uniform(0.1, 0.5))
    return "Hello from LogStream!"

if __name__ == '__main__':
    # Avvia il server HTTP delle metriche su porta 8000
    start_http_server(8000)
    # Avvia l'applicazione Flask su porta 5000
    app.run(host='0.0.0.0', port=5000)