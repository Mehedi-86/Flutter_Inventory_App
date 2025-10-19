from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Dict, Optional
import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import random
import json

app = FastAPI(title="Inventory Analytics API", version="1.0.0")

# Enable CORS for Flutter app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Data Models
class Product(BaseModel):
    id: str
    name: str
    sku: str
    categoryId: str
    quantity: int
    unitPrice: float
    reorderLevel: int

class SalesData(BaseModel):
    productId: str
    quantity: int
    date: str
    revenue: float

class RecommendationRequest(BaseModel):
    products: List[Product]
    salesHistory: Optional[List[SalesData]] = []
    timeRange: int = 30  # days

# Generate dummy sales data for analytics
def generate_sales_data(products: List[Product], days: int = 90) -> List[Dict]:
    sales_data = []
    for product in products:
        for day in range(days):
            date = datetime.now() - timedelta(days=day)
            # Simulate varying sales based on product popularity
            base_sales = random.randint(1, 10) if random.random() > 0.3 else 0
            
            # Add seasonality and trends
            weekday_factor = 1.2 if date.weekday() < 5 else 0.8
            trend_factor = 1 + (day / days) * 0.5  # Growing trend
            
            quantity = int(base_sales * weekday_factor * trend_factor)
            if quantity > 0:
                sales_data.append({
                    "productId": product.id,
                    "productName": product.name,
                    "sku": product.sku,
                    "categoryId": product.categoryId,
                    "quantity": quantity,
                    "date": date.strftime("%Y-%m-%d"),
                    "revenue": quantity * product.unitPrice,
                    "unitPrice": product.unitPrice
                })
    
    return sales_data

@app.get("/")
async def root():
    return {"message": "Inventory Analytics API is running!"}

