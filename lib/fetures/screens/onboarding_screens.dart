import 'package:flutter/material.dart';

import 'package:flutter_overboard/flutter_overboard.dart';
import 'package:mafia_store/core/app_assets.dart';
import 'package:mafia_store/core/app_colore.dart';



class OnboardingPage extends StatefulWidget {
  OnboardingPage({Key? key}) : super(key: key);

  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _globalKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      body: OverBoard(
        allowScroll: true,
        pages: pages,
        showBullets: true,
        inactiveBulletColor: Colors.grey,
        buttonColor: AppColore.primaryColor,
        activeBulletColor: AppColore.primaryColor,
        
        // backgroundProvider: NetworkImage('https://picsum.photos/720/1280'),
        skipCallback: () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Skip clicked",style: TextStyle(color: AppColore.primaryColor),),
          ));
        },
        finishCallback: () {
          Navigator.pushReplacementNamed(context, '/home');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Finish clicked",style: TextStyle(color: AppColore.primaryColor),),
          ));
        },
      ),
    );
  }

  final pages = [
    PageModel(
        color: const Color(0xFFF1d7686),
        imageAssetPath: AppAssets.onboarding1,
        title: 'MAFIA STORE',
        body: 'Welcome to Mafia Store – your trusted place to explore, shop, and enjoy the best deals all in one place.',
        doAnimateImage: true),
    PageModel(
        color: const Color(0xFF9df3f7),
        imageAssetPath: AppAssets.onboarding2,
        
        title: 'Online Shopping',
        body: 'Browse thousands of products anytime, anywhere, and enjoy a seamless shopping experience from your mobile.',
        doAnimateImage: true),
    PageModel(
        color: const Color(0xFF1d7686),
        imageAssetPath: AppAssets.onboarding3,
        title: 'Products',
        body: 'Discover a wide variety of high-quality products carefully selected to meet your needs and style',
        doAnimateImage: true),
    PageModel.withChild(
        child: Padding(
          padding: EdgeInsets.only(bottom: 25.0),
          child: Image.asset(AppAssets.onboarding4, width: 300.0, height: 300.0),
        ),
        color: const Color(0xFFcae2fd),
        doAnimateChild: true,
        
        )
  ];
}