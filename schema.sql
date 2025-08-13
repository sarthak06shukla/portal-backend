-- Report Types Table
CREATE TABLE report_types (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    display_name TEXT NOT NULL,
    description TEXT NOT NULL,
    table_name TEXT NOT NULL UNIQUE,
    query_name TEXT
);

-- Column Configurations Table
CREATE TABLE column_configs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    table_name TEXT NOT NULL,
    column_name TEXT NOT NULL,
    display_name TEXT NOT NULL,
    data_type TEXT NOT NULL,
    is_visible BOOLEAN NOT NULL DEFAULT true,
    sort_order INTEGER NOT NULL,
    UNIQUE(table_name, column_name)
);

-- Stock Prices Table
CREATE TABLE stock_prices (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    company TEXT NOT NULL,
    date DATE NOT NULL,
    open_price REAL NOT NULL,
    high_price REAL NOT NULL,
    low_price REAL NOT NULL,
    close_price REAL NOT NULL,
    volume INTEGER NOT NULL
);

-- Financial Metrics Table
CREATE TABLE financial_metrics (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    company TEXT NOT NULL,
    date DATE NOT NULL,
    pe_ratio REAL,
    market_cap REAL,
    book_value REAL,
    debt_to_equity REAL,
    current_ratio REAL,
    roce REAL
);

-- Performance Table
CREATE TABLE performance (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    company TEXT NOT NULL,
    date DATE NOT NULL,
    returns_1m REAL,
    returns_3m REAL,
    returns_6m REAL,
    returns_1y REAL,
    volatility REAL,
    beta REAL
);

