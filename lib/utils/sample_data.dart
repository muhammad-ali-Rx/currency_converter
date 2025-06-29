import 'package:currency_converter/model/trend_model.dart';
import 'package:currency_converter/model/analysis_model.dart';
import 'package:currency_converter/model/chart_model.dart';
import 'package:currency_converter/services/firebase_service.dart';

class SampleDataGenerator {
  
  static Future<void> addSampleTrends() async {
    final sampleTrends = [
      Trend(
        title: "USD Bullish Momentum Continues",
        currency: "USD/EUR",
        timeframe: "1W",
        percentage: 2.45,
        direction: "up",
        description: "Strong economic data supports USD strength across major pairs",
        analysis: "The US Dollar continues its upward trajectory supported by robust employment data and hawkish Fed commentary. Technical indicators suggest further upside potential with RSI at 65 and MACD showing bullish crossover.",
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        authorId: "admin_001",
        authorName: "Market Analyst",
      ),
      
      Trend(
        title: "EUR Faces Downward Pressure",
        currency: "USD/EUR",
        timeframe: "1D",
        percentage: -1.23,
        direction: "down",
        description: "ECB dovish stance weighs on Euro sentiment",
        analysis: "The Euro faces headwinds as ECB maintains accommodative policy stance while economic growth concerns persist in the Eurozone. Technical support at 1.0850 level remains critical.",
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 4)),
        authorId: "admin_002",
        authorName: "Currency Expert",
      ),
      
