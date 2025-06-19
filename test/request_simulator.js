import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
    vus: 500,
    duration: '10s',
    thresholds: {
        http_req_duration: ['p(95)<200'],
        http_req_failed: ['rate<0.01'],
    },
};

const baseURL = 'http://localhost:3000';
const items = ['burger', 'fries', 'pizza', 'soda', 'salad'];

function randomUserId() {
    return Math.floor(Math.random() * 1000) + 1;
}

function randomItemSet() {
    let selected = {};
    const count = Math.floor(Math.random() * 3) + 1;
    for (let i = 0; i < count; i++) {
        const item = items[Math.floor(Math.random() * items.length)];
        const quantity = Math.floor(Math.random() * 5) + 1;
        selected[item] = quantity;
    }
    return selected;
}

function createOrder(userId) {
    const payload = JSON.stringify({ order: { items: randomItemSet() } });
    return http.post(`${baseURL}/orders?user_id=${userId}`, payload, {
        headers: { 'Content-Type': 'application/json' },
    });
}

function getOrder(orderId) {
    return http.get(`${baseURL}/orders/${orderId}`);
}

function cancelOrder(orderId) {
    return http.post(`${baseURL}/orders/${orderId}/cancel`);
}

function updateOrderStatus(orderId, status) {
    return http.put(`${baseURL}/orders/${orderId}/update_status`, JSON.stringify({ status }), {
        headers: { 'Content-Type': 'application/json' },
    });
}

export default function () {
    const userId = randomUserId();
    const action = Math.floor(Math.random() * 4);

    let res;
    switch (action) {
        case 0:
            res = createOrder(userId);
            check(res, { 'order created': (r) => r.status === 201 || r.status === 202 });
            if (res.status === 201 || res.status === 202) {
                const orderId = res.json('id');
                if (orderId) {
                    sleep(0.1);
                    getOrder(orderId);
                    if (Math.random() < 0.5) cancelOrder(orderId);
                    else updateOrderStatus(orderId, 'Delivered');
                }
            }
            break;
        case 1:
            getOrder(Math.floor(Math.random() * 10000) + 1);
            break;
        case 2:
            cancelOrder(Math.floor(Math.random() * 10000) + 1);
            break;
        case 3:
            updateOrderStatus(Math.floor(Math.random() * 10000) + 1, 'Delivered');
            break;
    }

    sleep(Math.random() * 0.3);
}
