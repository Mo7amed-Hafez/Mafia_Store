import 'package:flutter/material.dart';
import 'package:mafia_store/core/app_assets.dart';
import 'package:mafia_store/core/app_colore.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

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
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // search
                    Container(
                      width: MediaQuery.of(context).size.width / 1.4,
                      height: 50,
                      decoration: BoxDecoration(
                        // color: AppColore.darkColor,
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
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.search,
                              color: AppColore.lightColor,
                            ),
                          ),
                          Text(
                            "Search Products",
                            style: TextStyle(color: AppColore.lightColor),
                          ),
                        ],
                      ),
                    ),

                    // filter
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColore.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.tune,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // image
              Positioned(
                bottom: -100,
                left: MediaQuery.of(context).size.width / 2 - 175,
                child: Container(
                    width: 350,
                    height: 150,
                    child: Image.asset(AppAssets.onboarding1)),
              )
            ],
          )
        ],
      ),
    );
  }
}
