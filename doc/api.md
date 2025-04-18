API Documentation – iSave Backend

This document describes all available endpoints for managing customer portfolios and investments in the iSave backend API.

---

Base URL

http://localhost:3000/api/v1


---

Access Rules

- A customer can only access their own portfolios
- Only portfolios of type "CTO" or "PEA" support:
  - Deposit
  - Withdraw
  - Arbitration (move between investments)

---

Endpoints Summary

| Method | Endpoint                                                  | Description                        |
|--------|-----------------------------------------------------------|------------------------------------|
| GET    | `/customers/:id/portfolios`                               | List all portfolios for a customer |
| POST   | `/customers/:customer_id/portfolios/:id/deposit`          | Deposit funds into an investment   |
| POST   | `/customers/:customer_id/portfolios/:id/withdraw`         | Withdraw funds from an investment  |
| POST   | `/customers/:customer_id/portfolios/:id/arbitrate`        | Move funds between investments     |

---

1. Get Portfolios

Request: GET /customers/:id/portfolios


### Success (200 OK)

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


Error (404)

{ "error": "Customer not found" }

2. Deposit

Request: POST /customers/:customer_id/portfolios/:id/deposit

{
  "investment_id": 1,
  "amount": 5000
}

Success (200 OK)

{
  "message": "Deposit successful.",
  "investment": {
    "id": 1,
    "amount_invested": 15000.0
  },
  "total_portfolio_amount": 105000.0
}


Possible Errors

Status	Message
403	Changes are only allowed on CTO or PEA
403	You are not authorized to access this portfolio
422	Amount must be positive
404	Investment not found in portfolio


 3. Withdraw
Request: POST /customers/:customer_id/portfolios/:id/withdraw

{
  "investment_id": 1,
  "amount": 2000
}

Success (200 OK)

{
  "message": "Withdrawal successful.",
  "investment": {
    "id": 1,
    "amount_invested": 8000.0
  },
  "total_portfolio_amount": 98000.0
}

Possible Errors

Status	Message
403	Not allowed on this portfolio
403	You are not authorized to access this portfolio
422	Not enough funds
422	Amount must be positive
404	Investment not found in portfolio

4. Arbitrate (Move Funds)
Request: POST /customers/:customer_id/portfolios/:id/arbitrate

{
  "from_investment_id": 1,
  "to_investment_id": 2,
  "amount": 3000
}

Success (200 OK)
{
  "message": "Arbitrage completed successfully."
}


Possible Errors

Status	Message
403	You are not authorized to access this portfolio
403	Arbitration only allowed on CTO or PEA
422	Not enough funds
422	Amount must be positive
404	From investment not found in portfolio
404	To investment not found in portfolio


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


