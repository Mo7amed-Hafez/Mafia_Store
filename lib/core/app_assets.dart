class AppAssets {
  static const String logo = 'assets/images/mfLogo.png';
  static const String onboarding1 = 'assets/images/welcome.png';
  static const String onboarding2 = 'assets/images/Online_Shoping.png';
  static const String onboarding3 = 'assets/images/productesIcon.png';
  static const String onboarding4 = 'assets/images/cart.png';

  // profile
  static const String profile = 'assets/images/profile1.jpg';

  // banners
  static const String banner1 = 'assets/images/ban2.png';
  static const String banner2 = 'assets/images/banr1.png';
  static const String banner3 = 'assets/images/ban5.jpg';
  static const String banner4 = 'assets/images/ban6.jpg';

  // products
  static const String nikeShoes = 'assets/images/nikeShoes.jpg';
  static const String adidasTShirt2 = 'assets/images/adidasTShirt2.jpg';
  static const String ultraBoost = 'assets/images/ultraBoost.jpg';
  static const String adidasTShirt = 'assets/images/adidasTShirt.jpg';
  static const String samsungS25 = 'assets/images/samsungS25.jpg';
  static const String fitbitCharge5 = 'assets/images/fitbitCharge5.jpg';
  static const String airpodsPro = 'assets/images/airpodsPro.jpg';
  static const String pumaSneakers = 'assets/images/pumaSneakers.jpg';
  static const String iphone15 = 'assets/images/iphone15.jpg';

  /// Map عشان نربط imageKey من Firestore بالصورة الصح
  static const Map<String, String> imagesMap = {
    "defaultProfile":profile,
    "nikeShoes": nikeShoes,
    "adidasTShirt2": adidasTShirt2,
    "ultraBoost": ultraBoost,
    "adidasTShirt": adidasTShirt,
    "samsungS25": samsungS25,
    "fitbitCharge5": fitbitCharge5,
    "airpodsPro": airpodsPro,
    "pumaSneakers": pumaSneakers,
    "iphone15": iphone15,
  };
}
