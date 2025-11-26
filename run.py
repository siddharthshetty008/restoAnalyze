#!/usr/bin/env python3
"""
Menu Engineering Analysis - Production Script
"""

import subprocess
import sys
import os

def install_requirements():
    """Install required packages"""
    print("📦 Installing required packages...")
    subprocess.check_call([sys.executable, "-m", "pip", "install", "-r", "requirements.txt"])
    print("✅ Packages installed successfully!")

def run_analysis(csv_file=None):
    """Run the menu analysis"""
    print("🍽️ Menu Engineering Analysis")
    print("=" * 50)
    
    # Check if requirements are installed
    try:
        import pandas
        print("✅ Dependencies available")
    except ImportError:
        install_requirements()
    
    # Run the analysis
    print("🔄 Running accurate menu analysis...")
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
    if len(sys.argv) > 1 and sys.argv[1] == "--install":
        install_requirements()
    elif len(sys.argv) > 1:
        # Specific CSV file provided
        csv_file = sys.argv[1]
        run_analysis(csv_file)
    else:
        # Auto-detect CSV files
        run_analysis()

if __name__ == "__main__":
    main()