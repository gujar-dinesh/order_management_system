# Order Management System (OMS)

This is a lightweight, event-aware order management system built with Ruby on Rails, Sidekiq, Redis, and PostgreSQL. Inventory logic is handled asynchronously with Sidekiq, and PgBouncer is used for PostgreSQL connection pooling.

## Features

* Place and manage orders
* Inventory deduction and restoration
* Event-driven processing with Sidekiq
* PgBouncer for DB pooling
* Load testing via custom simulator
* Fully containerized with Docker Compose

---

## Running in Docker

### 1. Clone the Repo

```bash
git clone <your-repo-url>
cd your-repo-directory
```

### 2. Build and Start Containers (initial setup)

```bash
docker-compose build
```

### 3. Run Database Migrations and Seeds

```bash
docker-compose run web rails db:create db:migrate db:seed
```

### 4. Start All Services

```bash
docker-compose up
```

This will spin up:

* `web`: Rails API
* `sidekiq`: Background job processor
* `db`: PostgreSQL
* `redis`: For Sidekiq queues
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

* API available at: `http://localhost:3000`

* Rails console:

```bash
docker-compose exec web rails console
```

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

---

## Cleanup

```bash
docker-compose down -v
```

This will remove all containers, volumes, and networks.

---

## ENV Defaults

These are pre-configured in `docker-compose.yml`:

```
DB_USERNAME=dinesh
DB_PASSWORD=password
DB_HOST=pgbouncer
DB_PORT=6432
REDIS_URL=redis://redis:6379/1
```

---

Happy hacking!
