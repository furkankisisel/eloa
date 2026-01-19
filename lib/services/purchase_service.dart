import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PurchaseService extends ChangeNotifier {
  static const String _premiumKey = 'is_premium';
  static const String _tokensKey = 'token_balance';

  // Ürün ID'leri - Google Play Console ve App Store Connect'te tanımlanmalı
  static const String premiumProductId = 'eloa_premium';
  static const String monthlySubId = 'eloa_premium_monthly';
  static const String yearlySubId = 'eloa_premium_yearly';

  // Jeton Paketleri
  static const String token1Id = 'eloa_token_1';
  static const String token5Id = 'eloa_token_5';
  static const String token10Id = 'eloa_token_10';

  static const Set<String> _productIds = {
    premiumProductId,
    monthlySubId,
    yearlySubId,
    token1Id,
    token5Id,
    token10Id,
  };

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  List<ProductDetails> _products = [];
  bool _isPremium = false;
  int _tokenBalance = 0;
  bool _isLoading = false;
  bool _isAvailable = false;
  String? _error;

  List<ProductDetails> get products => _products;
  bool get isPremium => _isPremium;
  int get tokenBalance => _tokenBalance;
  bool get isLoading => _isLoading;
  bool get isAvailable => _isAvailable;
  String? get error => _error;

  PurchaseService() {
    _init();
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();

    // Yerel premium ve jeton durumunu yükle
    await _loadUserData();

    // Mağaza erişilebilirliğini kontrol et
    _isAvailable = await _inAppPurchase.isAvailable();

    if (!_isAvailable) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    // Satın alma akışını dinle
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen(
      _onPurchaseUpdated,
      onDone: () => _subscription?.cancel(),
      onError: (error) => debugPrint('Purchase stream error: $error'),
    );

    // Ürünleri yükle
    await loadProducts();

    // Önceki satın almaları geri yükle
    await restorePurchases();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool(_premiumKey) ?? false;
    _tokenBalance = prefs.getInt(_tokensKey) ?? 0;
  }

  Future<void> _addTokens(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    _tokenBalance += amount;
    await prefs.setInt(_tokensKey, _tokenBalance);
    notifyListeners();
  }

  Future<bool> consumeToken() async {
    if (_isPremium) return true; // Premium kullanıcılar jeton harcamaz
    if (_tokenBalance > 0) {
      final prefs = await SharedPreferences.getInstance();
      _tokenBalance--;
      await prefs.setInt(_tokensKey, _tokenBalance);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> _savePremiumStatus(bool status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumKey, status);
    _isPremium = status;
    notifyListeners();
  }

  Future<void> loadProducts() async {
    try {
      final ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails(_productIds);

      if (response.error != null) {
        _error = response.error!.message;
        debugPrint('Product query error: ${response.error}');
      }

      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('Products not found: ${response.notFoundIDs}');
      }

      _products = response.productDetails;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint('Load products error: $e');
    }
  }

  Future<void> buyProduct(ProductDetails product) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final PurchaseParam purchaseParam =
          PurchaseParam(productDetails: product);

      // Consumable (Jeton) mu yoksa Non-consumable (Premium/Abonelik) mi?
      if ([token1Id, token5Id, token10Id].contains(product.id)) {
        await _inAppPurchase.buyConsumable(
            purchaseParam: purchaseParam, autoConsume: true);
      } else {
        await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('Buy product error: $e');
    }
  }

  void _onPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          debugPrint('Purchase pending: ${purchaseDetails.productID}');
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _verifyAndDeliverProduct(purchaseDetails);
          break;

        case PurchaseStatus.error:
          _error = purchaseDetails.error?.message;
          debugPrint('Purchase error: ${purchaseDetails.error}');
          _isLoading = false;
          notifyListeners();
          break;

        case PurchaseStatus.canceled:
          _isLoading = false;
          notifyListeners();
          break;
      }
    }
  }

  Future<void> _verifyAndDeliverProduct(PurchaseDetails purchaseDetails) async {
    // Gerçek uygulamada sunucu tarafında doğrulama yapılmalı
    // Şimdilik basit bir yerel doğrulama

    if (purchaseDetails.status == PurchaseStatus.purchased) {
      if (purchaseDetails.productID == token1Id)
        await _addTokens(1);
      else if (purchaseDetails.productID == token5Id)
        await _addTokens(5);
      else if (purchaseDetails.productID == token10Id)
        await _addTokens(10);
      else if ([premiumProductId, monthlySubId, yearlySubId]
          .contains(purchaseDetails.productID)) {
        await _savePremiumStatus(true);
      }
    } else if (purchaseDetails.status == PurchaseStatus.restored) {
      // Restore sadece kalıcı ürünler için
      if ([premiumProductId, monthlySubId, yearlySubId]
          .contains(purchaseDetails.productID)) {
        await _savePremiumStatus(true);
      }
    }

    if (purchaseDetails.pendingCompletePurchase) {
      await _inAppPurchase.completePurchase(purchaseDetails);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> restorePurchases() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      _error = e.toString();
      debugPrint('Restore purchases error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
