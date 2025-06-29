import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:currency_converter/model/article_model.dart';
import 'package:currency_converter/model/trend_model.dart';
import 'package:currency_converter/model/analysis_model.dart';
import 'package:currency_converter/model/chart_model.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _articlesCollection = 'articles';
  static const String _trendsCollection = 'trends';
  static const String _analysisCollection = 'analysis';
  static const String _chartsCollection = 'charts';

  // ============ ARTICLES METHODS ============
  
  // Add new article
  static Future<String?> addArticle(Article article) async {
    try {
      DocumentReference docRef = await _firestore.collection(_articlesCollection).add(article.toMap());
      return docRef.id;
    } catch (e) {
      print('Error adding article: $e');
      return null;
    }
  }

  // Update existing article
  static Future<String?> updateArticle(String articleId, Article article) async {
    try {
      await _firestore.collection(_articlesCollection).doc(articleId).update(article.toMap());
      return articleId;
    } catch (e) {
      print('Error updating article: $e');
      return null;
    }
  }

  // Delete article
  static Future<bool> deleteArticle(String articleId) async {
    try {
      await _firestore.collection(_articlesCollection).doc(articleId).delete();
      return true;
    } catch (e) {
      print('Error deleting article: $e');
      return false;
    }
  }

  // Get all articles (real-time stream) - simplified query
  static Stream<List<Article>> getArticles() {
    return _firestore
        .collection(_articlesCollection)
        .where('isPublished', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final articles = snapshot.docs.map((doc) {
        return Article.fromMap(doc.data(), doc.id);
      }).toList();
    
    // Sort in memory to avoid index requirements
    articles.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return articles;
  });
}

  // Get articles by category - simplified query
  static Stream<List<Article>> getArticlesByCategory(String category) {
    return _firestore
        .collection(_articlesCollection)
        .where('category', isEqualTo: category)
        .where('isPublished', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final articles = snapshot.docs.map((doc) {
        return Article.fromMap(doc.data(), doc.id);
      }).toList();
    
    // Sort in memory to avoid index requirements
    articles.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return articles;
  });
}

  // Search articles
  static Future<List<Article>> searchArticles(String query) async {
    try {
      final snapshot = await _firestore
          .collection(_articlesCollection)
          .where('isPublished', isEqualTo: true)
          .get();

      final articles = snapshot.docs.map((doc) {
        return Article.fromMap(doc.data(), doc.id);
      }).toList();

      final filteredArticles = articles.where((article) {
        final searchLower = query.toLowerCase();
        return article.title.toLowerCase().contains(searchLower) ||
               article.summary.toLowerCase().contains(searchLower) ||
               article.content.toLowerCase().contains(searchLower) ||
               article.category.toLowerCase().contains(searchLower);
      }).toList();

      // Sort in memory
      filteredArticles.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return filteredArticles;
    } catch (e) {
      print('Error searching articles: $e');
      return [];
    }
  }

  // Get article by ID
  static Future<Article?> getArticleById(String articleId) async {
    try {
      final doc = await _firestore.collection(_articlesCollection).doc(articleId).get();
      
      if (doc.exists) {
        return Article.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting article: $e');
      return null;
    }
  }

  // Get articles count by category
  static Future<Map<String, int>> getArticleCountByCategory() async {
    try {
      final snapshot = await _firestore
          .collection(_articlesCollection)
          .where('isPublished', isEqualTo: true)
          .get();
      final Map<String, int> counts = {};
      
      for (var doc in snapshot.docs) {
        final category = doc.data()['category'] ?? 'Unknown';
        counts[category] = (counts[category] ?? 0) + 1;
      }
      
      return counts;
    } catch (e) {
      print('Error getting article counts: $e');
      return {};
    }
  }

  // ============ TRENDS METHODS ============

  // Add new trend
  static Future<String?> addTrend(Trend trend) async {
    try {
      DocumentReference docRef = await _firestore.collection(_trendsCollection).add(trend.toMap());
      return docRef.id;
    } catch (e) {
      print('Error adding trend: $e');
      return null;
    }
  }

  // Update existing trend
  static Future<String?> updateTrend(String trendId, Trend trend) async {
    try {
      await _firestore.collection(_trendsCollection).doc(trendId).update(trend.toMap());
      return trendId;
    } catch (e) {
      print('Error updating trend: $e');
      return null;
    }
  }

  // Delete trend
  static Future<bool> deleteTrend(String trendId) async {
    try {
      await _firestore.collection(_trendsCollection).doc(trendId).delete();
      return true;
    } catch (e) {
      print('Error deleting trend: $e');
      return false;
    }
  }

  // Get all trends (real-time stream) - simplified query
  static Stream<List<Trend>> getTrends() {
    return _firestore
        .collection(_trendsCollection)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final trends = snapshot.docs.map((doc) {
        return Trend.fromMap(doc.data(), doc.id);
      }).toList();
    
    // Sort in memory to avoid index requirements
    trends.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return trends;
  });
}

// Get trends by currency - simplified query
static Stream<List<Trend>> getTrendsByCurrency(String currency) {
  return _firestore
      .collection(_trendsCollection)
      .where('currency', isEqualTo: currency)
      .where('isActive', isEqualTo: true)
      .snapshots()
      .map((snapshot) {
    final trends = snapshot.docs.map((doc) {
      return Trend.fromMap(doc.data(), doc.id);
    }).toList();
    
    // Sort in memory to avoid index requirements
    trends.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return trends;
  });
}

