# iSave Backend API

A backend API built with Ruby on Rails to manage and analyze a Customer's investment portfolios.

# Technologies:

Ruby version 3.3.1

Ruby on Rails 7 (API mode)

SQLite3 (default DB)

RSpec for testing

Rubocop for linting

API Documentation


## Progress Status

The current implementation covers:

- ✅ Level 1 – Display all customer portfolios with investment.
- ✅ Level 2 – Allow deposit, withdrawal, and arbitration (only for CTO and PEA).
- ✅ Level 3 – Portfolio insights (risk and allocation indicators).
- ✅ Level 4 – Historical values of portfolios.
- ⬜️ Level 4 – Yields computation (not implemented yet).
- ⬜️ Level 5 - (not implemented yet)

---

# Running Tests :

bundle exec rspec


# Development Setup :

bundle install

rails db:create db:migrate db:seed


# Seeds include:

One customer

3 portfolios (Assurance Vie, PEA, Portefeuille d'actions)

Sample investments

Historical values loaded via job

---

Base URL

http://localhost:3000/api/v1

---

## Endpoints Summary

| Method | Endpoint                                                  | Description                                 |
|--------|-----------------------------------------------------------|---------------------------------------------|
| GET    | `/customers/:id/portfolios`                               | List all portfolios for a customer          |
| POST   | `/customers/:customer_id/portfolios/:id/deposit`          | Deposit funds into an investment            |
| POST   | `/customers/:customer_id/portfolios/:id/withdraw`         | Withdraw funds from an investment           |
| POST   | `/customers/:customer_id/portfolios/:id/arbitrate`        | Move funds between investments              |
| GET    | `/customers/:customer_id/insights`                        | Get insights for a portfolio                |
| GET    | `/customers/:customer_id/portfolios/:id/historical_values`| Get historical valuation for a portfolio    |

---

### 1. Get Portfolios

**Request:** `GET /customers/:id/portfolios`

#### Success (200 OK)

```json
[
  {
    "id": 1,
    "label": "CTO Portfolio",
    "type": "CTO",
    "total_amount": 100000.0,
    "investments": [
      {
        "id": 1,
        "label": "Amundi ETF",
        "isin": "FR0000000001",
        "type": "ETF",
        "price": 100.0,
        "sri": 3,
        "amount_invested": 5000.0,
        "share": 5.0
      }
    ]
  }
]
```

#### Error (404)
```json
{ "error": "Customer not found" }
```

---

### 2. Deposit

**Request:** `POST /customers/:customer_id/portfolios/:id/deposit`

```json
{
  "investment_id": 1,
  "amount": 5000
}
```

####  Success (200 OK)

```json
{
  "message": "Deposit successful.",
  "investment": {
    "id": 1,
    "amount_invested": 15000.0
  },
  "total_portfolio_amount": 105000.0
}
```

#### Possible Errors

- **403 Forbidden**: Deposits are only allowed for CTO or PEA portfolios  
- **404 Not Found**: Portfolio or Investment not found  
- **422 Unprocessable Entity**: Amount must be positive  
- **422 Unprocessable Entity**: Other unexpected error (e.g., validation failed)


---

### 3. Withdraw

**Request:** `POST /customers/:customer_id/portfolios/:id/withdraw`

```json
{
  "investment_id": 1,
  "amount": 2000
}
```

#### Success (200 OK)

```json
{
  "message": "Withdrawal successful.",
  "investment": {
    "id": 1,
    "amount_invested": 8000.0
  },
  "total_portfolio_amount": 98000.0
}
```
### Possible Errors

- **403 Forbidden**: Withdrawals are only allowed for CTO and PEA portfolios  
- **404 Not Found**: Customer or investment not found  
- **422 Unprocessable Entity**: Not enough funds in this investment  
- **422 Unprocessable Entity**: Amount must be positive


### 4. Arbitrate (Move Funds)

**Request:** `POST /customers/:customer_id/portfolios/:id/arbitrate`

```json
{
  "from_investment_id": 1,
  "to_investment_id": 2,
  "amount": 3000
}
```

#### Success (200 OK)

```json
{
  "message": "Arbitrage completed successfully."
}
```

### Possible Errors

- **403 Forbidden**: Arbitration only allowed on CTO or PEA  
- **404 Not Found**: From investment not found in portfolio  
- **404 Not Found**: Destination investment not found in portfolio  
- **422 Unprocessable Entity**: Amount must be positive  
- **422 Unprocessable Entity**: Not enough funds  
- **422 Unprocessable Entity**: Unexpected error (from DB validations, etc.)

---

### 5. Get Portfolio Insights

**Request:** `GET /customers/:customer_id/insights`

#### Success (200 OK)

```json
{
  "risk": 4.6,
  "allocation_by_type": {
    "Stock": 60.0,
    "Bond": 40.0
  }
}
```

#### Possible Errors

Status | Message
404 | Customer not found

---

### 6. Get Historical Values

**Request:** `GET /customers/:customer_id/portfolios/:id/historical_values`

#### Success (200 OK)

```json
[
  {
    "date": "2023-01-01",
    "amount": 10000.0
  },
  {
    "date": "2023-02-01",
    "amount": 10250.0
  }
]
```

### Possible Errors

- **404 Not Found**: Customer or Portfolio not found


---

Tip: Test with curl

curl -X POST http://localhost:3000/api/v1/customers/{customer_id}/portfolios/{portfolio_id}/deposit \
-H "Content-Type: application/json" \
-d '{"investment_id": 33, "amount": 5000}'

curl -X POST "http://localhost:3000/api/v1/customers/{customer_id}/portfolios/{portfolio_id}/withdraw" \
-H "Content-Type: application/json" \
-d '{"investment_id": "{investment_id}", "amount": 5000}'

curl -X POST http://localhost:3000/api/v1/customers/{customer_id}/portfolios/{portfolio_id}/arbitrate \
-H "Content-Type: application/json" \
-d '{
  "from_investment_id": 29,
  "to_investment_id": 30,
  "amount": 10000
 }'

 curl -X GET http://localhost:3000/api/v1/customers/{customer_id}/insights 


curl -X GET http://localhost:3000/api/v1/customers/12/portfolios/{portfolio_id}/historical_values


OR test directly on chrome with : http://localhost:3000/api/v1/customers/12/portfolios/{portfolio_id}/historical_values for example