      Trend(
        title: "GBP/USD Consolidation Phase",
        currency: "GBP/USD",
        timeframe: "4H",
        percentage: 0.15,
        direction: "neutral",
        description: "Pound Sterling shows mixed signals amid BoE uncertainty",
        analysis: "GBP/USD remains in a tight range as markets await clearer signals from the Bank of England regarding future policy direction. Brexit-related concerns continue to weigh on sentiment.",
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
        authorId: "admin_003",
        authorName: "Technical Analyst",
      ),
    ];

    for (var trend in sampleTrends) {
      await FirebaseService.addTrend(trend);
    }
  }

  static Future<void> addSampleAnalysis() async {
    final sampleAnalysis = [
      Analysis(
        title: "EUR/USD Technical Analysis: Bearish Outlook",
        currency: "USD/EUR",
        analysisType: "Technical",
        content: "The EUR/USD pair has broken below the critical 1.0900 support level, confirming the bearish outlook. The RSI is oversold at 28 but showing no signs of reversal yet. Key resistance now sits at 1.0950, while support is at 1.0800. A break below 1.0800 could trigger further selling towards 1.0750. The 50-day moving average has crossed below the 200-day MA, forming a death cross pattern. Volume analysis shows increased selling pressure during the recent decline.",
        summary: "EUR/USD shows strong bearish signals with key support at 1.0800",
        recommendation: "Sell",
        riskLevel: "Medium",
        confidenceScore: 78.5,
        keyPoints: [
          "Break below 1.0900 support confirms bearish trend",
          "RSI oversold but no reversal signals yet",
          "Death cross pattern formed on daily chart",
          "Next target at 1.0750 if 1.0800 breaks"
        ],
        timeHorizon: "Short-term",
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
        authorId: "analyst_001",
        authorName: "Technical Analyst",
        views: 156,
      ),
      
      Analysis(
        title: "GBP/USD Fundamental Outlook",
        currency: "GBP/USD",
        analysisType: "Fundamental",
        content: "The Bank of England's more aggressive stance on inflation compared to other central banks provides fundamental support for GBP. Recent UK inflation data came in above expectations at 4.2%, reinforcing the BoE's hawkish bias. However, concerns about UK economic growth and political stability remain key risks. The upcoming GDP data will be crucial for determining the BoE's next move. Brexit-related trade issues continue to create uncertainty.",
        summary: "Bank of England policy divergence supports GBP strength",
        recommendation: "Buy",
        riskLevel: "High",
        confidenceScore: 65.2,
        keyPoints: [
          "BoE maintains hawkish stance on inflation",
          "UK inflation above expectations at 4.2%",
          "Political stability concerns remain",
          "Brexit trade issues create uncertainty"
        ],
        timeHorizon: "Medium-term",
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
        authorId: "analyst_002",
        authorName: "Fundamental Analyst",
        views: 89,
      ),
      
      Analysis(
        title: "USD/JPY Market Sentiment Analysis",
        currency: "USD/JPY",
        analysisType: "Market Sentiment",
        content: "Market sentiment towards USD/JPY remains bullish as risk-on appetite drives flows into higher-yielding assets. The Bank of Japan's ultra-loose monetary policy continues to weigh on the Yen, while Fed hawkishness supports the Dollar. Retail trader positioning shows 68% long USD/JPY, indicating strong bullish sentiment. However, intervention risks from Japanese authorities at higher levels remain a concern.",
        summary: "Strong bullish sentiment drives USD/JPY higher amid BoJ dovishness",
        recommendation: "Hold",
        riskLevel: "Medium",
        confidenceScore: 72.8,
        keyPoints: [
          "Risk-on sentiment favors USD over JPY",
          "BoJ maintains ultra-loose policy",
          "68% of retail traders long USD/JPY",
          "Intervention risk at higher levels"
        ],
        timeHorizon: "Medium-term",
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
        authorId: "analyst_003",
        authorName: "Sentiment Analyst",
        views: 124,
      ),
    ];

    for (var analysis in sampleAnalysis) {
      await FirebaseService.addAnalysis(analysis);
    }
  }

  static Future<void> addSampleCharts() async {
    // Generate sample data points for the last 30 days
    final dataPoints = <ChartPoint>[];
    final basePrice = 1.0900;
    final now = DateTime.now();
    
    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final randomVariation = (i % 7 - 3) * 0.002; // More realistic variation
      final price = basePrice + randomVariation;
      
      dataPoints.add(ChartPoint(
        timestamp: date,
        value: price,
        high: price + 0.0025,
        low: price - 0.0020,
        open: price - 0.0005,
        close: price + 0.0010,
        volume: 1000000 + (i * 75000),
      ));
    }

    final sampleCharts = [
      ChartData(
        title: "EUR/USD Daily Price Chart",
        currency: "USD/EUR",
        chartType: "Candlestick",
        timeframe: "1D",
        dataPoints: dataPoints,
        description: "30-day price action with key technical levels and volume analysis",
        technicalIndicators: ["RSI", "MACD", "SMA_20", "SMA_50", "Bollinger Bands"],
        chartSettings: {
          "showGrid": true,
          "showVolume": true,
          "theme": "dark",
        },
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        updatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
        authorId: "system",
        authorName: "Chart Generator",
      ),
      
      ChartData(
        title: "GBP/USD Weekly Trend Analysis",
        currency: "GBP/USD",
        chartType: "Line",
        timeframe: "1W",
        dataPoints: dataPoints.map((dp) => ChartPoint(
          timestamp: dp.timestamp,
          value: dp.value * 1.25, // Convert to GBP/USD rate
          high: dp.high != null ? dp.high! * 1.25 : null,
          low: dp.low != null ? dp.low! * 1.25 : null,
          open: dp.open != null ? dp.open! * 1.25 : null,
          close: dp.close != null ? dp.close! * 1.25 : null,
          volume: dp.volume,
        )).toList(),
        description: "Weekly trend analysis for GBP/USD with momentum indicators",
        technicalIndicators: ["RSI", "MACD", "EMA_12", "EMA_26"],
        chartSettings: {
          "showGrid": false,
          "showVolume": false,
          "theme": "light",
        },
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
        authorId: "system",
        authorName: "Chart Generator",
      ),
      
      ChartData(
        title: "USD/JPY Support & Resistance Levels",
        currency: "USD/JPY",
        chartType: "Area",
        timeframe: "4H",
        dataPoints: dataPoints.map((dp) => ChartPoint(
          timestamp: dp.timestamp,
          value: dp.value * 145, // Convert to JPY rate
          high: dp.high != null ? dp.high! * 145 : null,
          low: dp.low != null ? dp.low! * 145 : null,
          open: dp.open != null ? dp.open! * 145 : null,
          close: dp.close != null ? dp.close! * 145 : null,
          volume: dp.volume,
        )).toList(),
        description: "4-hour chart showing key support and resistance levels with volume profile",
        technicalIndicators: ["Support/Resistance", "Volume Profile", "Fibonacci"],
        chartSettings: {
          "showGrid": true,
          "showVolume": true,
          "theme": "dark",
        },
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        authorId: "system",
        authorName: "Chart Generator",
      ),
    ];

    for (var chart in sampleCharts) {
      await FirebaseService.addChart(chart);
    }
  }

  static Future<void> generateAllSampleData() async {
    print("Generating sample trends...");
    await addSampleTrends();
    
    print("Generating sample analysis...");
    await addSampleAnalysis();
    
    print("Generating sample charts...");
    await addSampleCharts();
    
    print("Sample data generation completed!");
  }
}
