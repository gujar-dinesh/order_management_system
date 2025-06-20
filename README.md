# Order Management System (OMS)

<<<<<<< Updated upstream
This is a lightweight, event-aware order management system built with Ruby on Rails, Kafka, Karafka, Sidekiq, Redis, and PostgreSQL. Orders and inventory are processed asynchronously using Kafka topics, and PgBouncer is used for PostgreSQL connection pooling.
=======
This is a lightweight, event-aware order management system built with Ruby on Rails, Kafka, Karafka, Redis, and PostgreSQL. Inventory and order logic are handled asynchronously via Kafka topics. PgBouncer is used for PostgreSQL connection pooling.
>>>>>>> Stashed changes

## Features

* Place and manage orders
* Inventory deduction and restoration
<<<<<<< Updated upstream
* Event-driven architecture with Kafka + Karafka
* Background processing with Sidekiq
=======
* Event-driven processing with Kafka + Karafka
>>>>>>> Stashed changes
* PgBouncer for DB pooling
* Load testing via custom simulator
* Fully containerized with Docker Compose

---

## Kafka-Based Event Flow

This app uses **Kafka** for asynchronous communication between services:

- `orders` topic: carries order status updates
- `inventory` topic: carries new order events that trigger inventory deduction

Karafka consumers:
- `OrderConsumer` – handles order status changes and inventory rollback on cancellation
- `InventoryConsumer` – reserves inventory on new order creation

---

## Running in Docker

### 1. Clone the Repo

```bash
git clone git@github.com:gujar-dinesh/order_management_system.git
cd order_management_system
```

### 2. Build and Start Containers

```bash
docker-compose build --no-cache
```

### 3. Run Database Migrations and Seeds

```bash
docker-compose run web rails db:create db:migrate db:seed
```

### 4. Start All Services

```bash
docker-compose up
```

This spins up:

* `web`: Rails API
<<<<<<< Updated upstream
* `sidekiq`: Background job processor
* `karafka`: Karafka consumer server
* `kafka`: Kafka broker
* `zookeeper`: Required for Kafka
* `redis`: For Sidekiq queues
* `db`: PostgreSQL
=======
* `karafka`: Kafka consumer service
* `kafka`: Kafka broker
* `zookeeper`: Required by Kafka
* `db`: PostgreSQL
* `redis`: Used for caching or pub/sub if needed
>>>>>>> Stashed changes
* `pgbouncer`: Connection pooler on port 6432

---

## Access the App

### API Endpoints

* `POST   /orders?user_id=:id` — Create an order
* `GET    /orders/:id` — Get order details
* `PUT    /orders/:id/update_status` — Update order status
* `POST   /orders/:id/cancel` — Cancel order
* `GET    /users/:user_id/orders` — List orders for a user
* `POST   /inventory_items` — Add inventory item
* `PUT    /inventory_items/:id` — Update inventory item
* `DELETE /inventory_items/:id` — Delete inventory item

<<<<<<< Updated upstream
Access API via: `http://localhost:3000`
=======
API available at: `http://localhost:3000`
>>>>>>> Stashed changes

### Rails console

```bash
docker-compose exec web rails console
```

---

## Kafka Events

**Published Events:**

<<<<<<< Updated upstream
* `inventory` topic (from order observer):

```ruby
Karafka.producer.produce_async(
  topic: 'inventory',
  payload: { order_id: order.id }.to_json
)
```

* `orders` topic (from order update logic):

```ruby
Karafka.producer.produce_async(
  topic: 'orders',
  payload: { order_id: order.id, new_status: 'Cancelled' }.to_json
)
```

**Consumed by Karafka:**

* `InventoryConsumer`: reserves inventory, confirms/rejects orders
* `OrderConsumer`: updates order status, restores inventory on cancel

---

## Running Karafka Server (Manual)

If you want to run Karafka server manually (outside Docker):

```bash
bundle exec karafka server
```

Docker version runs it via `karafka` service automatically.

=======
* `inventory` topic: triggered when an order is created to reserve inventory
* `orders` topic: triggered when order status is updated (e.g., cancellation)

**Consumed by Karafka:**

* `InventoryConsumer`: attempts to reserve inventory or reject the order
* `OrderConsumer`: updates order status and rolls back inventory if needed

---

## Running Karafka Manually

You can also run Karafka from inside the container:

```bash
docker-compose exec karafka bundle exec karafka server
```

>>>>>>> Stashed changes
---

## Run Simulator (Load Testing)

The load test simulator is available in the `test/` folder.

### 1. Ensure the app is running

```bash
docker-compose up
```

### 2. Run the simulator using `k6`

From your host machine:

```bash
k6 run test/load_test.js
```

You can modify `vus`, `duration`, and test logic in `load_test.js`.

---

## Run RSpec Tests

```bash
docker-compose exec web bundle exec rspec
```

## Check Test Coverage

```bash
docker-compose exec web rspec
open coverage/index.html  # or xdg-open on Linux
```

---

## Useful Commands

* Restart only web:

  ```bash
  docker-compose restart web
  ```

* Rails console:

  ```bash
  docker-compose exec web rails c
  ```

* DB console:

  ```bash
  docker-compose exec db psql -U dinesh oms_development
  ```

<<<<<<< Updated upstream
* Karafka server (manually):
=======
* Karafka server (manual run):
>>>>>>> Stashed changes

  ```bash
  docker-compose exec karafka bundle exec karafka server
  ```

---

## Cleanup

```bash
docker-compose down -v
```

Removes all containers, volumes, and networks.

---

## ENV Defaults

Pre-configured in `docker-compose.yml`:

```
DB_USERNAME=dinesh
DB_PASSWORD=password
DB_HOST=pgbouncer
DB_PORT=6432
REDIS_URL=redis://redis:6379/1
KAFKA_BROKER=kafka:9092
```

---

Happy hacking 🎉
