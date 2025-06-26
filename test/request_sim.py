import requests
import json
import random
import time
import threading

# Configuration
NUM_USERS = 500  # Number of concurrent simulated users
REQUEST_INTERVAL = 1  # Seconds between each user's request

# Request headers
headers = {
    "Content-Type": "application/json"
}

# Function for each user thread
def simulate_user(user_index):
    while True:
        # Generate random values
        user_id = random.randint(1, 10000)
        burger_qty = random.randint(1, 100)
        fries_qty = random.randint(1, 100)

        # URL with dynamic user_id
        url = f"http://localhost:3000/orders/?user_id={user_id}"

        # Payload
        data = {
            "order": {
                "items": {
                    "burger": burger_qty,
                    "fries": fries_qty
                }
            }
        }

        try:
            response = requests.post(url, headers=headers, data=json.dumps(data))
            print(f"[{time.strftime('%H:%M:%S')}] User-{user_index} | user_id={user_id} | Burger={burger_qty} | Fries={fries_qty} | Status={response.status_code}")
        except Exception as e:
            print(f"User-{user_index} failed: {e}")

        time.sleep(REQUEST_INTERVAL)

# Start threads
threads = []
for i in range(NUM_USERS):
    thread = threading.Thread(target=simulate_user, args=(i + 1,))
    thread.daemon = True  # Optional: allows Ctrl+C to stop all threads
    thread.start()

# Keep main thread alive
try:
    while True:
        time.sleep(1)
except KeyboardInterrupt:
    print("\nSimulation stopped.")
