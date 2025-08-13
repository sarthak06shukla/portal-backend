from datetime import datetime, timedelta
import random
import sqlite3
from database import get_db, execute_write

# Sample companies (from your schema.sql update)
COMPANIES = [
    "Sobha Limited", "IPCA Laboratories Ltd", "Punjab Chemicals & Crop Protection Ltd",
    "ITD Cementation India Ltd", "Sakthi Sugars Ltd", "Igarashi Motors India Ltd",
    "Apollo Tyres Limited", "Shriram Finance Limited", "Sumeet Industries Ltd",
    "Eveready Industries India Ltd", "Gokaldas Exports Ltd", "SHREE CEMENT LIMITED"
]

def seed_core_data(conn: sqlite3.Connection):
    """Seeds core stock price, financial metrics, performance, and dividend data."""
    # Clear existing data for these tables
    execute_write(conn, "DELETE FROM stock_prices;")
    execute_write(conn, "DELETE FROM financial_metrics;")
    execute_write(conn, "DELETE FROM performance;")
    execute_write(conn, "DELETE FROM dividend;")

    end_date = datetime(2024, 3, 20).date()
    dates = [(end_date - timedelta(days=x)) for x in range(30)]
    
    # Base values for each company (adjusted for new companies or general ranges)
    base_values = {
        "Sobha Limited": {"price": 860, "market_cap": 320000},
        "IPCA Laboratories Ltd": {"price": 960, "market_cap": 420000},
        "Punjab Chemicals & Crop Protection Ltd": {"price": 760, "market_cap": 280000},
        "ITD Cementation India Ltd": {"price": 460, "market_cap": 180000},
        "Sakthi Sugars Ltd": {"price": 183, "market_cap": 120000},
        "Igarashi Motors India Ltd": {"price": 323, "market_cap": 150000},
        "Apollo Tyres Limited": {"price": 383, "market_cap": 250000},
        "Shriram Finance Limited": {"price": 2210, "market_cap": 850000},
        "Sumeet Industries Ltd": {"price": 121, "market_cap": 80000},
        "Eveready Industries India Ltd": {"price": 353, "market_cap": 200000},
        "Gokaldas Exports Ltd": {"price": 283, "market_cap": 150000},
        "SHREE CEMENT LIMITED": {"price": 28100, "market_cap": 9800000}
    }

    for date in dates:
        for company in COMPANIES:
            base = base_values[company]
            variation = random.uniform(0.97, 1.03)

            # Stock price data
            base_price = base["price"] * variation
            execute_write(conn, """
                INSERT INTO stock_prices (company, date, open_price, high_price, low_price, close_price, volume)
                VALUES (?, ?, ?, ?, ?, ?, ?)
            """, (
                company,
                date.isoformat(),
                round(base_price * random.uniform(0.998, 1.002), 2),
                round(base_price * random.uniform(1.002, 1.015), 2),
                round(base_price * random.uniform(0.985, 0.998), 2),
                round(base_price * random.uniform(0.995, 1.005), 2),
                int(random.uniform(100000, 1000000))
            ))

            # Financial metrics
            market_cap = base["market_cap"] * variation
            execute_write(conn, """
                INSERT INTO financial_metrics (company, date, pe_ratio, market_cap, book_value, debt_to_equity, current_ratio, roce)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            """, (
                company,
                date.isoformat(),
                round(random.uniform(10, 40), 2),
                round(market_cap, 2),
                round(market_cap / random.uniform(3, 10), 2),
                round(random.uniform(0.1, 1.8), 2),
                round(random.uniform(1.0, 3.0), 2),
                round(random.uniform(10, 30), 2)
            ))

            # Performance metrics
            execute_write(conn, """
                INSERT INTO performance (company, date, returns_1m, returns_3m, returns_6m, returns_1y, volatility, beta)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            """, (
                company,
                date.isoformat(),
                round(random.uniform(-10, 15), 2),
                round(random.uniform(-15, 25), 2),
                round(random.uniform(-20, 40), 2),
                round(random.uniform(-25, 60), 2),
                round(random.uniform(10, 40), 2),
                round(random.uniform(0.5, 1.5), 2)
            ))

            # Dividend data
            execute_write(conn, """
                INSERT INTO dividend (company, date, dividend_yield, payout_ratio, dividend_per_share, dividend_growth)
                VALUES (?, ?, ?, ?, ?, ?)
            """, (
                company,
                date.isoformat(),
                round(random.uniform(0.5, 5.0), 2),
                round(random.uniform(15, 70), 2),
                round(random.uniform(5, 100), 2),
                round(random.uniform(-10, 20), 2)
            ))

def seed_technical_indicators_data(conn: sqlite3.Connection):
    """Seeds technical indicators data."""
    execute_write(conn, "DELETE FROM technical_indicators;")

    base_date = datetime(2024, 1, 1).date()
    
    for company in COMPANIES:
        for i in range(30):  # 30 days of data
            date = base_date - timedelta(days=i)
            execute_write(conn, """
                INSERT INTO technical_indicators (company, date, rsi_14, macd, macd_signal, ma_20, ma_50, ma_200, bollinger_upper, bollinger_middle, bollinger_lower, atr, stochastic_k, stochastic_d)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """, (
                company,
                date.isoformat(),
                round(random.uniform(30, 70), 2),
                round(random.uniform(-5, 5), 2),
                round(random.uniform(-4, 4), 2),
                round(random.uniform(100, 30000), 2),  # Adjust range for various company prices
                round(random.uniform(100, 30000), 2),
                round(random.uniform(100, 30000), 2),
                round(random.uniform(100, 30000), 2),
                round(random.uniform(100, 30000), 2),
                round(random.uniform(100, 30000), 2),
                round(random.uniform(5, 30), 2),
                round(random.uniform(20, 80), 2),
                round(random.uniform(15, 75), 2)
            ))

