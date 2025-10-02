#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

BASE_URL="http://localhost:8000"
VALID_AUTH="admin:password123"
INVALID_AUTH="wrong:credentials"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}MoMo SMS Transaction API Test Suite${NC}"
echo -e "${BLUE}========================================${NC}\n"

# Test 1: GET all transactions with valid auth
echo -e "${GREEN}Test 1: GET /transactions (Valid Auth)${NC}"
curl -X GET $BASE_URL/transactions \
  -u $VALID_AUTH \
  -H "Content-Type: application/json"
echo -e "\n"

# Test 2: GET all transactions with invalid auth
echo -e "${RED}Test 2: GET /transactions (Invalid Auth - Should return 401)${NC}"
curl -X GET $BASE_URL/transactions \
  -u $INVALID_AUTH \
  -H "Content-Type: application/json"
echo -e "\n"

# Test 3: GET all transactions without auth
echo -e "${RED}Test 3: GET /transactions (No Auth - Should return 401)${NC}"
curl -X GET $BASE_URL/transactions \
  -H "Content-Type: application/json"
echo -e "\n"

# Test 4: GET single transaction
echo -e "${GREEN}Test 4: GET /transactions/1 (Valid Auth)${NC}"
curl -X GET $BASE_URL/transactions/1 \
  -u $VALID_AUTH \
  -H "Content-Type: application/json"
echo -e "\n"

# Test 5: POST new transaction
echo -e "${GREEN}Test 5: POST /transactions (Create New)${NC}"
curl -X POST $BASE_URL/transactions \
  -u $VALID_AUTH \
  -H "Content-Type: application/json" \
  -d '{
    "protocol": "0",
    "address": "182",
    "date": 1715351458724,
    "readable_date": "10 May 2024 5:00:00 PM",
    "body": "Test transaction created via API",
    "amount": 5000.0,
    "recipient_name": "Test User",
    "transaction_type": "payment",
    "new_balance": 15000.0,
    "fee": 100.0
  }'
echo -e "\n"

# Test 6: PUT update transaction
echo -e "${GREEN}Test 6: PUT /transactions/1 (Update)${NC}"
curl -X PUT $BASE_URL/transactions/1 \
  -u $VALID_AUTH \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 2500.0,
    "recipient_name": "Updated Recipient Name"
  }'
echo -e "\n"

# Test 7: DELETE transaction
echo -e "${GREEN}Test 7: DELETE /transactions/2 (Delete)${NC}"
curl -X DELETE $BASE_URL/transactions/2 \
  -u $VALID_AUTH \
  -H "Content-Type: application/json"
echo -e "\n"

# Test 8: GET non-existent transaction
echo -e "${RED}Test 8: GET /transactions/9999 (Not Found - Should return 404)${NC}"
curl -X GET $BASE_URL/transactions/9999 \
  -u $VALID_AUTH \
  -H "Content-Type: application/json"
echo -e "\n"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Test Suite Complete${NC}"
echo -e "${BLUE}========================================${NC}"