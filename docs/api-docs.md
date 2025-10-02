# MoMo SMS Transaction API - Setup Instructions

## Project Structure

```
.
├── api/
│   └── api_server.py           # REST API implementation
├── dsa/
│   ├── parse_xml.py            # XML parser
│   └── dsa_search.py           # Search algorithms comparison
├── data/
│   ├── raw/
│   │   └── modified_sms_v2.xml # Input XML file (place here)
│   └── processed/
│       └── transactions.json    # Generated JSON output
├── docs/
│   └── api_docs.md             # API documentation
├── screenshots/                 # Test screenshots go here
├── scripts/
│   └── test_commands.sh        # Automated test script
└── requirements.txt            # Python dependencies (none needed)
```

## Prerequisites

- Python 3

## Setup Steps

### 1. Clone/Download Project

```bash
cd KK-Team-sms-api
```

### 3. Add XML Data

Place the `modified_sms_v2.xml` file in `data/raw/` directory.

### 4. Parse XML Data

```bash
python dsa/parse_xml.py
```

This will generate `data/processed/transactions.json` with all parsed transactions.

### 5. Run DSA Performance Test

```bash
python dsa/dsa_search.py
```

This will compare linear search vs dictionary lookup performance.

## Running the API Server

### Start Server

```bash
python api/api_server.py
```

The server will start on `http://localhost:8000`

### Authentication Credentials

- **Username:** `kkteam`
- **Password:** `password123`

## Testing the API

### Option 1: Using the Test Script

```bash
chmod +x scripts/test_commands.sh
bash scripts/test_commands.sh
```

### Option 2: Manual cURL Commands

#### Test Valid Authentication

```bash
curl -X GET http://localhost:8000/transactions \
  -u admin:password123
```

#### Test Invalid Authentication

```bash
curl -X GET http://localhost:8000/transactions \
  -u wrong:credentials
```

#### Get Single Transaction

```bash
curl -X GET http://localhost:8000/transactions/1 \
  -u admin:password123
```

#### Create Transaction

```bash
curl -X POST http://localhost:8000/transactions \
  -u admin:password123 \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 5000.0,
    "recipient_name": "John Doe",
    "transaction_type": "payment"
  }'
```

#### Update Transaction

```bash
curl -X PUT http://localhost:8000/transactions/1 \
  -u admin:password123 \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 2500.0
  }'
```

#### Delete Transaction

```bash
curl -X DELETE http://localhost:8000/transactions/1 \
  -u admin:password123
```

### Option 3: Using Postman

1. Import the endpoints from `docs/api_docs.md`
2. Set Authorization type to "Basic Auth"
3. Enter username: `admin`, password: `password123`
4. Test each endpoint
