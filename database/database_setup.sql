
CREATE DATABASE IF NOT EXISTS momo_sms_analyzer;
USE momo_sms_analyzer;

-- 1. USERS TABLE 
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    phone_number VARCHAR(15) UNIQUE COMMENT 'Phone number from SMS',
    full_name VARCHAR(100) COMMENT 'User name extracted from SMS',
    account_type ENUM('individual', 'business', 'agent') DEFAULT 'individual',
    momo_account_id VARCHAR(20) COMMENT 'MoMo account ID from SMS body',
    current_balance DECIMAL(15,2) COMMENT 'Latest balance from SMS',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_phone_number (phone_number),
    INDEX idx_account_id (momo_account_id)
) COMMENT 'MoMo users extracted from SMS data';

-- 2. TRANSACTION_CATEGORIES TABLE
CREATE TABLE transaction_categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) UNIQUE NOT NULL,
    category_type ENUM('payment', 'transfer', 'deposit', 'airtime') NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_category_type (category_type)
) COMMENT 'Transaction type categorization';

-- 3. TRANSACTIONS TABLE
CREATE TABLE transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    
    sms_date BIGINT NOT NULL COMMENT 'SMS timestamp from XML',
    sms_body TEXT NOT NULL COMMENT 'Full SMS message content',
    readable_date VARCHAR(50) COMMENT 'Human readable date',
    
    external_ref_id VARCHAR(50) COMMENT 'TxId from SMS',
    sender_id INT COMMENT 'FK to users table',
    receiver_id INT COMMENT 'FK to users table', 
    receiver_name VARCHAR(100) COMMENT 'Recipient name from SMS',
    receiver_phone VARCHAR(15) COMMENT 'Recipient phone from SMS',
    category_id INT NOT NULL COMMENT 'FK to transaction_categories',
    
    amount DECIMAL(15,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'RWF',
    transaction_fee DECIMAL(10,2) DEFAULT 0.00,
    new_balance DECIMAL(15,2) COMMENT 'Balance after transaction',
    
    transaction_datetime DATETIME NOT NULL COMMENT 'Parsed transaction time',
    status ENUM('completed', 'failed') DEFAULT 'completed',
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Key Constraints
    CONSTRAINT fk_transactions_sender FOREIGN KEY (sender_id) REFERENCES users(user_id),
    CONSTRAINT fk_transactions_receiver FOREIGN KEY (receiver_id) REFERENCES users(user_id),
    CONSTRAINT fk_transactions_category FOREIGN KEY (category_id) REFERENCES transaction_categories(category_id),
    
    -- Indexes
    INDEX idx_sms_date (sms_date),
    INDEX idx_transaction_datetime (transaction_datetime),
    INDEX idx_amount (amount),
    INDEX idx_external_ref (external_ref_id),
    INDEX idx_receiver_phone (receiver_phone),
    
    -- Constraints
    CONSTRAINT chk_amount_positive CHECK (amount > 0),
    CONSTRAINT chk_fee_non_negative CHECK (transaction_fee >= 0)
) COMMENT 'Core MoMo transaction records from SMS';

-- 4. USER_TRANSACTION_HISTORY
CREATE TABLE user_transaction_history (
    history_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    transaction_id INT NOT NULL,
    role_type ENUM('sender', 'receiver') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_history_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT fk_history_transaction FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id),
    
    UNIQUE KEY uk_user_transaction_role (user_id, transaction_id, role_type),
    INDEX idx_user_id (user_id),
    INDEX idx_transaction_id (transaction_id)
) COMMENT 'Many-to-many relationship between users and transactions';

-- 5. SYSTEM_LOGS
CREATE TABLE system_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    log_type ENUM('info', 'warning', 'error') NOT NULL,
    process_name VARCHAR(50) NOT NULL,
    message TEXT NOT NULL,
    transaction_ref VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_log_type (log_type),
    INDEX idx_created_at (created_at)
) COMMENT 'System processing logs';

-- INSERTING SAMPLE DATA

-- Transaction categories
INSERT INTO transaction_categories (category_name, category_type, description) VALUES
('Individual Payment', 'payment', 'Payment to named individual with account ID'),
('Money Transfer', 'transfer', 'Transfer to phone number'),
('Bank Deposit', 'deposit', 'Cash deposit to mobile money account'),
('Airtime Purchase', 'airtime', 'Mobile airtime purchase');

-- Sample users
INSERT INTO users (phone_number, full_name, account_type, momo_account_id, current_balance) VALUES
('+250795963036', 'Account Holder', 'individual', '36521838', 980.00),
('250791666666', 'Samuel Carter', 'individual', '95464', NULL),
('250790777777', 'Samuel Carter', 'individual', NULL, NULL),
('250788999999', 'Samuel Carter', 'individual', NULL, NULL),
('+250791666666', 'Alex Doe', 'individual', NULL, NULL);