def seed_profit_report_data(conn: sqlite3.Connection):
    """Seeds profit report data (12,000 rows)."""
    execute_write(conn, "DELETE FROM profit_report;")

    # Constants based on your sample
    AUDITED_UNAUDITED_OPTIONS = ['U', 'A']
    CONSOLIDATED_OPTIONS = ['Consolidated', 'Standalone']
    INDASNONIND_VALUE = 'Ind As'
    RF_RESULT_FORMAT_VALUE = 'N'
    PERIOD_TYPES = ['Q1', 'Q2', 'Q3', 'Q4']

    # Generate for approx 250 years to get ~1000 rows per company (12 * 250 * 4 = 12000)
    start_year = 1774 # Starting year far back to get enough unique application numbers
    end_year = 2024

    current_app_suffix = 90000 # Starting suffix for application_no

    for company in COMPANIES:
        for year in range(start_year, end_year + 1):
            for quarter_idx, period_type in enumerate(PERIOD_TYPES):
                # Define dates for the quarter
                if period_type == 'Q1':
                    from_date = datetime(year, 1, 1).date()
                    to_date = datetime(year, 3, 31).date()
                    period_end_dt = datetime(year, 3, 31).date()
                elif period_type == 'Q2':
                    from_date = datetime(year, 4, 1).date()
                    to_date = datetime(year, 6, 30).date()
                    period_end_dt = datetime(year, 6, 30).date()
                elif period_type == 'Q3':
                    from_date = datetime(year, 7, 1).date()
                    to_date = datetime(year, 9, 30).date()
                    period_end_dt = datetime(year, 9, 30).date()
                else: # Q4
                    from_date = datetime(year, 10, 1).date()
                    to_date = datetime(year, 12, 31).date()
                    period_end_dt = datetime(year, 12, 31).date()
                
                # Generate application number based on year and a growing suffix
                app_no_str = f"{year}/Q{quarter_idx+1}/{current_app_suffix}"
                current_app_suffix += 1

                # Generate profit/loss with some randomness
                net_profit_loss = int(random.uniform(100000, 1500000)) # Wide range for profits

                execute_write(conn, """
                    INSERT INTO profit_report (application_no, symbol, company_name, period_type, period_end_dt, net_profit_loss_for_t, from_date, to_date, audited_unaudited, consolidated, indasnonind, rf_result_format)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """, (
                    app_no_str,
                    company[:8].upper(), # Simple symbol generation from company name
                    company,
                    period_type,
                    period_end_dt.isoformat(),
                    net_profit_loss,
                    from_date.isoformat(),
                    to_date.isoformat(),
                    random.choice(AUDITED_UNAUDITED_OPTIONS),
                    random.choice(CONSOLIDATED_OPTIONS),
                    INDASNONIND_VALUE,
                    RF_RESULT_FORMAT_VALUE
                ))

def seed_dividend_data(conn: sqlite3.Connection):
    """Seeds dividend data (12,000 rows)."""
    execute_write(conn, "DELETE FROM dividend;")
    
    # Constants based on your sample
    DIVIDEND_TYPES = ['Final', 'Interim', 'Special']
    
    # Generate for approx 250 years to get ~1000 rows per company (12 * 250 * 4 = 12000)
    start_year = 1774
    end_year = 2024
    
    for company in COMPANIES:
        for year in range(start_year, end_year + 1):
            # Generate 4 dividend entries per year
            for quarter in range(4):
                # Define dates for the quarter
                if quarter == 0:
                    date = datetime(year, 3, 31).date()
                elif quarter == 1:
                    date = datetime(year, 6, 30).date()
                elif quarter == 2:
                    date = datetime(year, 9, 30).date()
                else: # Q4
                    date = datetime(year, 12, 31).date()
                
                # Generate dividend metrics with some randomness
                dividend_yield = round(random.uniform(1, 5), 2)
                payout_ratio = round(random.uniform(20, 80), 2)
                dividend_per_share = round(random.uniform(10, 100), 2)
                dividend_growth = round(random.uniform(-10, 30), 2)
                is_eligible = random.choice(['Y', 'N'])
                
                execute_write(conn, """
                    INSERT INTO dividend (company, date, dividend_yield, payout_ratio, dividend_per_share, dividend_growth, is_eligible)
                    VALUES (?, ?, ?, ?, ?, ?, ?)
                """, (
                    company,
                    date.isoformat(),
                    dividend_yield,
                    payout_ratio,
                    dividend_per_share,
                    dividend_growth,
                    is_eligible
                ))

def seed_all_data():
    """Main function to seed all data"""
    conn = get_db()
    try:
        seed_core_data(conn)
        seed_technical_indicators_data(conn)
        seed_profit_report_data(conn)
        seed_dividend_data(conn)
        print("✅ All data seeded successfully!")
    except Exception as e:
        print(f"❌ Error seeding data: {e}")
    finally:
        # Removed conn.close() as the in-memory database connection should remain open for the app's lifetime
        pass

if __name__ == "__main__":
    seed_all_data() 