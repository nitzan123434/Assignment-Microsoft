from flask import Flask, jsonify
import requests
import threading
import time

app = Flask(__name__)
prices = []

def fetch_bitcoin_price():
    while True:
        try:
            response = requests.get("https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd")
            data = response.json()

            if "bitcoin" in data and "usd" in data["bitcoin"]:
                price = float(data["bitcoin"]["usd"])
                prices.append(price)
                print(f"Current BTC price: ${price:.2f}")

                if len(prices) > 10:
                    prices.pop(0)

                if len(prices) == 10:
                    avg = sum(prices) / len(prices)
                    print(f"Average of last 10 minutes: ${avg:.2f}")
        except:
            print("Error fetching price")

        time.sleep(60)

@app.route("/healthz")
def health():
    return "OK", 200

@app.route("/readyz")
def ready():
    return "READY", 200

if __name__ == "__main__":
    threading.Thread(target=fetch_bitcoin_price, daemon=True).start()
    app.run(host="0.0.0.0", port=8080)