-- Sample transactions
INSERT INTO transactions (
    sms_date, sms_body, readable_date, external_ref_id, 
    sender_id, receiver_id, receiver_name, category_id,
    amount, transaction_fee, new_balance, transaction_datetime, status
) VALUES
-- Received money 
(1715351458724, 
 'You have received 2000 RWF from Jane Smith (*********013) on your mobile money account at 2024-05-10 16:30:51. Message from sender: . Your new balance:2000 RWF. Financial Transaction Id: 76662021700.',
 '10 May 2024 4:30:58 PM', '76662021700', NULL, 1, 'Jane Smith', 2,
 2000.00, 0.00, 2000.00, '2024-05-10 16:30:51', 'completed'),

-- Payment to 
(1715351506754,
 'TxId: 73214484437. Your payment of 1,000 RWF to Jane Smith 12845 has been completed at 2024-05-10 16:31:39. Your new balance: 1,000 RWF. Fee was 0 RWF.Kanda*182*16# wiyandikishe muri poromosiyo ya BivaMoMotima, ugire amahirwe yo gutsindira ibihembo bishimishije.',
 '10 May 2024 4:31:46 PM', '73214484437', 1, NULL, 'Jane Smith', 1,
 1000.00, 0.00, 1000.00, '2024-05-10 16:31:39', 'completed'),

-- Payment to
(1715369560245,
 'TxId: 51732411227. Your payment of 600 RWF to Samuel Carter 95464 has been completed at 2024-05-10 21:32:32. Your new balance: 400 RWF. Fee was 0 RWF.Kanda*182*16# wiyandikishe muri poromosiyo ya BivaMoMotima, ugire amahirwe yo gutsindira ibihembo bishimishije.',
 '10 May 2024 9:32:40 PM', '51732411227', 1, 2, 'Samuel Carter', 1,
 600.00, 0.00, 400.00, '2024-05-10 21:32:32', 'completed'),

-- Bank deposit
(1715445936412,
 '*113*R*A bank deposit of 40000 RWF has been added to your mobile money account at 2024-05-11 18:43:49. Your NEW BALANCE :40400 RWF. Cash Deposit::CASH::::0::250795963036.Thank you for using MTN MobileMoney.*EN#',
 '11 May 2024 6:45:36 PM', NULL, NULL, 1, 'CASH DEPOSIT', 3,
 40000.00, 0.00, 40400.00, '2024-05-11 18:43:49', 'completed'),

-- Airtime purchase
(1715506895734,
 '*162*TxId:13913173274*S*Your payment of 2000 RWF to Airtime with token has been completed at 2024-05-12 11:41:28. Fee was 0 RWF. Your new balance: 25280 RWF . Message: - -. *EN#',
 '12 May 2024 11:41:35 AM', '13913173274', 1, NULL, 'Airtime', 4,
 2000.00, 0.00, 25280.00, '2024-05-12 11:41:28', 'completed');

-- Populate junction table
INSERT INTO user_transaction_history (user_id, transaction_id, role_type) VALUES
(1, 1, 'receiver'),  -- Received from Jane Smith
(1, 2, 'sender'),    -- Paid Jane Smith
(1, 3, 'sender'),    -- Paid Samuel Carter  
(2, 3, 'receiver'),  -- Samuel received payment
(1, 4, 'receiver'),  -- Received bank deposit
(1, 5, 'sender');    -- Bought airtime

-- Sample system logs
INSERT INTO system_logs (log_type, process_name, message, transaction_ref) VALUES
('info', 'xml_parser', 'Successfully processed XML file with 5 transactions', NULL),
('info', 'sms_processor', 'Extracted transaction data from SMS messages', NULL),
('warning', 'balance_tracker', 'Large deposit detected', '40000'),
('info', 'categorizer', 'All transactions categorized successfully', NULL);

-- Sample queries to demonstrate functionality
SELECT 'User Transaction Summary:' as description;
SELECT u.full_name, u.phone_number, u.current_balance,
       COUNT(t.transaction_id) as total_transactions,
       SUM(CASE WHEN uth.role_type = 'sender' THEN t.amount ELSE 0 END) as total_sent,
       SUM(CASE WHEN uth.role_type = 'receiver' THEN t.amount ELSE 0 END) as total_received
FROM users u
LEFT JOIN user_transaction_history uth ON u.user_id = uth.user_id
LEFT JOIN transactions t ON uth.transaction_id = t.transaction_id
GROUP BY u.user_id, u.full_name, u.phone_number, u.current_balance;

SELECT 'Transaction Categories Summary:' as description;
SELECT tc.category_name, tc.category_type, 
       COUNT(t.transaction_id) as transaction_count,
       SUM(t.amount) as total_amount
FROM transaction_categories tc
LEFT JOIN transactions t ON tc.category_id = t.category_id
GROUP BY tc.category_id, tc.category_name, tc.category_type;