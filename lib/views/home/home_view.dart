import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/services_controller.dart';
import '../../models/service.dart';
import '../emergancy/confirm_book_eme.dart';
import '../nursing/nursing_booking_view.dart';
import '../widgets/clinic_card.dart';
import '../widgets/emergency_card.dart';
import '../widgets/extra_service_card.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeView extends StatelessWidget {
  HomeView({super.key});

  final AuthController authController = Get.find<AuthController>();
  final ServicesController servicesController = Get.put(ServicesController());
  late final ProfileController profileController;

  @override
  Widget build(BuildContext context) {
    // Initialize ProfileController if not already initialized
    try {
      if (profileController == null)
        profileController = Get.find<ProfileController>();
    } catch (e) {
      profileController = Get.put(ProfileController());
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/wave BG@2x.png', // Use your actual background asset
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with avatar and logo
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (profileController.isLoggedIn) {
                                  Get.toNamed('/profile');
                                } else {
                                  Get.toNamed('/login');
                                }
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Obx(() {
                                        final isLoggedIn =
                                            profileController.isLoggedIn;
                                        final gender =
                                            profileController.gender.value;
                                        return ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Image.asset(
                                            isLoggedIn && gender == 'Female'
                                                ? "assets/images/female.jpeg"
                                                : 'assets/images/male.jpeg',
                                            fit: BoxFit.cover,
                                          ),
                                        );
                                      })),
                                  const SizedBox(width: 12),
                                  Obx(() {
                                    final isLoggedIn =
                                        profileController.isLoggedIn;
                                    final firstName =
                                        profileController.firstName.value;
                                    return Text(
                                      isLoggedIn && firstName.isNotEmpty
                                          ? "${'Hello'.tr} ${firstName ?? ''} "
                                          : 'Hello'.tr,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Container(
                          child: Image.asset(
                            'assets/images/horizontal color.png', // Your logo asset
                            height: 70,
                            width: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // --- Main Services Grid ---
                    FutureBuilder<List<Service>>(
                      future: servicesController.fetchPrimaryServices(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(
                              child: Text('error'.trParams(
                                  {'error': snapshot.error.toString()})));
                        }
                        final services = snapshot.data ?? [];
                        final emergency = services.firstWhereOrNull(
                            (s) => s.name.toLowerCase().contains('emergency'));
                        final dialysis = services.firstWhereOrNull(
                            (s) => s.name.toLowerCase().contains('dialysis'));
                        final nursing = services.firstWhereOrNull(
                            (s) => s.name.toLowerCase().contains('nursing'));
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (emergency != null)
                              EmergencyCard(
                                title: emergency.name,
                                icon: emergency.imageUrl ??
                                    'assets/icons/emergency.svg',
                                onTap: () {
                                  Get.to(() => EmeBookingConfirmationView(),
                                      arguments: {
                                        'clinic': emergency,
                                        'selectedDate': DateTime.now(),
                                        'selectedTimeSlot': 'Emergency Booking',
                                      });
                                },
                              ),
                            const SizedBox(height: 16),
                            if (dialysis != null || nursing != null)
                              Row(
                                children: [
                                  if (dialysis != null)
                                    Expanded(
                                      child: ClinicCard(
                                        titleBackgroundColor: Color(0xfff5ab0b),
                                        title: dialysis.name,
                                        icon: dialysis.imageUrl ??
                                            'assets/icons/dialysis.svg',
                                        onTap: () {
                                          Get.toNamed('/dialysis-booking',
                                              arguments: dialysis);
                                        },
                                      ),
                                    ),
                                  if (dialysis != null && nursing != null)
                                    const SizedBox(width: 12),
                                  if (nursing != null)
                                    Expanded(
                                      child: ClinicCard(
                                        title: nursing.name,
                                        titleBackgroundColor: Color(0XFFF45C07),
                                        icon: nursing.imageUrl ??
                                            'assets/icons/nursing.svg',
                                        onTap: () {
                                          Get.to(
                                              () => const NursingBookingView(),
                                              arguments: nursing);
                                        },
                                      ),
                                    ),
                                ],
                              ),
                            const SizedBox(height: 20),
                          ],
                        );
                      },
                    ),

                    // --- Our Services Grid ---
                    FutureBuilder<List<Service>>(
                      future: servicesController.fetchClinics(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(
                              child: Text('error'.trParams(
                                  {'error': snapshot.error.toString()})));
                        }
                        final clinics = snapshot.data ?? [];
                        if (clinics.isEmpty) return const SizedBox();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                'Clinics'.tr,
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 4 / 5,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: clinics.length,
                              itemBuilder: (context, index) {
                                final clinic = clinics[index];
                                return ClinicCard(
                                  title: clinic.name,
                                  icon: clinic.imageUrl ??
                                      'assets/icons/abdominal.svg',
                                  onTap: () {
                                    Get.toNamed('/booking', arguments: clinic);
                                  },
                                );
                              },
                            ),
                            const SizedBox(height: 32),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainCard({
    required String title,
    required String icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 100,
              height: double.infinity,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(12),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Image.asset(icon),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(String icon, Color color) {
    try {
      // Try SVG first
      return SvgPicture.asset(
        icon,
        colorFilter: ColorFilter.mode(
          color,
          BlendMode.srcIn,
        ),
        fit: BoxFit.contain,
      );
    } catch (e) {
      try {
        // If SVG fails, try PNG
        return Image.asset(
          icon,
          // color: color,
          fit: BoxFit.cover,
        );
      } catch (e) {
        // If both fail, return a placeholder
        return Icon(
          Icons.image_not_supported,
          color: color,
          size: 32,
        );
      }
    }
  }

  void _showSpecialServices(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Special Services',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Service>>(
                future: servicesController.fetchPrimaryServices(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                        child: Text('error'
                            .trParams({'error': snapshot.error.toString()})));
                  }

                  final primaryServices = snapshot.data ?? [];
                  if (primaryServices.isEmpty) {
                    return Center(child: Text('no_services_found'.tr));
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: primaryServices.length,
                    itemBuilder: (context, index) {
                      final service = primaryServices[index];
                      return EmergencyCard(
                        title: service.name,
                        icon: service.imageUrl ?? 'assets/icons/emergency.svg',
                        onTap: () {
                          Navigator.pop(context);
                          if (service.name == 'Dialysis') {
                            Get.toNamed('/dialysis-booking',
                                arguments: service);
                          } else if (service.name == 'Emergency' ||
                              service.name == 'Intoxication') {
                            Get.to(() => EmeBookingConfirmationView(),
                                arguments: {
                                  'clinic': service,
                                  'selectedDate': DateTime.now(),
                                  'selectedTimeSlot': 'Emergency Booking',
                                });
                          } else if (service.name == 'Home nursing') {
                            Get.to(() => const NursingBookingView(),
                                arguments: service);
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClinics(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Our Services',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Service>>(
                future: servicesController.fetchClinics(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                        child: Text('error'
                            .trParams({'error': snapshot.error.toString()})));
                  }

                  final clinics = snapshot.data ?? [];
                  if (clinics.isEmpty) {
                    return Center(child: Text('no_clinics_found'.tr));
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 3 / 4,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: clinics.length,
                    itemBuilder: (context, index) {
                      final clinic = clinics[index];
                      return ClinicCard(
                        title: clinic.name,
                        icon: clinic.imageUrl ?? 'assets/icons/abdominal.svg',
                        onTap: () {
                          Navigator.pop(context);
                          Get.toNamed('/booking', arguments: clinic);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOtherServices(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.4,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Other Services',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: 1,
                itemBuilder: (context, index) {
                  return ExtraServiceCard(
                    title: 'animal_care'.tr,
                    icon: 'assets/images/guide-dog 1.svg',
                    onTap: () {
                      Navigator.pop(context);
                      _showComingSoonDialog(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Coming soon',
            textAlign: TextAlign.center,
          ),
          content: Text(
            'coming_soon_msg'.tr,
            textAlign: TextAlign.center,
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('ok'.tr),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        );
      },
    );
  }
}
