import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mafia_store/core/app_assets.dart';
import 'package:mafia_store/core/app_colore.dart';
import 'package:banner_carousel/banner_carousel.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final List<BannerModel> listBanners = [
    BannerModel(imagePath: AppAssets.banner1, id: '1'),
    BannerModel(imagePath: AppAssets.banner2, id: '2'),
    BannerModel(imagePath: AppAssets.banner3, id: '3'),
    BannerModel(imagePath: AppAssets.banner4, id: '4'),
  ];

  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
        if (_currentPage < listBanners.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }

        if (mounted) {
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.only(bottom: 80),
                width: double.infinity,
                height: 140,
                decoration: BoxDecoration(
                  color: AppColore.darkColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // 🔍 search
                    Container(
                      width: MediaQuery.of(context).size.width / 1.4,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColore.darkColor,
                            const Color.fromARGB(238, 79, 69, 62),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Icons.search, color: Colors.white),
                          ),
                          Text(
                            "Search Products",
                            style: TextStyle(color: AppColore.lightColor),
                          ),
                        ],
                      ),
                    ),

                    // 🎛 filter
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColore.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.tune, color: Colors.white),
                    ),
                  ],
                ),
              ),

              // 🖼️ banner carousel
              Positioned(
                bottom: -60,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: 120,
                  child: BannerCarousel(
                    banners: listBanners,
                    customizedIndicators: const IndicatorModel.animation(
                      width: 20,
                      height: 3,
                      spaceBetween: 5,
                      widthAnimation: 50,
                      heightAnimation: 5
                    ),
                    height: 180,
                    activeColor: const Color.fromARGB(255, 197, 53, 9),
                    disableColor: Colors.grey,
                    animation: true,
                    borderRadius: 18,
                    pageController: _pageController,
                    onTap: (id) {
                      debugPrint("Banner tapped: $id");
                    },
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