@app.post("/analytics/recommendations")
async def get_inventory_recommendations(request: RecommendationRequest):
    """Generate inventory recommendations based on sales data and current stock"""
    try:
        products = request.products
        
        # Generate mock sales data if none provided
        if not request.salesHistory:
            sales_data = generate_sales_data(products, request.timeRange)
        else:
            sales_data = [sale.dict() for sale in request.salesHistory]
        
        # Convert to DataFrame for analysis
        df_sales = pd.DataFrame(sales_data)
        df_products = pd.DataFrame([p.dict() for p in products])
        
        recommendations = []
        
        for product in products:
            product_sales = df_sales[df_sales['productId'] == product.id]
            
            if not product_sales.empty:
                # Calculate metrics
                avg_daily_sales = product_sales['quantity'].sum() / request.timeRange
                total_revenue = product_sales['revenue'].sum()
                velocity = avg_daily_sales  # Sales velocity
                
                # Calculate stock status
                days_until_stockout = product.quantity / max(avg_daily_sales, 0.1)
                
                # Generate recommendation
                if days_until_stockout < 7:
                    urgency = "HIGH"
                    action = "REORDER_NOW"
                    recommended_quantity = int(avg_daily_sales * 30)  # 30 days supply
                elif days_until_stockout < 14:
                    urgency = "MEDIUM"
                    action = "REORDER_SOON"
                    recommended_quantity = int(avg_daily_sales * 20)
                else:
                    urgency = "LOW"
                    action = "MONITOR"
                    recommended_quantity = 0
                
                # Performance classification
                if velocity > 2:
                    performance = "FAST_MOVING"
                elif velocity > 0.5:
                    performance = "MEDIUM_MOVING"
                else:
                    performance = "SLOW_MOVING"
                
                recommendations.append({
                    "productId": product.id,
                    "productName": product.name,
                    "sku": product.sku,
                    "currentStock": product.quantity,
                    "avgDailySales": round(avg_daily_sales, 2),
                    "daysUntilStockout": round(days_until_stockout, 1),
                    "urgency": urgency,
                    "action": action,
                    "recommendedQuantity": recommended_quantity,
                    "performance": performance,
                    "totalRevenue": round(total_revenue, 2),
                    "velocity": round(velocity, 2)
                })
            else:
                # No sales data
                recommendations.append({
                    "productId": product.id,
                    "productName": product.name,
                    "sku": product.sku,
                    "currentStock": product.quantity,
                    "avgDailySales": 0,
                    "daysUntilStockout": float('inf'),
                    "urgency": "LOW",
                    "action": "NO_DATA",
                    "recommendedQuantity": 0,
                    "performance": "NO_DATA",
                    "totalRevenue": 0,
                    "velocity": 0
                })
        
        return {
            "recommendations": recommendations,
            "summary": {
                "totalProducts": len(products),
                "highUrgency": len([r for r in recommendations if r["urgency"] == "HIGH"]),
                "mediumUrgency": len([r for r in recommendations if r["urgency"] == "MEDIUM"]),
                "lowUrgency": len([r for r in recommendations if r["urgency"] == "LOW"]),
                "analysisDate": datetime.now().isoformat()
            }
        }
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/analytics/sales-forecast")
async def get_sales_forecast(request: RecommendationRequest):
    """Generate sales forecast for the next 30 days"""
    try:
        products = request.products
        sales_data = generate_sales_data(products, 90)  # 90 days of history
        
        df_sales = pd.DataFrame(sales_data)
        forecasts = []
        
        for product in products:
            product_sales = df_sales[df_sales['productId'] == product.id]
            
            if not product_sales.empty:
                # Simple moving average forecast
                recent_sales = product_sales.tail(30)['quantity'].values
                avg_sales = np.mean(recent_sales) if len(recent_sales) > 0 else 0
                
                # Generate 30-day forecast with some variance
                forecast_days = []
                for day in range(30):
                    future_date = datetime.now() + timedelta(days=day+1)
                    # Add some randomness and trend
                    trend_factor = 1 + (day / 30) * 0.1  # Slight upward trend
                    noise = random.uniform(0.8, 1.2)  # Random variance
                    predicted_quantity = max(0, int(avg_sales * trend_factor * noise))
                    
                    forecast_days.append({
                        "date": future_date.strftime("%Y-%m-%d"),
                        "predictedQuantity": predicted_quantity,
                        "predictedRevenue": predicted_quantity * product.unitPrice
                    })
                
                forecasts.append({
                    "productId": product.id,
                    "productName": product.name,
                    "sku": product.sku,
                    "forecast": forecast_days,
                    "totalPredictedSales": sum([day["predictedQuantity"] for day in forecast_days]),
                    "totalPredictedRevenue": sum([day["predictedRevenue"] for day in forecast_days])
                })
        
        return {
            "forecasts": forecasts,
            "generatedAt": datetime.now().isoformat()
        }
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/analytics/abc-analysis")
async def get_abc_analysis(request: RecommendationRequest):
    """Perform ABC analysis on products"""
    try:
        products = request.products
        sales_data = generate_sales_data(products, request.timeRange)
        
        df_sales = pd.DataFrame(sales_data)
        
        # Calculate revenue per product
        product_revenues = df_sales.groupby('productId').agg({
            'revenue': 'sum',
            'quantity': 'sum',
            'productName': 'first',
            'sku': 'first'
        }).reset_index()
        
        # Sort by revenue
        product_revenues = product_revenues.sort_values('revenue', ascending=False)
        product_revenues['cumulative_revenue'] = product_revenues['revenue'].cumsum()
        total_revenue = product_revenues['revenue'].sum()
        product_revenues['revenue_percentage'] = (product_revenues['cumulative_revenue'] / total_revenue) * 100
        
        # Classify into ABC categories
        abc_results = []
        for _, row in product_revenues.iterrows():
            if row['revenue_percentage'] <= 80:
                category = 'A'
                description = 'High Value - Focus on tight control'
            elif row['revenue_percentage'] <= 95:
                category = 'B'
                description = 'Medium Value - Regular monitoring'
            else:
                category = 'C'
                description = 'Low Value - Basic control'
            
            abc_results.append({
                "productId": row['productId'],
                "productName": row['productName'],
                "sku": row['sku'],
                "revenue": round(row['revenue'], 2),
                "quantity": int(row['quantity']),
                "revenuePercentage": round(row['revenue_percentage'], 2),
                "category": category,
                "description": description
            })
        
        # Summary statistics
        a_count = len([r for r in abc_results if r['category'] == 'A'])
        b_count = len([r for r in abc_results if r['category'] == 'B'])
        c_count = len([r for r in abc_results if r['category'] == 'C'])
        
        return {
            "analysis": abc_results,
            "summary": {
                "totalProducts": len(abc_results),
                "categoryA": a_count,
                "categoryB": b_count,
                "categoryC": c_count,
                "totalRevenue": round(total_revenue, 2),
                "analysisDate": datetime.now().isoformat()
            }
        }
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/analytics/performance-metrics")
async def get_performance_metrics(request: RecommendationRequest):
    """Get comprehensive performance metrics"""
    try:
        products = request.products
        sales_data = generate_sales_data(products, request.timeRange)
        
        df_sales = pd.DataFrame(sales_data)
        df_products = pd.DataFrame([p.dict() for p in products])
        
        # Calculate various metrics
        total_revenue = df_sales['revenue'].sum()
        total_quantity = df_sales['quantity'].sum()
        avg_order_value = total_revenue / len(df_sales) if len(df_sales) > 0 else 0
        
        # Stock value
        total_stock_value = sum([p.quantity * p.unitPrice for p in products])
        
        # Category performance
        category_performance = df_sales.groupby('categoryId').agg({
            'revenue': 'sum',
            'quantity': 'sum'
        }).reset_index()
        
        category_results = []
        for _, row in category_performance.iterrows():
            category_results.append({
                "categoryId": row['categoryId'],
                "totalRevenue": round(row['revenue'], 2),
                "totalQuantity": int(row['quantity']),
                "revenueShare": round((row['revenue'] / total_revenue) * 100, 2) if total_revenue > 0 else 0
            })
        
        # Top performing products
        top_products = df_sales.groupby(['productId', 'productName']).agg({
            'revenue': 'sum',
            'quantity': 'sum'
        }).reset_index().sort_values('revenue', ascending=False).head(5)
        
        top_products_list = []
        for _, row in top_products.iterrows():
            top_products_list.append({
                "productId": row['productId'],
                "productName": row['productName'],
                "revenue": round(row['revenue'], 2),
                "quantity": int(row['quantity'])
            })
        
        return {
            "overallMetrics": {
                "totalRevenue": round(total_revenue, 2),
                "totalQuantitySold": int(total_quantity),
                "averageOrderValue": round(avg_order_value, 2),
                "totalStockValue": round(total_stock_value, 2),
                "numberOfProducts": len(products),
                "analysisPeriod": f"{request.timeRange} days"
            },
            "categoryPerformance": category_results,
            "topProducts": top_products_list,
            "generatedAt": datetime.now().isoformat()
        }
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)