// Get trends by timeframe - simplified query
static Stream<List<Trend>> getTrendsByTimeframe(String timeframe) {
  return _firestore
      .collection(_trendsCollection)
      .where('timeframe', isEqualTo: timeframe)
      .where('isActive', isEqualTo: true)
      .snapshots()
      .map((snapshot) {
    final trends = snapshot.docs.map((doc) {
      return Trend.fromMap(doc.data(), doc.id);
    }).toList();
    
    // Sort in memory to avoid index requirements
    trends.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return trends;
  });
}

  // ============ ANALYSIS METHODS ============

  // Add new analysis
  static Future<String?> addAnalysis(Analysis analysis) async {
    try {
      DocumentReference docRef = await _firestore.collection(_analysisCollection).add(analysis.toMap());
      return docRef.id;
    } catch (e) {
      print('Error adding analysis: $e');
      return null;
    }
  }

  // Update existing analysis
  static Future<String?> updateAnalysis(String analysisId, Analysis analysis) async {
    try {
      await _firestore.collection(_analysisCollection).doc(analysisId).update(analysis.toMap());
      return analysisId;
    } catch (e) {
      print('Error updating analysis: $e');
      return null;
    }
  }

  // Delete analysis
  static Future<bool> deleteAnalysis(String analysisId) async {
    try {
      await _firestore.collection(_analysisCollection).doc(analysisId).delete();
      return true;
    } catch (e) {
      print('Error deleting analysis: $e');
      return false;
    }
  }

  // Get all analysis (real-time stream) - simplified query
  static Stream<List<Analysis>> getAnalysis() {
    return _firestore
        .collection(_analysisCollection)
        .where('isPublished', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final analysisList = snapshot.docs.map((doc) {
        return Analysis.fromMap(doc.data(), doc.id);
      }).toList();
    
    // Sort in memory to avoid index requirements
    analysisList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return analysisList;
  });
}

// Get analysis by currency - simplified query
static Stream<List<Analysis>> getAnalysisByCurrency(String currency) {
  return _firestore
      .collection(_analysisCollection)
      .where('currency', isEqualTo: currency)
      .where('isPublished', isEqualTo: true)
      .snapshots()
      .map((snapshot) {
    final analysisList = snapshot.docs.map((doc) {
      return Analysis.fromMap(doc.data(), doc.id);
    }).toList();
    
    // Sort in memory to avoid index requirements
    analysisList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return analysisList;
  });
}

// Get analysis by type - simplified query
static Stream<List<Analysis>> getAnalysisByType(String analysisType) {
  return _firestore
      .collection(_analysisCollection)
      .where('analysisType', isEqualTo: analysisType)
      .where('isPublished', isEqualTo: true)
      .snapshots()
      .map((snapshot) {
    final analysisList = snapshot.docs.map((doc) {
      return Analysis.fromMap(doc.data(), doc.id);
    }).toList();
    
    // Sort in memory to avoid index requirements
    analysisList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return analysisList;
  });
}

  // Increment analysis views
  static Future<void> incrementAnalysisViews(String analysisId) async {
    try {
      await _firestore.collection(_analysisCollection).doc(analysisId).update({
        'views': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error incrementing views: $e');
    }
  }

  // ============ CHARTS METHODS ============

  // Add new chart
  static Future<String?> addChart(ChartData chart) async {
    try {
      DocumentReference docRef = await _firestore.collection(_chartsCollection).add(chart.toMap());
      return docRef.id;
    } catch (e) {
      print('Error adding chart: $e');
      return null;
    }
  }

  // Update existing chart
  static Future<String?> updateChart(String chartId, ChartData chart) async {
    try {
      await _firestore.collection(_chartsCollection).doc(chartId).update(chart.toMap());
      return chartId;
    } catch (e) {
      print('Error updating chart: $e');
      return null;
    }
  }

  // Delete chart
  static Future<bool> deleteChart(String chartId) async {
    try {
      await _firestore.collection(_chartsCollection).doc(chartId).delete();
      return true;
    } catch (e) {
      print('Error deleting chart: $e');
      return false;
    }
  }

  // Get all charts (real-time stream) - simplified query
  static Stream<List<ChartData>> getCharts() {
    return _firestore
        .collection(_chartsCollection)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final charts = snapshot.docs.map((doc) {
        return ChartData.fromMap(doc.data(), doc.id);
      }).toList();
    
    // Sort in memory to avoid index requirements
    charts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return charts;
  });
}

// Get charts by currency - simplified query
static Stream<List<ChartData>> getChartsByCurrency(String currency) {
  return _firestore
      .collection(_chartsCollection)
      .where('currency', isEqualTo: currency)
      .where('isActive', isEqualTo: true)
      .snapshots()
      .map((snapshot) {
    final charts = snapshot.docs.map((doc) {
      return ChartData.fromMap(doc.data(), doc.id);
    }).toList();
    
    // Sort in memory to avoid index requirements
    charts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return charts;
  });
}

// Get charts by timeframe - simplified query
static Stream<List<ChartData>> getChartsByTimeframe(String timeframe) {
  return _firestore
      .collection(_chartsCollection)
      .where('timeframe', isEqualTo: timeframe)
      .where('isActive', isEqualTo: true)
      .snapshots()
      .map((snapshot) {
    final charts = snapshot.docs.map((doc) {
      return ChartData.fromMap(doc.data(), doc.id);
    }).toList();
    
    // Sort in memory to avoid index requirements
    charts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return charts;
  });
}

// Get charts by type - simplified query
static Stream<List<ChartData>> getChartsByType(String chartType) {
  return _firestore
      .collection(_chartsCollection)
      .where('chartType', isEqualTo: chartType)
      .where('isActive', isEqualTo: true)
      .snapshots()
      .map((snapshot) {
    final charts = snapshot.docs.map((doc) {
      return ChartData.fromMap(doc.data(), doc.id);
    }).toList();
    
    // Sort in memory to avoid index requirements
    charts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return charts;
  });
}
}
