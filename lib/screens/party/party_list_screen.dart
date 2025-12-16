import 'package:flutter/material.dart';
import 'package:hetanshi_enterprise/models/party_model.dart';
import 'package:hetanshi_enterprise/services/firestore_service.dart';
import 'package:hetanshi_enterprise/screens/party/add_edit_party_screen.dart';
import 'package:hetanshi_enterprise/widgets/app_drawer.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:hetanshi_enterprise/utils/app_theme.dart';
import 'package:hetanshi_enterprise/widgets/modern_background.dart';
import 'package:hetanshi_enterprise/utils/toast_utils.dart';

class PartyListScreen extends StatelessWidget {
  const PartyListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      // AppBar removed to use custom header
      drawer: const AppDrawer(),
      body: ModernBackground(
        child: Column(
          children: [
            // Custom Header matching Dashboard
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
              child: SafeArea( // Ensure header respects top notch
                bottom: false,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Builder(
                          builder: (context) => IconButton(
                            icon: const Icon(Icons.menu, color: Colors.white),
                            onPressed: () {
                              Scaffold.of(context).openDrawer();
                            },
                          ),
                        ),
                        // You can add search or filter icons here if needed
                        const SizedBox(width: 48), // Balancing space
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.people_outline, color: Colors.white, size: 30),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          "Parties",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // List content taking remaining space
            Expanded(
              child: StreamBuilder<List<Party>>(
                stream: firestoreService.getParties(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final parties = snapshot.data ?? [];

                  if (parties.isEmpty) {
                    return const Center(child: Text('No parties found'));
                  }

                  return AnimationLimiter(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: parties.length,
                      itemBuilder: (context, index) {
                        final party = parties[index];
                         return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 1,
                                color: AppColors.cardWhite.withOpacity(0.9),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: AppColors.infoSkyBlue.withOpacity(0.1),
                                    child: Text(
                                      party.name.isNotEmpty ? party.name[0].toUpperCase() : '?',
                                      style: const TextStyle(color: AppColors.infoSkyBlue, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  title: Text(party.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(party.mobile, style: const TextStyle(color: AppColors.textSecondary)),
                                      Text(party.address,
                                          maxLines: 1, overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(color: AppColors.textSecondary)),
                                    ],
                                  ),
                                  isThreeLine: true,
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: AppColors.primaryBlue),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  AddEditPartyScreen(party: party),
                                            ),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: AppColors.errorRed),
                                        onPressed: () async {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('Delete Party'),
                                              content: const Text(
                                                  'Are you sure you want to delete this party?'),
                                              actions: [
                                                TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context, false),
                                                    child: const Text('Cancel')),
                                                TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context, true),
                                                    child: const Text('Delete',
                                                        style: TextStyle(
                                                            color: AppColors.errorRed))),
                                              ],
                                            ),
                                          );

                                          if (confirm == true) {
                                            try {
                                              await firestoreService.deleteParty(party.id);
                                              if (context.mounted) {
                                                 ToastUtils.showSuccess(context, 'Party deleted');
                                              }
                                            } catch (e) {
                                              if (context.mounted) {
                                                 ToastUtils.showError(context, 'Error deleting: $e');
                                              }
                                            }
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditPartyScreen(),
            ),
          );
        },
        backgroundColor: AppColors.secondaryTeal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
