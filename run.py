#!/usr/bin/env python3
"""
Restaurant Analytics - Database-Powered Production Script
Lead AI Engineer Design - PostgreSQL-driven analysis
"""

import subprocess
import sys
import os

def install_requirements():
    """Install required packages"""
    print("📦 Installing required packages...")
    subprocess.check_call([sys.executable, "-m", "pip", "install", "-r", "requirements.txt"])
    print("✅ Packages installed successfully!")

def check_database():
    """Check if database is accessible"""
    try:
        import psycopg2
        conn = psycopg2.connect(
            host="localhost",
            port="5432", 
            database="restaurant_analytics",
            user="restaurant_admin",
            password="analytics123"
        )
        conn.close()
        return True
    except Exception as e:
        print(f"❌ Database connection failed: {e}")
        print("💡 Run database setup first: cd database && ./setup_database.sh")
        return False

def run_database_analysis(filter_type="all"):
    """Run database-powered analytics"""
    filter_desc = f" - {filter_type.replace('_', ' ').title()}" if filter_type != "all" else ""
    print(f"🍽️ Restaurant Analytics - Database Engine{filter_desc}")
    print("=" * (55 + len(filter_desc)))
    
    # Check if requirements are installed
    try:
        import pandas
        import psycopg2
        print("✅ Dependencies available")
    except ImportError:
        print("⚠️  Installing missing dependencies...")
        install_requirements()
    
    # Check database connection
    if not check_database():
        return False
    
    # Run database analysis
    print(f"🚀 Running database-powered analytics ({filter_type} items)...")
    try:
        result = subprocess.run([sys.executable, "database_analyzer.py", filter_type])
        return result.returncode == 0
    except FileNotFoundError:
        print("❌ database_analyzer.py not found!")
        return False
    except KeyboardInterrupt:
        print("\n👋 Analysis stopped by user")
        return False

def run_legacy_csv_analysis(csv_file=None):
    """Run legacy CSV-based analysis (fallback)"""
    print("🍽️ Menu Engineering Analysis - CSV Mode")
    print("=" * 50)
    print("⚠️  Using legacy CSV analysis. For better performance, use database mode.")
    
    # Check if requirements are installed
    try:
        import pandas
        print("✅ Dependencies available")
    except ImportError:
        install_requirements()
    
    # Run CSV analysis
    print("🔄 Running CSV-based analysis...")
    try:
        cmd = [sys.executable, "menu_analyzer.py"]
        if csv_file:
            cmd.append(csv_file)
        subprocess.run(cmd)
    except FileNotFoundError:
        print("❌ menu_analyzer.py not found!")
    except KeyboardInterrupt:
        print("\n👋 Analysis stopped by user")

def main():
    """Main execution with database-first approach"""
    
    if len(sys.argv) > 1 and sys.argv[1] == "--install":
        install_requirements()
        return
    
    if len(sys.argv) > 1 and sys.argv[1] == "--csv":
        # Force CSV mode
        csv_file = sys.argv[2] if len(sys.argv) > 2 else None
        run_legacy_csv_analysis(csv_file)
        return
    
    if len(sys.argv) > 1 and sys.argv[1] == "--help":
        print("🍽️ Restaurant Analytics - Usage")
        print("=" * 45)
        print("Default mode (all items):     python run.py")
        print("Non-alcohol items only:       python run.py --non-alcohol")
        print("Alcohol items only:           python run.py --alcohol")
        print("CSV mode (legacy):            python run.py --csv [file]")
        print("Install dependencies:         python run.py --install")
        print("Show help:                   python run.py --help")
        print()
        print("🚀 Database mode features:")
        print("  • Sub-second query performance")
        print("  • Real-time monthly trends")
        print("  • Service type analysis") 
        print("  • Enhanced BCG matrix")
        print("  • Alcohol/Non-alcohol filtering")
        print("  • 100% revenue accuracy")
        return
    
    # Determine filter type
    filter_type = "all"
    if len(sys.argv) > 1:
        if sys.argv[1] == "--non-alcohol":
            filter_type = "non_alcohol"
        elif sys.argv[1] == "--alcohol":
            filter_type = "alcohol"
        elif sys.argv[1].startswith("--"):
            print(f"❌ Unknown option: {sys.argv[1]}")
            print("💡 Run 'python run.py --help' for usage")
            return
    
    # Default: Try database mode first
    print("🎯 Starting Restaurant Analytics...")
    print(f"📊 Mode: Database-Powered (PostgreSQL)")
    print(f"🔍 Filter: {filter_type.replace('_', '-').title()} items")
    
    if run_database_analysis(filter_type):
        print("\n🎉 Analysis completed successfully!")
        print("📄 Check output/ folder for detailed reports")
    else:
        print("\n⚠️  Database mode failed. Try CSV mode:")
        print("   python run.py --csv")

if __name__ == "__main__":
    main()