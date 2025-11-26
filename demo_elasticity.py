"""
Demo script to show price elasticity features with current data
"""

import pandas as pd
import numpy as np
from menu_analyzer import AccurateMenuAnalyzer, PriceElasticityAnalyzer
import json

def create_demo_data_with_price_variation(original_df):
    """
    Create demo data by adding artificial price variations to show elasticity features
    """
    print("🎭 Creating demo data with price variations for feature demonstration...")
    
    # Create extended time range (3 months)
    demo_data = []
    
    for month_offset in [0, 30, 60]:  # 3 months of data
        for _, row in original_df.iterrows():
            new_row = row.copy()
            
            # Add price variation based on month (simulate promotions, seasonal changes)
            if month_offset == 30:  # Month 2: Promotion period
                new_row['allocated_price'] *= np.random.uniform(0.8, 0.95)  # 5-20% discount
            elif month_offset == 60:  # Month 3: Premium pricing
                new_row['allocated_price'] *= np.random.uniform(1.05, 1.15)  # 5-15% increase
                
            # Adjust date
            original_date = pd.to_datetime(new_row['date'])
            new_row['date'] = original_date + pd.Timedelta(days=month_offset)
            
            # Adjust demand based on price (simulate realistic elasticity)
            price_change = (new_row['allocated_price'] / row['allocated_price']) - 1
            
            # Different items have different elasticities
            if 'thali' in new_row['item_name'].lower():
                elasticity = -0.8  # Moderately elastic (food staples)
            elif 'alcohol' in new_row['item_name'].lower() or any(drink in new_row['item_name'].lower() for drink in ['beer', 'wine', 'rum', 'whiskey']):
                elasticity = -0.3  # Less elastic (alcohol)
            else:
                elasticity = -1.2  # More elastic (other items)
            
            # Calculate demand adjustment
            demand_change = elasticity * price_change
            
            # Randomly include/exclude transactions based on demand change
            inclusion_probability = max(0.1, min(1.5, 1 + demand_change))
            
            if np.random.random() < inclusion_probability:
                demo_data.append(new_row)
    
    return pd.DataFrame(demo_data)

def run_demo_analysis():
    """Run elasticity analysis demo with enhanced data"""
    
    # Load original data
    analyzer = AccurateMenuAnalyzer()
    
    print("📖 Loading original transaction data...")
    with open('data/orders_oct_25.csv', 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_df = analyzer.parse_restaurant_csv(content)
    print(f"✅ Loaded {len(original_df)} transactions from original data")
    
    # Create demo data with price variations
    demo_df = create_demo_data_with_price_variation(original_df)
    print(f"✅ Created demo dataset with {len(demo_df)} transactions over 3 months")
    
    # Run elasticity analysis on demo data
    print("\n🚀 RUNNING DEMO PRICE ELASTICITY ANALYSIS...")
    elasticity_analyzer = PriceElasticityAnalyzer()
    
    # Calculate elasticity
    elasticity_results = elasticity_analyzer.calculate_price_elasticity(demo_df)
    
    if elasticity_results:
        print(f"✅ Price elasticity calculated for {len(elasticity_results)} items")
        
        # Generate pricing recommendations
        pricing_recommendations = elasticity_analyzer.optimize_pricing(demo_df, elasticity_results)
        print(f"🎯 Generated pricing recommendations for {len(pricing_recommendations)} items")
        
        # Show top recommendations
        if pricing_recommendations:
            print("\n💰 TOP PRICING RECOMMENDATIONS:")
            high_priority = {k: v for k, v in pricing_recommendations.items() if v['priority'] == 'HIGH'}
            
            for item_name, rec in sorted(high_priority.items(), key=lambda x: x[1]['revenue_change'], reverse=True)[:5]:
                action_icon = "📈" if rec['action'] == 'INCREASE' else "📉" if rec['action'] == 'DECREASE' else "✅"
                print(f"  {action_icon} {item_name}:")
                print(f"    Current: ₹{rec['current_price']:.0f} → Recommended: ₹{rec['recommended_price']:.0f}")
                print(f"    Revenue Impact: +₹{rec['revenue_change']:,.0f} ({rec['confidence']} confidence)")
                print(f"    Elasticity: {rec['elasticity']:.2f}")
                print()
        
        # Generate summary
        summary = elasticity_analyzer.generate_elasticity_summary()
        print(f"\n📊 ELASTICITY SUMMARY:")
        print(f"  Items Analyzed: {summary['summary']['total_items_analyzed']}")
        print(f"  High Confidence Items: {summary['high_confidence_items']}")
        print(f"  Price Increase Candidates: {summary['pricing_opportunities']['price_increase_candidates']}")
        print(f"  Volume Boost Candidates: {summary['pricing_opportunities']['volume_boost_candidates']}")
        
        # Save demo results
        demo_results = {
            'elasticity_results': elasticity_results,
            'pricing_recommendations': pricing_recommendations,
            'summary': summary
        }
        
        with open('demo_elasticity_results.json', 'w') as f:
            json.dump(demo_results, f, indent=2, default=str)
        
        print(f"\n📁 Demo results saved to: demo_elasticity_results.json")
        print("🎭 This demonstrates the advanced features available with proper longitudinal data!")
        
    else:
        print("❌ Demo failed - check data processing")

if __name__ == "__main__":
    run_demo_analysis()