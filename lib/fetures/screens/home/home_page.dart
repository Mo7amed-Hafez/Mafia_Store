import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mafia_store/core/app_colore.dart';
import 'package:mafia_store/fetures/screens/home/home_content.dart';
import 'package:mafia_store/fetures/screens/info/profile_page.dart';
import 'package:mafia_store/fetures/screens/productes/cart_page.dart';
import 'package:mafia_store/fetures/screens/productes/productes_page.dart';
import 'package:mafia_store/fetures/widgets/home_widget/build_drawer.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser;

  var _currentIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomeContent(),
      const ProductesPage(),
      const CartPage(),
      const ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 30,
        flexibleSpace: SizedBox(
          height: 30,
        ),
        title: Text(
          "MAFIA STORE",
          style: TextStyle(fontSize: 18, color: AppColore.primaryColor),
        ),
        backgroundColor: AppColore.darkColor,
      ),
      drawer: BuildDrawer(user: user),
      body: _pages[_currentIndex],
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: [
          /// Home
          SalomonBottomBarItem(
            icon: Icon(Icons.home_outlined),
            title: Text("Home"),
            selectedColor: AppColore.primaryColor,
          ),

          /// Likes
          SalomonBottomBarItem(
              icon: Icon(Icons.store_outlined),
              title: Text("Productes"),
              selectedColor: const Color.fromARGB(255, 37, 75, 158)),

          /// Search
          SalomonBottomBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            title: Text("Cart"),
            selectedColor: Colors.orange,
          ),

          /// Profile
          SalomonBottomBarItem(
            icon: Icon(Icons.person_outline_rounded),
            title: Text("Profile"),
            selectedColor: Colors.teal,
          ),
        ],
      ),
    );
  }
}
