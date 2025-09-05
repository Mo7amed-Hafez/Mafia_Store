// Card Drawer
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mafia_store/core/app_assets.dart';
import 'package:mafia_store/core/app_colore.dart';
import 'package:mafia_store/fetures/screens/home/home_page.dart';
import 'package:mafia_store/fetures/screens/info/profile_page.dart';
import 'package:mafia_store/fetures/screens/info/settings_page.dart';
import 'package:mafia_store/fetures/screens/productes/cart_page.dart';
import 'package:mafia_store/fetures/screens/productes/productes_page.dart';

Widget buildCardDrawer({
  required String title,
  required IconData icon,
  required BuildContext context,
  required Widget route,
}) {
  return ListTile(
    leading: Icon(
      icon,
      color: AppColore.oliveGreen,
    ),
    title: Text(title,
        style: const TextStyle(
            color: AppColore.darkColor, fontWeight: FontWeight.w500)),
    onTap: () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => route));
    },
  );
}

class BuildDrawer extends StatelessWidget {
  const BuildDrawer({
    super.key,
    required this.user,
  });

  final User? user;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColore.lightColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColore.darkColor, AppColore.primaryColor])),
            accountName: Text(user!.displayName ?? '', style: const TextStyle(fontWeight: FontWeight.bold,color: AppColore.lightColor)),
            accountEmail: Text(user!.email ?? ''),
            currentAccountPicture: CircleAvatar(
              backgroundImage: AssetImage(AppAssets.profile),
            ),
          ),
          buildCardDrawer(
            title: "Home",
            icon: Icons.home,
            context: context,
            route: const HomePage(),
          ),
          buildCardDrawer(
            title: "Profile",
            icon: Icons.person,
            context: context,
            route: const ProfilePage(),
          ),
          buildCardDrawer(
            title: "Cart",
            icon: Icons.shopping_cart,
            context: context,
            route: const CartPage(),
          ),
          buildCardDrawer(
            title: "Products",
            icon: Icons.store,
            context: context,
            route: const ProductesPage(),
          ),
          buildCardDrawer(
            title: "Settings",
            icon: Icons.settings,
            context: context,
            route: const SettingsPage(),
          ),
          const Divider(
            color: AppColore.oliveGreen,
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text(
              "Logout",
              style: TextStyle(color: AppColore.darkColor),
            ),
            onTap: () async {
              // await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}

