# KK Team - MoMo SMS Data Analyzer

## Team Information

**Team Name:** KK Team

**Project Description:**
Enterprise-level fullstack application for processing MoMo SMS data in XML format, cleaning and categorizing transactions, storing in a relational database, and providing a frontend interface for data analysis and visualization.

**Team Members:**

- Aime SHYAKA - [SHYAKA-Aime]
- Golbert Gautier Kamanzi - [kamanzi2025]
- Jotham Rutijana Jabo - [Rutijana]
- Rwema Christian Gashumba - [Rwema707]

## Project Overview

This application processes MoMo (Mobile Money) SMS transaction data through an ETL pipeline, stores it in a relational database, and provides analytical insights through a web dashboard.

## System Architecture

**Architecture Diagram:** https://drive.google.com/file/d/13Y0TeXwpu6Z7vND-cllienmW6l3AE1NR/view?usp=sharing

## Project Management

**Scrum Board (Trello) (Updated):** https://trello.com/invite/b/68c0458a13ff991b7f3fdf62/ATTI814d0df2eba6b66f5764829b196d81835097B29D/kk-team-momo-sms-etl-project

## Week 2 Implementation - Database Design & Implementation

This repository contains the complete database foundation for processing MoMo SMS transaction data, including:

- **Entity Relationship Diagram (ERD)** - Visual representation of database structure
- **SQL Database Schema** - Complete MySQL implementation with constraints and triggers
- **JSON Data Models** - API-ready serialization examples
- **Sample Data** - Test data based on real SMS patterns
- **Documentation** - Comprehensive system documentation

## Database Design Summary

Our database architecture is designed to efficiently process and analyze MoMo SMS transaction data while maintaining data integrity and supporting future scalability. The design transforms unstructured XML SMS data into a relational format suitable for business intelligence and analytics.

### Core Database Entities

1. **Users Table** - Stores customer information extracted from SMS data including phone numbers, names, account types, MoMo account IDs, and current balance information.

2. **Transactions Table** - The main entity storing SMS transaction data with essential XML metadata (sms_date, sms_body, readable_date) and extracted transaction details (amounts, fees, balances, recipient information).

3. **Transaction Categories Table** - Classification system for transaction categorization with four main types: payments, transfers, deposits, and airtime purchases.

4. **User Transaction History Table** - Junction table resolving the many-to-many relationship between users and transactions, tracking whether users are senders or receivers.

5. **System Logs Table** - Logging system for processing activities, warnings, and error tracking.

### Key Design Features

**Essential SMS Data Preservation:** Core SMS metadata (timestamps, message content, readable dates) preserved for audit trail and analysis capabilities.

**Transaction Categorization:** Four main categories (payment, transfer, deposit, airtime) for systematic transaction classification.

**Balance Tracking:** Current balance tracking from SMS data with transaction-level balance updates.

**Data Integrity:** Foreign key constraints and check constraints ensure data consistency and prevent invalid data entry.

**Many-to-Many Relationships:** Users can participate in multiple transactions as either senders or receivers, properly modeled through junction table.

**System Monitoring:** Processing logs for operational tracking and error detection.

## Key Relationships

- **Users and Transactions** (Many-to-Many via User_Transaction_History): Users can be senders/receivers in multiple transactions
- **Categories and Transactions** (One-to-Many): Each transaction belongs to exactly one category
- **System Logs**: Independent logging table for process monitoring

## Security & Data Integrity Features

The database implements essential security and data integrity measures:

- **Foreign Key Constraints** - Ensures referential integrity between related tables
- **Check Constraints** - Validates positive amounts and non-negative fees
- **Unique Constraints** - Prevents duplicate phone numbers and transaction references
- **Junction Table Management** - Maintains proper many-to-many relationships
- **System Logging** - Tracks processing activities and errors for monitoring

### Quick Start

1. **Clone Repository**

   ```bash
   git clone https://github.com/SHYAKA-Aime/KK-Team_momo-sms-analyzer-app.git
   cd momo-sms-analyzer
   ```

## Sample Usage

### Basic Transaction Query

```sql
-- Get recent transactions with user details
SELECT t.external_ref_id, t.amount, t.transaction_datetime,
       s.phone_number as sender, r.phone_number as receiver,
       tc.category_name
FROM transactions t
LEFT JOIN users s ON t.sender_id = s.user_id
LEFT JOIN users r ON t.receiver_id = r.user_id
JOIN transaction_categories tc ON t.category_id = tc.category_id
ORDER BY t.transaction_datetime DESC
LIMIT 10;
```

### Transaction Volume Analysis

```sql
-- Transaction volume by category
SELECT tc.category_name,
       COUNT(*) as transaction_count,
       SUM(t.amount) as total_volume,
       AVG(t.amount) as avg_amount
FROM transactions t
JOIN transaction_categories tc ON t.category_id = tc.category_id
WHERE t.status = 'completed'
GROUP BY tc.category_id
ORDER BY total_volume DESC;
```

## JSON API Examples

The system provides JSON serialization for all database entities. Example transaction API response:

```json
{
  "transaction_id": 1,
  "external_ref_id": "35617026753",
  "amount": 1500.0,
  "currency": "RWF",
  "transaction_datetime": "2024-05-24T16:41:03Z",
  "sender": {
    "phone_number": "+250795963036",
    "full_name": "Account Holder"
  },
  "receiver": {
    "full_name": "Alex Doe",
    "account_id": "22692"
  },
  "category": {
    "category_name": "Payment to Individual",
    "category_type": "payment"
  }
}
```
