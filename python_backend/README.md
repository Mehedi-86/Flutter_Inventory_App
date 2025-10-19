# Inventory Analytics Backend

This Python backend provides advanced analytics and machine learning features for the Flutter Inventory App.

## Features

- **Inventory Recommendations**: AI-powered reorder suggestions based on sales patterns
- **Sales Forecasting**: 30-day sales predictions using historical data
- **ABC Analysis**: Product classification by revenue contribution
- **Performance Metrics**: Comprehensive analytics dashboard

## Setup

### 1. Create Virtual Environment
```powershell
cd python_backend
python -m venv inventory_env
```

### 2. Activate Virtual Environment
```powershell
# On Windows PowerShell
.\inventory_env\Scripts\Activate.ps1

# On Windows Command Prompt
inventory_env\Scripts\activate.bat

# On macOS/Linux
source inventory_env/bin/activate
```

### 3. Install Dependencies
```powershell
pip install -r requirements.txt
```

### 4. Run the Server
```powershell
python main.py
```

The server will start on `http://localhost:8000`

## API Endpoints

### Health Check
- `GET /` - Check if server is running

### Analytics Endpoints
- `POST /analytics/recommendations` - Get inventory recommendations
- `POST /analytics/sales-forecast` - Get sales forecast
- `POST /analytics/abc-analysis` - Get ABC analysis
- `POST /analytics/performance-metrics` - Get performance metrics

## Request Format

All analytics endpoints expect this format:

```json
{
  "products": [
    {
      "id": "string",
      "name": "string", 
      "sku": "string",
      "categoryId": "string",
      "quantity": 0,
      "unitPrice": 0.0,
      "reorderLevel": 0
    }
  ],
  "timeRange": 30
}
```

## Development

### View API Documentation
Once the server is running, visit:
- Interactive docs: `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`

### Adding New Features
1. Add new endpoints in `main.py`
2. Update the `AnalyticsService` in Flutter
3. Create new screens for visualization

## Troubleshooting

### Server Won't Start
- Check if virtual environment is activated
- Ensure all dependencies are installed: `pip install -r requirements.txt`
- Check if port 8000 is available

### Flutter Can't Connect
- Ensure server is running on `http://localhost:8000`
- Check if CORS is properly configured
- Verify network connectivity

### Data Issues
- The backend generates mock data for demonstration
- In production, connect to your actual database
- Modify the data generation logic as needed