-- Dividend Table
CREATE TABLE dividend (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    company TEXT NOT NULL,
    date DATE NOT NULL,
    dividend_yield REAL,
    payout_ratio REAL,
    dividend_per_share REAL,
    dividend_growth REAL,
    is_eligible TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Technical Indicators Table
CREATE TABLE technical_indicators (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    company TEXT NOT NULL,
    date DATE NOT NULL,
    rsi_14 REAL,
    macd REAL,
    macd_signal REAL,
    ma_20 REAL,
    ma_50 REAL,
    ma_200 REAL,
    bollinger_upper REAL,
    bollinger_middle REAL,
    bollinger_lower REAL,
    atr REAL,
    stochastic_k REAL,
    stochastic_d REAL
);

-- New Profit Report Table
CREATE TABLE profit_report (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    application_no TEXT NOT NULL,
    symbol TEXT NOT NULL,
    company_name TEXT NOT NULL,
    period_type TEXT,
    period_end_dt TEXT,
    net_profit_loss_for_t INTEGER,
    from_date TEXT,
    to_date TEXT,
    audited_unaudited TEXT,
    consolidated TEXT,
    indasnonind TEXT,
    rf_result_format TEXT
);

-- Developer Queries Table
CREATE TABLE developer_queries (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    variation_name TEXT,
    query TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending', -- 'pending', 'approved', 'rejected'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better performance
CREATE INDEX idx_stock_prices_company_date ON stock_prices(company, date);
CREATE INDEX idx_financial_metrics_company_date ON financial_metrics(company, date);
CREATE INDEX idx_performance_company_date ON performance(company, date);
CREATE INDEX idx_dividend_company_date ON dividend(company, date);
CREATE INDEX idx_technical_indicators_company_date ON technical_indicators(company, date);

-- Insert Report Types
INSERT INTO report_types (name, display_name, description, table_name, query_name) VALUES
('stock_prices', 'Stock Prices', 'Daily stock price information including open, high, low, close prices and volume', 'stock_prices', 'Stock Prices'),
('financial_metrics', 'Financial Metrics', 'Key financial metrics including P/E ratio, market cap, and other important ratios', 'financial_metrics', 'Financial Metrics'),
('performance', 'Performance', 'Performance metrics including returns over different periods and risk measures', 'performance', 'Performance'),
('dividend', 'Dividend', 'Dividend related metrics including yield and payout information', 'dividend', 'Dividend'),
('technical_indicators', 'Technical Indicators', 'Technical analysis indicators including RSI, MACD, Moving Averages, and more', 'technical_indicators', 'Technical Indicators'),
('profit_report', 'Profit Report', 'Comprehensive profit and loss data including application details, period information, and net profit/loss', 'profit_report', 'Profit Report');

-- Insert Column Configurations
-- Stock Prices
INSERT INTO column_configs (table_name, column_name, display_name, data_type, is_visible, sort_order) VALUES
('stock_prices', 'company', 'Company', 'text', true, 1),
('stock_prices', 'date', 'Date', 'date', true, 2),
('stock_prices', 'open', 'Open', 'number', true, 3),
('stock_prices', 'high', 'High', 'number', true, 4),
('stock_prices', 'low', 'Low', 'number', true, 5),
('stock_prices', 'close', 'Close', 'number', true, 6),
('stock_prices', 'volume', 'Volume', 'number', true, 7);

-- Financial Metrics
INSERT INTO column_configs (table_name, column_name, display_name, data_type, is_visible, sort_order) VALUES
('financial_metrics', 'company', 'Company', 'text', true, 1),
('financial_metrics', 'date', 'Date', 'date', true, 2),
('financial_metrics', 'revenue', 'Revenue', 'number', true, 3),
('financial_metrics', 'profit', 'Profit', 'number', true, 4),
('financial_metrics', 'eps', 'EPS', 'number', true, 5),
('financial_metrics', 'pe_ratio', 'P/E Ratio', 'number', true, 6),
('financial_metrics', 'market_cap', 'Market Cap (Cr)', 'number', true, 7),
('financial_metrics', 'book_value', 'Book Value', 'number', true, 8),
('financial_metrics', 'debt_to_equity', 'Debt to Equity', 'number', true, 9),
('financial_metrics', 'current_ratio', 'Current Ratio', 'number', true, 10),
('financial_metrics', 'roce', 'ROCE (%)', 'number', true, 11);

-- Performance
INSERT INTO column_configs (table_name, column_name, display_name, data_type, is_visible, sort_order) VALUES
('performance', 'company', 'Company', 'text', true, 1),
('performance', 'date', 'Date', 'date', true, 2),
('performance', 'return_1d', '1D Return', 'number', true, 3),
('performance', 'return_1w', '1W Return', 'number', true, 4),
('performance', 'return_1m', '1M Return', 'number', true, 5),
('performance', 'return_1y', '1Y Return', 'number', true, 6),
('performance', 'volatility', 'Volatility (%)', 'number', true, 7),
('performance', 'beta', 'Beta', 'number', true, 8);

-- Dividend
INSERT INTO column_configs (table_name, column_name, display_name, data_type, is_visible, sort_order) VALUES
('dividend', 'company', 'Company', 'text', true, 1),
('dividend', 'date', 'Date', 'date', true, 2),
('dividend', 'dividend_amount', 'Dividend Amount', 'number', true, 3),
('dividend', 'dividend_type', 'Dividend Type', 'text', true, 4),
('dividend', 'payout_ratio', 'Payout Ratio (%)', 'number', true, 5),
('dividend', 'dividend_per_share', 'DPS (₹)', 'number', true, 6),
('dividend', 'dividend_growth', 'Dividend Growth (%)', 'number', true, 7),
('dividend', 'is_eligible', 'Eligible for Dividend', 'text', true, 8);

-- Technical Indicators
INSERT INTO column_configs (table_name, column_name, display_name, data_type, is_visible, sort_order) VALUES
('technical_indicators', 'company', 'Company', 'text', true, 1),
('technical_indicators', 'date', 'Date', 'date', true, 2),
('technical_indicators', 'rsi', 'RSI', 'number', true, 3),
('technical_indicators', 'macd', 'MACD', 'number', true, 4),
('technical_indicators', 'macd_signal', 'MACD Signal', 'number', true, 5),
('technical_indicators', 'ma_20', '20-day MA', 'number', true, 6),
('technical_indicators', 'ma_50', '50-day MA', 'number', true, 7),
('technical_indicators', 'ma_200', '200-day MA', 'number', true, 8),
('technical_indicators', 'bollinger_upper', 'Bollinger Upper', 'number', true, 9),
('technical_indicators', 'bollinger_middle', 'Bollinger Middle', 'number', true, 10),
('technical_indicators', 'bollinger_lower', 'Bollinger Lower', 'number', true, 11),
('technical_indicators', 'atr', 'ATR', 'number', true, 12),
('technical_indicators', 'stochastic_k', 'Stochastic %K', 'number', true, 13),
('technical_indicators', 'stochastic_d', 'Stochastic %D', 'number', true, 14);

-- Insert comprehensive sample data
INSERT INTO stock_prices (company, date, open_price, high_price, low_price, close_price, volume) VALUES
-- TCS
('TCS', '2024-01-01', 3500.00, 3550.00, 3480.00, 3520.00, 1000000),
('TCS', '2024-01-02', 3520.00, 3580.00, 3510.00, 3565.00, 950000),
('TCS', '2024-01-03', 3565.00, 3600.00, 3540.00, 3585.00, 1200000),
-- Infosys
('Infosys', '2024-01-01', 1500.00, 1520.00, 1480.00, 1510.00, 800000),
('Infosys', '2024-01-02', 1510.00, 1535.00, 1505.00, 1525.00, 750000),
('Infosys', '2024-01-03', 1525.00, 1540.00, 1515.00, 1530.00, 900000),
-- HDFC Bank
('HDFC Bank', '2024-01-01', 1600.00, 1620.00, 1580.00, 1615.00, 900000),
('HDFC Bank', '2024-01-02', 1615.00, 1630.00, 1610.00, 1625.00, 850000),
('HDFC Bank', '2024-01-03', 1625.00, 1645.00, 1620.00, 1640.00, 950000),
-- Reliance Industries
('Reliance', '2024-01-01', 2500.00, 2550.00, 2480.00, 2530.00, 1500000),
('Reliance', '2024-01-02', 2530.00, 2580.00, 2520.00, 2565.00, 1400000),
('Reliance', '2024-01-03', 2565.00, 2600.00, 2550.00, 2585.00, 1600000),
-- ITC
('ITC', '2024-01-01', 450.00, 455.00, 448.00, 452.00, 2000000),
('ITC', '2024-01-02', 452.00, 458.00, 450.00, 456.00, 1800000),
('ITC', '2024-01-03', 456.00, 460.00, 454.00, 458.00, 2200000),
-- Bharti Airtel
('Bharti Airtel', '2024-01-01', 950.00, 965.00, 945.00, 960.00, 1200000),
('Bharti Airtel', '2024-01-02', 960.00, 975.00, 955.00, 970.00, 1100000),
('Bharti Airtel', '2024-01-03', 970.00, 985.00, 965.00, 980.00, 1300000),
-- HUL
('HUL', '2024-01-01', 2600.00, 2620.00, 2580.00, 2610.00, 600000),
('HUL', '2024-01-02', 2610.00, 2630.00, 2600.00, 2625.00, 550000),
('HUL', '2024-01-03', 2625.00, 2645.00, 2615.00, 2635.00, 700000),
-- Axis Bank
('Axis Bank', '2024-01-01', 1100.00, 1115.00, 1095.00, 1110.00, 1500000),
('Axis Bank', '2024-01-02', 1110.00, 1125.00, 1105.00, 1120.00, 1400000),
('Axis Bank', '2024-01-03', 1120.00, 1135.00, 1115.00, 1130.00, 1600000),
-- Wipro
('Wipro', '2024-01-01', 450.00, 455.00, 445.00, 452.00, 900000),
('Wipro', '2024-01-02', 452.00, 458.00, 450.00, 455.00, 850000),
('Wipro', '2024-01-03', 455.00, 460.00, 452.00, 458.00, 950000),
-- SBI
('SBI', '2024-01-01', 620.00, 625.00, 615.00, 622.00, 2500000),
('SBI', '2024-01-02', 622.00, 628.00, 620.00, 625.00, 2300000),
('SBI', '2024-01-03', 625.00, 630.00, 622.00, 628.00, 2600000);

-- Sample Financial Metrics
INSERT INTO financial_metrics (company, date, pe_ratio, market_cap, book_value, debt_to_equity, current_ratio, roce) VALUES
-- TCS
('TCS', '2024-01-01', 28.5, 12500.00, 250.00, 0.12, 3.2, 25.5),
('TCS', '2024-01-02', 28.7, 12600.00, 250.00, 0.12, 3.2, 25.6),
('TCS', '2024-01-03', 28.8, 12650.00, 250.00, 0.12, 3.2, 25.7),
-- Infosys
('Infosys', '2024-01-01', 24.2, 7200.00, 180.00, 0.08, 4.1, 28.2),
('Infosys', '2024-01-02', 24.4, 7250.00, 180.00, 0.08, 4.1, 28.3),
('Infosys', '2024-01-03', 24.5, 7280.00, 180.00, 0.08, 4.1, 28.4),
-- HDFC Bank
('HDFC Bank', '2024-01-01', 22.8, 9800.00, 950.00, 0.45, 1.8, 18.5),
('HDFC Bank', '2024-01-02', 22.9, 9850.00, 950.00, 0.45, 1.8, 18.6),
('HDFC Bank', '2024-01-03', 23.0, 9900.00, 950.00, 0.45, 1.8, 18.7),
-- Reliance Industries
('Reliance', '2024-01-01', 25.5, 15800.00, 1150.00, 0.65, 1.5, 15.8),
('Reliance', '2024-01-02', 25.6, 15900.00, 1150.00, 0.65, 1.5, 15.9),
('Reliance', '2024-01-03', 25.7, 16000.00, 1150.00, 0.65, 1.5, 16.0),
-- ITC
('ITC', '2024-01-01', 20.5, 5500.00, 220.00, 0.15, 2.8, 22.5),
('ITC', '2024-01-02', 20.6, 5550.00, 220.00, 0.15, 2.8, 22.6),
('ITC', '2024-01-03', 20.7, 5580.00, 220.00, 0.15, 2.8, 22.7),
-- Bharti Airtel
('Bharti Airtel', '2024-01-01', 26.8, 6800.00, 280.00, 1.2, 1.2, 12.5),
('Bharti Airtel', '2024-01-02', 26.9, 6850.00, 280.00, 1.2, 1.2, 12.6),
('Bharti Airtel', '2024-01-03', 27.0, 6900.00, 280.00, 1.2, 1.2, 12.7),
-- HUL
('HUL', '2024-01-01', 32.5, 8200.00, 185.00, 0.05, 2.5, 28.5),
('HUL', '2024-01-02', 32.6, 8250.00, 185.00, 0.05, 2.5, 28.6),
('HUL', '2024-01-03', 32.7, 8280.00, 185.00, 0.05, 2.5, 28.7),
-- Axis Bank
('Axis Bank', '2024-01-01', 18.5, 4200.00, 420.00, 0.85, 1.6, 15.5),
('Axis Bank', '2024-01-02', 18.6, 4250.00, 420.00, 0.85, 1.6, 15.6),
('Axis Bank', '2024-01-03', 18.7, 4280.00, 420.00, 0.85, 1.6, 15.7),
-- Wipro
('Wipro', '2024-01-01', 22.5, 3200.00, 150.00, 0.10, 3.5, 24.5),
('Wipro', '2024-01-02', 22.6, 3250.00, 150.00, 0.10, 3.5, 24.6),
('Wipro', '2024-01-03', 22.7, 3280.00, 150.00, 0.10, 3.5, 24.7),
-- SBI
('SBI', '2024-01-01', 15.8, 7500.00, 580.00, 0.95, 1.4, 14.5),
('SBI', '2024-01-02', 15.9, 7550.00, 580.00, 0.95, 1.4, 14.6),
('SBI', '2024-01-03', 16.0, 7580.00, 580.00, 0.95, 1.4, 14.7);

-- Sample Performance Data
INSERT INTO performance (company, date, returns_1m, returns_3m, returns_6m, returns_1y, volatility, beta) VALUES
-- TCS
('TCS', '2024-01-01', 5.2, 12.5, 18.2, 25.5, 15.2, 0.85),
('TCS', '2024-01-02', 5.4, 12.8, 18.5, 25.8, 15.2, 0.85),
('TCS', '2024-01-03', 5.6, 13.0, 18.8, 26.0, 15.2, 0.85),
-- Infosys
('Infosys', '2024-01-01', 3.8, 8.2, 15.5, 22.8, 18.5, 0.92),
('Infosys', '2024-01-02', 4.0, 8.5, 15.8, 23.0, 18.5, 0.92),
('Infosys', '2024-01-03', 4.2, 8.8, 16.0, 23.2, 18.5, 0.92),
-- HDFC Bank
('HDFC Bank', '2024-01-01', 4.5, 10.8, 16.8, 28.2, 16.8, 1.12),
('HDFC Bank', '2024-01-02', 4.7, 11.0, 17.0, 28.5, 16.8, 1.12),
('HDFC Bank', '2024-01-03', 4.9, 11.2, 17.2, 28.8, 16.8, 1.12),
-- Reliance Industries
('Reliance', '2024-01-01', 6.5, 15.2, 22.5, 32.8, 20.5, 1.25),
('Reliance', '2024-01-02', 6.7, 15.5, 22.8, 33.0, 20.5, 1.25),
('Reliance', '2024-01-03', 6.9, 15.8, 23.0, 33.2, 20.5, 1.25),
-- ITC
('ITC', '2024-01-01', 2.8, 7.5, 12.8, 18.5, 14.2, 0.75),
('ITC', '2024-01-02', 3.0, 7.8, 13.0, 18.8, 14.2, 0.75),
('ITC', '2024-01-03', 3.2, 8.0, 13.2, 19.0, 14.2, 0.75),
-- Bharti Airtel
('Bharti Airtel', '2024-01-01', 5.8, 14.2, 20.5, 28.8, 22.5, 1.15),
('Bharti Airtel', '2024-01-02', 6.0, 14.5, 20.8, 29.0, 22.5, 1.15),
('Bharti Airtel', '2024-01-03', 6.2, 14.8, 21.0, 29.2, 22.5, 1.15),
-- HUL
('HUL', '2024-01-01', 3.2, 8.5, 14.2, 20.5, 12.8, 0.65),
('HUL', '2024-01-02', 3.4, 8.8, 14.5, 20.8, 12.8, 0.65),
('HUL', '2024-01-03', 3.6, 9.0, 14.8, 21.0, 12.8, 0.65),
-- Axis Bank
('Axis Bank', '2024-01-01', 5.5, 12.8, 19.5, 26.8, 24.5, 1.35),
('Axis Bank', '2024-01-02', 5.7, 13.0, 19.8, 27.0, 24.5, 1.35),
('Axis Bank', '2024-01-03', 5.9, 13.2, 20.0, 27.2, 24.5, 1.35),
-- Wipro
('Wipro', '2024-01-01', 2.5, 6.8, 11.5, 16.8, 16.5, 0.95),
('Wipro', '2024-01-02', 2.7, 7.0, 11.8, 17.0, 16.5, 0.95),
('Wipro', '2024-01-03', 2.9, 7.2, 12.0, 17.2, 16.5, 0.95),
-- SBI
('SBI', '2024-01-01', 6.2, 15.5, 22.8, 32.5, 25.8, 1.45),
('SBI', '2024-01-02', 6.4, 15.8, 23.0, 32.8, 25.8, 1.45),
('SBI', '2024-01-03', 6.6, 16.0, 23.2, 33.0, 25.8, 1.45);

-- Sample Dividend Data
INSERT INTO dividend (company, date, dividend_yield, payout_ratio, dividend_per_share, dividend_growth) VALUES
-- TCS
('TCS', '2024-01-01', 3.5, 45.2, 75.00, 12.5),
('TCS', '2024-01-02', 3.5, 45.2, 75.00, 12.5),
('TCS', '2024-01-03', 3.5, 45.2, 75.00, 12.5),
-- Infosys
('Infosys', '2024-01-01', 2.8, 42.8, 35.00, 8.2),
('Infosys', '2024-01-02', 2.8, 42.8, 35.00, 8.2),
('Infosys', '2024-01-03', 2.8, 42.8, 35.00, 8.2),
-- HDFC Bank
('HDFC Bank', '2024-01-01', 1.2, 22.5, 15.00, 15.8),
('HDFC Bank', '2024-01-02', 1.2, 22.5, 15.00, 15.8),
('HDFC Bank', '2024-01-03', 1.2, 22.5, 15.00, 15.8),
-- Reliance Industries
('Reliance', '2024-01-01', 0.8, 15.5, 8.00, 18.5),
('Reliance', '2024-01-02', 0.8, 15.5, 8.00, 18.5),
('Reliance', '2024-01-03', 0.8, 15.5, 8.00, 18.5),
-- ITC
('ITC', '2024-01-01', 4.2, 65.5, 12.50, 10.2),
('ITC', '2024-01-02', 4.2, 65.5, 12.50, 10.2),
('ITC', '2024-01-03', 4.2, 65.5, 12.50, 10.2),
-- Bharti Airtel
('Bharti Airtel', '2024-01-01', 1.5, 25.8, 10.00, 14.5),
('Bharti Airtel', '2024-01-02', 1.5, 25.8, 10.00, 14.5),
('Bharti Airtel', '2024-01-03', 1.5, 25.8, 10.00, 14.5),
-- HUL
('HUL', '2024-01-01', 2.5, 55.2, 45.00, 9.8),
('HUL', '2024-01-02', 2.5, 55.2, 45.00, 9.8),
('HUL', '2024-01-03', 2.5, 55.2, 45.00, 9.8),
-- Axis Bank
('Axis Bank', '2024-01-01', 1.0, 18.5, 8.00, 16.5),
('Axis Bank', '2024-01-02', 1.0, 18.5, 8.00, 16.5),
('Axis Bank', '2024-01-03', 1.0, 18.5, 8.00, 16.5),
-- Wipro
('Wipro', '2024-01-01', 2.2, 38.5, 7.00, 7.5),
('Wipro', '2024-01-02', 2.2, 38.5, 7.00, 7.5),
('Wipro', '2024-01-03', 2.2, 38.5, 7.00, 7.5),
-- SBI
('SBI', '2024-01-01', 1.8, 28.5, 8.50, 12.8),
('SBI', '2024-01-02', 1.8, 28.5, 8.50, 12.8),
('SBI', '2024-01-03', 1.8, 28.5, 8.50, 12.8);

-- Sample Technical Indicators
INSERT INTO technical_indicators (company, date, rsi_14, macd, macd_signal, ma_20, ma_50, ma_200, bollinger_upper, bollinger_middle, bollinger_lower, atr, stochastic_k, stochastic_d) VALUES
-- TCS
('TCS', '2024-01-01', 65.2, 25.8, 22.5, 3480.00, 3450.00, 3380.00, 3580.00, 3500.00, 3420.00, 45.2, 75.5, 72.8),
('TCS', '2024-01-02', 66.5, 26.2, 23.0, 3485.00, 3455.00, 3385.00, 3585.00, 3505.00, 3425.00, 45.5, 76.8, 73.5),
('TCS', '2024-01-03', 67.8, 26.5, 23.5, 3490.00, 3460.00, 3390.00, 3590.00, 3510.00, 3430.00, 45.8, 77.2, 74.2),
-- Infosys
('Infosys', '2024-01-01', 58.5, 15.2, 14.8, 1495.00, 1480.00, 1450.00, 1540.00, 1500.00, 1460.00, 28.5, 68.2, 65.5),
('Infosys', '2024-01-02', 59.8, 15.5, 15.0, 1500.00, 1485.00, 1455.00, 1545.00, 1505.00, 1465.00, 28.8, 69.5, 66.8),
('Infosys', '2024-01-03', 60.2, 15.8, 15.2, 1505.00, 1490.00, 1460.00, 1550.00, 1510.00, 1470.00, 29.2, 70.8, 67.2),
-- HDFC Bank
('HDFC Bank', '2024-01-01', 62.8, 18.5, 17.2, 1605.00, 1590.00, 1550.00, 1650.00, 1600.00, 1550.00, 35.8, 72.5, 70.2),
('HDFC Bank', '2024-01-02', 63.5, 18.8, 17.5, 1610.00, 1595.00, 1555.00, 1655.00, 1605.00, 1555.00, 36.2, 73.8, 71.5),
('HDFC Bank', '2024-01-03', 64.2, 19.2, 17.8, 1615.00, 1600.00, 1560.00, 1660.00, 1610.00, 1560.00, 36.5, 74.2, 72.8),
-- Reliance Industries
('Reliance', '2024-01-01', 70.5, 35.2, 32.5, 2520.00, 2480.00, 2420.00, 2580.00, 2500.00, 2420.00, 55.2, 82.5, 80.2),
('Reliance', '2024-01-02', 71.8, 35.5, 32.8, 2525.00, 2485.00, 2425.00, 2585.00, 2505.00, 2425.00, 55.5, 83.8, 81.5),
('Reliance', '2024-01-03', 72.2, 35.8, 33.2, 2530.00, 2490.00, 2430.00, 2590.00, 2510.00, 2430.00, 55.8, 84.2, 82.8),
-- ITC
('ITC', '2024-01-01', 55.2, 8.5, 7.8, 448.00, 442.00, 435.00, 460.00, 450.00, 440.00, 12.5, 62.5, 60.2),
('ITC', '2024-01-02', 56.5, 8.8, 8.0, 450.00, 444.00, 437.00, 462.00, 452.00, 442.00, 12.8, 63.8, 61.5),
('ITC', '2024-01-03', 57.8, 9.2, 8.2, 452.00, 446.00, 439.00, 464.00, 454.00, 444.00, 13.2, 64.2, 62.8),
-- Bharti Airtel
('Bharti Airtel', '2024-01-01', 68.5, 22.5, 20.8, 955.00, 940.00, 920.00, 980.00, 960.00, 940.00, 32.5, 78.5, 76.2),
('Bharti Airtel', '2024-01-02', 69.8, 22.8, 21.2, 960.00, 945.00, 925.00, 985.00, 965.00, 945.00, 32.8, 79.8, 77.5),
('Bharti Airtel', '2024-01-03', 70.2, 23.2, 21.5, 965.00, 950.00, 930.00, 990.00, 970.00, 950.00, 33.2, 80.2, 78.8),
-- HUL
('HUL', '2024-01-01', 52.5, 12.5, 11.8, 2585.00, 2560.00, 2520.00, 2640.00, 2600.00, 2560.00, 42.5, 58.5, 56.2),
('HUL', '2024-01-02', 53.8, 12.8, 12.0, 2590.00, 2565.00, 2525.00, 2645.00, 2605.00, 2565.00, 42.8, 59.8, 57.5),
('HUL', '2024-01-03', 54.2, 13.2, 12.2, 2595.00, 2570.00, 2530.00, 2650.00, 2610.00, 2570.00, 43.2, 60.2, 58.8),
-- Axis Bank
('Axis Bank', '2024-01-01', 64.5, 16.5, 15.2, 1105.00, 1090.00, 1060.00, 1130.00, 1100.00, 1070.00, 38.5, 74.5, 72.2),
('Axis Bank', '2024-01-02', 65.8, 16.8, 15.5, 1110.00, 1095.00, 1065.00, 1135.00, 1105.00, 1075.00, 38.8, 75.8, 73.5),
('Axis Bank', '2024-01-03', 66.2, 17.2, 15.8, 1115.00, 1100.00, 1070.00, 1140.00, 1110.00, 1080.00, 39.2, 76.2, 74.8),
-- Wipro
('Wipro', '2024-01-01', 48.5, 5.5, 4.8, 445.00, 440.00, 435.00, 460.00, 450.00, 440.00, 15.5, 54.5, 52.2),
('Wipro', '2024-01-02', 49.8, 5.8, 5.0, 447.00, 442.00, 437.00, 462.00, 452.00, 442.00, 15.8, 55.8, 53.5),
('Wipro', '2024-01-03', 50.2, 6.2, 5.2, 449.00, 444.00, 439.00, 464.00, 454.00, 444.00, 16.2, 56.2, 54.8),
-- SBI
('SBI', '2024-01-01', 72.5, 28.5, 26.8, 618.00, 610.00, 595.00, 635.00, 620.00, 605.00, 25.5, 85.5, 83.2),
('SBI', '2024-01-02', 73.8, 28.8, 27.2, 620.00, 612.00, 597.00, 637.00, 622.00, 607.00, 25.8, 86.8, 84.5),
('SBI', '2024-01-03', 74.2, 29.2, 27.5, 622.00, 614.00, 599.00, 639.00, 624.00, 609.00, 26.2, 87.2, 85.8);

-- Sample Data for Profit Report
INSERT INTO profit_report (application_no, symbol, company_name, period_type, period_end_dt, net_profit_loss_for_t, from_date, to_date, audited_unaudited, consolidated, indasnonind, rf_result_format) VALUES
('2023/Aug/90500', 'SOBHA', 'Sobha Limited', 'Q2', '30-JUN-2023', 443169, '01-APR-2023', '30-JUN-2023', 'U', 'Consolidated', 'Ind As', 'N'),
('2023/Aug/90501', 'SOBHA', 'Sobha Limited', 'Q3', '30-SEP-2023', 480000, '01-JUL-2023', '30-SEP-2023', 'A', 'Standalone', 'Ind As', 'N'),
('2023/Aug/90502', 'SOBHA', 'Sobha Limited', 'Q4', '31-DEC-2023', 520000, '01-OCT-2023', '31-DEC-2023', 'U', 'Consolidated', 'Ind As', 'N'),
('2023/Aug/90503', 'SOBHA', 'Sobha Limited', 'Q1', '31-MAR-2024', 550000, '01-JAN-2024', '31-MAR-2024', 'A', 'Standalone', 'Ind As', 'N'),
('2023/Aug/90504', 'IPCA', 'IPCA Laboratories Ltd', 'Q2', '30-JUN-2023', 580501, '01-APR-2023', '30-JUN-2023', 'A', 'Consolidated', 'Ind As', 'N'),
('2023/Aug/90505', 'IPCA', 'IPCA Laboratories Ltd', 'Q3', '30-SEP-2023', 600000, '01-JUL-2023', '30-SEP-2023', 'U', 'Standalone', 'Ind As', 'N'),
('2023/Aug/90506', 'IPCA', 'IPCA Laboratories Ltd', 'Q4', '31-DEC-2023', 620000, '01-OCT-2023', '31-DEC-2023', 'A', 'Consolidated', 'Ind As', 'N'),
('2023/Aug/90507', 'IPCA', 'IPCA Laboratories Ltd', 'Q1', '31-MAR-2024', 650000, '01-JAN-2024', '31-MAR-2024', 'U', 'Standalone', 'Ind As', 'N'),
('2023/Aug/90508', 'PUNJABCHE', 'Punjab Chemicals & Crop Protection Ltd', 'Q2', '30-JUN-2023', 425094, '01-APR-2023', '30-JUN-2023', 'U', 'Consolidated', 'Ind As', 'N'),
('2023/Aug/90509', 'PUNJABCHE', 'Punjab Chemicals & Crop Protection Ltd', 'Q3', '30-SEP-2023', 450000, '01-JUL-2023', '30-SEP-2023', 'A', 'Standalone', 'Ind As', 'N'),
('2023/Aug/90510', 'PUNJABCHE', 'Punjab Chemicals & Crop Protection Ltd', 'Q4', '31-DEC-2023', 470000, '01-OCT-2023', '31-DEC-2023', 'U', 'Consolidated', 'Ind As', 'N'),
('2023/Aug/90511', 'PUNJABCHE', 'Punjab Chemicals & Crop Protection Ltd', 'Q1', '31-MAR-2024', 500000, '01-JAN-2024', '31-MAR-2024', 'A', 'Standalone', 'Ind As', 'N'),
('2023/Aug/90512', 'ITDCEM', 'ITD Cementation India Ltd', 'Q1', '30-JUN-2023', 767341, '01-APR-2023', '30-JUN-2023', 'A', 'Standalone', 'Ind As', 'N'),
('2023/Aug/90513', 'ITDCEM', 'ITD Cementation India Ltd', 'Q2', '30-SEP-2023', 800000, '01-JUL-2023', '30-SEP-2023', 'U', 'Consolidated', 'Ind As', 'N'),
('2023/Aug/90514', 'ITDCEM', 'ITD Cementation India Ltd', 'Q3', '31-DEC-2023', 820000, '01-OCT-2023', '31-DEC-2023', 'A', 'Standalone', 'Ind As', 'N'),
('2023/Aug/90515', 'ITDCEM', 'ITD Cementation India Ltd', 'Q4', '31-MAR-2024', 850000, '01-JAN-2024', '31-MAR-2024', 'U', 'Consolidated', 'Ind As', 'N'),
('2023/Aug/90516', 'SAKTHISUG', 'Sakthi Sugars Ltd', 'Q2', '30-JUN-2023', 939096, '01-APR-2023', '30-JUN-2023', 'A', 'Consolidated', 'Ind As', 'N'),
('2023/Aug/90517', 'SAKTHISUG', 'Sakthi Sugars Ltd', 'Q3', '30-SEP-2023', 950000, '01-JUL-2023', '30-SEP-2023', 'U', 'Standalone', 'Ind As', 'N'),
('2023/Aug/90518', 'SAKTHISUG', 'Sakthi Sugars Ltd', 'Q4', '31-DEC-2023', 970000, '01-OCT-2023', '31-DEC-2023', 'A', 'Consolidated', 'Ind As', 'N'),
('2023/Aug/90519', 'SAKTHISUG', 'Sakthi Sugars Ltd', 'Q1', '31-MAR-2024', 1000000, '01-JAN-2024', '31-MAR-2024', 'U', 'Standalone', 'Ind As', 'N'),
('2023/Aug/90520', 'IGARASHI', 'Igarashi Motors India Ltd', 'Q1', '30-JUN-2023', 337530, '01-APR-2023', '30-JUN-2023', 'A', 'Standalone', 'Ind As', 'N'),
('2023/Aug/90521', 'IGARASHI', 'Igarashi Motors India Ltd', 'Q2', '30-SEP-2023', 350000, '01-JUL-2023', '30-SEP-2023', 'U', 'Consolidated', 'Ind As', 'N'),
('2023/Aug/90522', 'IGARASHI', 'Igarashi Motors India Ltd', 'Q3', '31-DEC-2023', 370000, '01-OCT-2023', '31-DEC-2023', 'A', 'Standalone', 'Ind As', 'N'),
('2023/Aug/90523', 'IGARASHI', 'Igarashi Motors India Ltd', 'Q4', '31-MAR-2024', 400000, '01-JAN-2024', '31-MAR-2024', 'U', 'Consolidated', 'Ind As', 'N'),
('2023/Aug/90524', 'APOLLOTYRE', 'Apollo Tyres Limited', 'Q2', '30-JUN-2023', 645142, '01-APR-2023', '30-JUN-2023', 'A', 'Consolidated', 'Ind As', 'N'),
('2023/Aug/90525', 'APOLLOTYRE', 'Apollo Tyres Limited', 'Q3', '30-SEP-2023', 680000, '01-JUL-2023', '30-SEP-2023', 'U', 'Standalone', 'Ind As', 'N'),
('2023/Aug/90526', 'APOLLOTYRE', 'Apollo Tyres Limited', 'Q4', '31-DEC-2023', 720000, '01-OCT-2023', '31-DEC-2023', 'A', 'Consolidated', 'Ind As', 'N'),
('2023/Aug/90527', 'APOLLOTYRE', 'Apollo Tyres Limited', 'Q1', '31-MAR-2024', 750000, '01-JAN-2024', '31-MAR-2024', 'U', 'Standalone', 'Ind As', 'N'),
('2023/Aug/90528', 'SHRIRAMFIN', 'Shriram Finance Limited', 'Q2', '30-JUN-2023', 780000, '01-APR-2023', '30-JUN-2023', 'U', 'Consolidated', 'Ind As', 'N'),
('2023/Aug/90529', 'SHRIRAMFIN', 'Shriram Finance Limited', 'Q3', '30-SEP-2023', 820000, '01-JUL-2023', '30-SEP-2023', 'A', 'Standalone', 'Ind As', 'N'),
('2023/Aug/90530', 'SHRIRAMFIN', 'Shriram Finance Limited', 'Q4', '31-DEC-2023', 850000, '01-OCT-2023', '31-DEC-2023', 'U', 'Consolidated', 'Ind As', 'N'),
('2023/Aug/90531', 'SHRIRAMFIN', 'Shriram Finance Limited', 'Q1', '31-MAR-2024', 880000, '01-JAN-2024', '31-MAR-2024', 'A', 'Standalone', 'Ind As', 'N'),
('2023/Aug/90532', 'SUMEETIND', 'Sumeet Industries Ltd', 'Q2', '30-JUN-2023', 250000, '01-APR-2023', '30-JUN-2023', 'A', 'Consolidated', 'Ind As', 'N'),
('2023/Aug/90533', 'SUMEETIND', 'Sumeet Industries Ltd', 'Q3', '30-SEP-2023', 270000, '01-JUL-2023', '30-SEP-2023', 'U', 'Standalone', 'Ind As', 'N'),
('2023/Aug/90534', 'SUMEETIND', 'Sumeet Industries Ltd', 'Q4', '31-DEC-2023', 290000, '01-OCT-2023', '31-DEC-2023', 'A', 'Consolidated', 'Ind As', 'N'),
('2023/Aug/90535', 'SUMEETIND', 'Sumeet Industries Ltd', 'Q1', '31-MAR-2024', 310000, '01-JAN-2024', '31-MAR-2024', 'U', 'Standalone', 'Ind As', 'N'),
('2023/Aug/90536', 'EVEREADY', 'Eveready Industries India Ltd', 'Q4', '30-JUN-2023', 645142, '01-APR-2023', '30-JUN-2023', 'A', 'Consolidated', 'Ind As', 'N'),
('2023/Aug/90537', 'EVEREADY', 'Eveready Industries India Ltd', 'Q1', '30-SEP-2023', 680000, '01-JUL-2023', '30-SEP-2023', 'U', 'Standalone', 'Ind As', 'N'),
('2023/Aug/90538', 'EVEREADY', 'Eveready Industries India Ltd', 'Q2', '31-DEC-2023', 720000, '01-OCT-2023', '31-DEC-2023', 'A', 'Consolidated', 'Ind As', 'N'),
('2023/Aug/90539', 'EVEREADY', 'Eveready Industries India Ltd', 'Q3', '31-MAR-2024', 750000, '01-JAN-2024', '31-MAR-2024', 'U', 'Standalone', 'Ind As', 'N'),
('2023/Aug/90540', 'GOKALDAS', 'Gokaldas Exports Ltd', 'Q2', '30-JUN-2023', 500000, '01-APR-2023', '30-JUN-2023', 'U', 'Consolidated', 'Ind As', 'N'),
('2023/Aug/90541', 'GOKALDAS', 'Gokaldas Exports Ltd', 'Q3', '30-SEP-2023', 520000, '01-JUL-2023', '30-SEP-2023', 'A', 'Standalone', 'Ind As', 'N'),
('2023/Aug/90542', 'GOKALDAS', 'Gokaldas Exports Ltd', 'Q4', '31-DEC-2023', 550000, '01-OCT-2023', '31-DEC-2023', 'U', 'Consolidated', 'Ind As', 'N'),
('2023/Aug/90543', 'GOKALDAS', 'Gokaldas Exports Ltd', 'Q1', '31-MAR-2024', 580000, '01-JAN-2024', '31-MAR-2024', 'A', 'Standalone', 'Ind As', 'N'),
('2023/Aug/90544', 'SHREECEM', 'SHREE CEMENT LIMITED', 'Q2', '30-JUN-2023', 1200000, '01-APR-2023', '30-JUN-2023', 'A', 'Consolidated', 'Ind As', 'N'),
('2023/Aug/90545', 'SHREECEM', 'SHREE CEMENT LIMITED', 'Q3', '30-SEP-2023', 1250000, '01-JUL-2023', '30-SEP-2023', 'U', 'Standalone', 'Ind As', 'N'),
('2023/Aug/90546', 'SHREECEM', 'SHREE CEMENT LIMITED', 'Q4', '31-DEC-2023', 1300000, '01-OCT-2023', '31-DEC-2023', 'A', 'Consolidated', 'Ind As', 'N'),
('2023/Aug/90547', 'SHREECEM', 'SHREE CEMENT LIMITED', 'Q1', '31-MAR-2024', 1350000, '01-JAN-2024', '31-MAR-2024', 'U', 'Standalone', 'Ind As', 'N');

-- Insert column configurations for the new profit_report table
INSERT INTO column_configs (table_name, column_name, display_name, data_type, is_visible, sort_order) VALUES
('profit_report', 'id', 'ID', 'INTEGER', 0, 1),
('profit_report', 'application_no', 'Application No', 'text', true, 2),
('profit_report', 'symbol', 'Symbol', 'text', true, 3),
('profit_report', 'company_name', 'Company Name', 'text', true, 4),
('profit_report', 'period_type', 'Period Type', 'text', true, 5),
('profit_report', 'period_end_dt', 'Period End Date', 'date', true, 6),
('profit_report', 'net_profit_loss_for_t', 'Net Profit/Loss', 'number', true, 7),
('profit_report', 'from_date', 'From Date', 'date', true, 8),
('profit_report', 'to_date', 'To Date', 'date', true, 9),
('profit_report', 'audited_unaudited', 'Audited/Unaudited', 'text', true, 10),
('profit_report', 'consolidated', 'Consolidated', 'text', true, 11),
('profit_report', 'indasnonind', 'Ind AS/Non-Ind AS', 'text', true, 12),
('profit_report', 'rf_result_format', 'Result Format', 'text', true, 13); 