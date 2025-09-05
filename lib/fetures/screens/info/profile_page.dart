import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mafia_store/core/app_assets.dart';
import 'package:mafia_store/core/app_colore.dart';
import 'package:mafia_store/core/auth_service.dart';
import 'package:mafia_store/fetures/widgets/profile_widget/profile_info.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColore.darkColor,
        title: const Text('My Profile',
            style: TextStyle(color: AppColore.lightColor)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColore.primaryColor),
            onPressed: () async {
              // عرض تأكيد تسجيل الخروج
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text("Logout"),
                    ),
                  ],
                ),
              );

              if (shouldLogout == true) {
                await AuthService.signOut();
                if (mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(_uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Un Error has Ocurred : ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final data = snapshot.data?.data() ?? <String, dynamic>{};

          final displayName =
              (data['name'] as String?) ?? user?.displayName ?? 'User';
          final email = user?.email ?? (data['email'] as String?) ?? '';
          final phone = (data['phone'] as String?) ?? 'No phone';
          final gender = (data['gender'] as String?) ?? 'Not set';
          // نقرأ حقل birthday إذا كان موجوداً وإلا نبقي 'Not set'
          String birthdate = 'Not set';
          if (data.containsKey('birthday')) {
            final String raw = (data['birthday'] as String?) ?? '';
            if (raw.isNotEmpty) {
              try {
                final dt = DateTime.tryParse(raw);
                if (dt != null) {
                  birthdate = dt.toString().split(' ')[0];
                } else {
                  birthdate = raw; // fallback كما هو
                }
              } catch (_) {
                birthdate = raw;
              }
            }
          } else if (data.containsKey('birthdate')) {
            // دعم خلفي إذا كان الحقل القديم مستخدماً
            birthdate = (data['birthdate'] as String?) ?? 'Not set';
          }
          final photoUrl = user?.photoURL;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        colors: [AppColore.darkColor, AppColore.primaryColor],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: photoUrl != null
                            ? NetworkImage(photoUrl)
                            : const AssetImage(AppAssets.profile)
                                as ImageProvider,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 16,
                        runSpacing: 6,
                        children: [
                          iconInfo(icon: Icons.phone, label: phone),
                          iconInfo(icon: Icons.person, label: gender),
                          iconInfo(icon: Icons.cake, label: birthdate),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Sections: Orders and Favorites
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'My Orders',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 170,
                      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(_uid)
                            .collection('orders')
                            .orderBy('createdAt', descending: true)
                            .snapshots(),
                        builder: (context, ordersSnap) {
                          if (ordersSnap.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          final orders = ordersSnap.data?.docs ?? [];
                          if (orders.isEmpty) {
                            return const Center(
                              child: Text('No orders yet',
                                  style: TextStyle(color: Colors.grey)),
                            );
                          }
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: orders.length,
                            itemBuilder: (context, index) {
                              final orderDoc = orders[index];
                              return FutureBuilder<
                                  QuerySnapshot<Map<String, dynamic>>>(
                                future: orderDoc.reference
                                    .collection('items')
                                    .limit(1)
                                    .get(),
                                builder: (context, itemSnap) {
                                  if (itemSnap.connectionState ==
                                      ConnectionState.waiting) {
                                    return miniCard(
                                      imagePath: null,
                                      name: 'Order',
                                      price: (orderDoc.data()['totalPrice'] ??
                                          0) as num,
                                    );
                                  }
                                  if (!itemSnap.hasData ||
                                      itemSnap.data!.docs.isEmpty) {
                                    return miniCard(
                                      imagePath: null,
                                      name: 'Order',
                                      price: (orderDoc.data()['totalPrice'] ??
                                          0) as num,
                                    );
                                  }
                                  final data = itemSnap.data!.docs.first.data();
                                  final String? imageKey =
                                      data['imageKey'] as String?;
                                  final String? imagePath = imageKey != null
                                      ? AppAssets.imagesMap[imageKey]
                                      : null;
                                  final String name =
                                      (data['name'] as String?) ?? 'Item';
                                  final num price = (data['price'] ?? 0) as num;
                                  return miniCard(
                                      imagePath: imagePath,
                                      name: name,
                                      price: price);
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'My Favorites',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 170,
                      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(_uid)
                            .collection('favorites')
                            .snapshots(),
                        builder: (context, favSnap) {
                          if (favSnap.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          final favs = favSnap.data?.docs ?? [];
                          if (favs.isEmpty) {
                            return const Center(
                              child: Text('No favorites yet',
                                  style: TextStyle(color: Colors.grey)),
                            );
                          }
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: favs.length,
                            itemBuilder: (context, index) {
                              final data = favs[index].data();
                              final String? imageKey =
                                  data['imageKey'] as String?;
                              final String? imagePath = imageKey != null
                                  ? AppAssets.imagesMap[imageKey]
                                  : null;
                              final String name =
                                  (data['name'] as String?) ?? 'Item';
                              final num price = (data['price'] ?? 0) as num;
                              return miniCard(
                                  imagePath: imagePath,
                                  name: name,
                                  price: price);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                // Logout button
                SafeArea(
                  minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      icon: const Icon(
                        Icons.logout,
                        color: Colors.red,
                      ),
                      label: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.red),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColore.secondaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
