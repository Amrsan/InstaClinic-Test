import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/edit_profile_dialog.dart';

String getTranslationKey(String dbValue) {
  switch (dbValue) {
    case 'Medical History':
      return 'medical_history';
    case 'Request History':
      return 'request_history';
    case 'Home':
      return 'home';
    // ...add more as needed
    default:
      return dbValue; // fallback to original
  }
}

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Refresh profile data when view is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchUserProfile();
    });
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Image
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                          child: Obx((){
                            final gender = controller.gender.value;
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                  gender=='Female'?
                                  "assets/images/female.jpeg"
                                    :
                                  'assets/images/male.jpeg',
                                fit: BoxFit.cover,
                              ),
                            );
                          })
                    ),
                    // Language and Logout Container
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF55B7B6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Text(
                                'language'.tr,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: DropdownButton<String>(
                                  value: Get.locale?.languageCode == 'ar' ? 'ar' : 'en',
                                  underline: const SizedBox(),
                                  icon: const Icon(Icons.arrow_drop_down, size: 20),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'en',
                                      child: Text('EN', style: TextStyle(fontSize: 14)),
                                    ),
                                    DropdownMenuItem(
                                      value: 'ar',
                                      child: Text('عربي', style: TextStyle(fontSize: 14)),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    if (value == 'ar') {
                                      Get.updateLocale(const Locale('ar'));
                                    } else {
                                      Get.updateLocale(const Locale('en'));
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Obx(() => TextButton.icon(
                            onPressed: () {
                              if (controller.isLogin.value) {
                                controller.signOut();
                                Get.offAllNamed('/login');
                              } else {
                                Get.offAllNamed('/login');
                              }
                            },
                            icon: Icon(
                              controller.isLogin.value? Icons.logout : Icons.login,
                              color: Colors.white,
                              size: 20,
                            ),
                            label: Text(
                              controller.isLogin.value ? 'logout'.tr : 'login'.tr,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          )),
                        ],
                      ),
                    ),
                  ],
                ),

                // Name and Edit Button
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() => Text(
                      controller.firstName.value.isNotEmpty && controller.lastName.value.isNotEmpty
                          ? '${controller.firstName} ${controller.lastName}'
                          : ' ',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    )),
                    Obx(() => controller.isLogin.value
                        ? IconButton(
                            icon: const Icon(Icons.edit, color: Color(0xFF55B7B6)),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return EditProfileDialog(controller: controller);
                                },
                              );
                            },
                          )
                        : const SizedBox()),
                  ],
                ),

                // Profile Information
                const SizedBox(height: 32),
                    // Labels row
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'date_of_birth'.tr + ' :',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black.withOpacity(0.6),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'gender'.tr + ' :',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black.withOpacity(0.6),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Values row
                    Row(
                      children: [
                        Expanded(
                          child: Obx(() => Text(
                            controller.birthDate.value.isNotEmpty
                                ? controller.birthDate.value
                                : ' ',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          )),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Obx(() => Text(
                                controller.gender.value.isNotEmpty
                                    ? controller.gender.value
                                    : ' ',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              )),
                              const SizedBox(width: 4),
                              const Text(
                                '♂',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                Obx(() => _buildInfoRow('email'.tr, controller.email.value.isNotEmpty ? controller.email.value : ' ')),
                Obx(() => _buildInfoRow('mobile_no'.tr, controller.phoneNumber.value.isNotEmpty ? controller.phoneNumber.value : ' ')),

                // Action Buttons
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        'medical_history'.tr,
                        Icons.history,
                        const Color(0xFF55B7B6),
                        () {
                          // Handle medical history
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildActionButton(
                        'request_history'.tr,
                        Icons.history,
                        const Color(0xFFE0E0E0),
                        () {
                          // Handle request history
                        },
                      ),
                    ),
                  ],
                ),

                // Addresses Section
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'home'.tr,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Obx(() => controller.isLogin.value
                        ? IconButton(
                            onPressed: () => Get.toNamed('/address'),
                            icon: const Icon(Icons.add, color: Color(0xFF55B7B6)),
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(0xFF55B7B6).withOpacity(0.1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          )
                        : const SizedBox()),
                  ],
                ),
                const SizedBox(height: 16),
                Obx(() => controller.addresses.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'no_addresses_found'.tr,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      )
                    : Column(
                        children: controller.addresses
                            .map((address) => _buildAddressCard(address))
                            .toList(),
                      )),

                const Divider(),

                // Contact Section at the bottom
                const SizedBox(height: 24),
                Text(
                  'contact us through'.tr,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Call Option
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final Uri phoneUri = Uri(
                            scheme: 'tel',
                            path: '01033298820',
                          );
                          if (await canLaunchUrl(phoneUri)) {
                            await launchUrl(phoneUri);
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Could not launch phone call'),
                                ),
                              );
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF55B7B6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.call, color: Colors.white, size: 24),
                              const SizedBox(height: 8),
                              Text('call'.tr, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // WhatsApp Option
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final Uri whatsappUri = Uri.parse('whatsapp://send?phone=201033298820&text=Hello, I need assistance with my InstaClinic account');
                          if (await canLaunchUrl(whatsappUri)) {
                            await launchUrl(whatsappUri);
                          } else {
                            // If WhatsApp is not installed, try opening in browser
                            final Uri webWhatsappUri = Uri.parse('https://wa.me/201033298820');
                            if (await canLaunchUrl(webWhatsappUri)) {
                              await launchUrl(webWhatsappUri);
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Could not launch WhatsApp'),
                                  ),
                                );
                              }
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF55B7B6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(
                                'assets/images/whatsapp-white-icon 1.svg',
                                colorFilter: const ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.srcIn,
                                ),
                                width: 24,
                                height: 24,
                              ),
                              const SizedBox(height: 8),
                              Text('whatsapp'.tr, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Email Option
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final Uri emailUri = Uri(
                            scheme: 'mailto',
                            path:    "instaclinic30@gmail.com",
                            queryParameters: {
                              'subject': 'InstaClinic Support',
                              'body': 'Hello, I need assistance with my InstaClinic account.',
                            },
                          );
                          if (await canLaunchUrl(emailUri)) {
                            await launchUrl(emailUri);
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Could not launch email'),
                                ),
                              );
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF55B7B6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.email, color: Colors.white, size: 24),
                              const SizedBox(height: 8),
                              Text('email'.tr, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Account Deletion Section (per App Store Guideline 5.1.1(v))
                Obx(() => controller.isLogin.value
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: () {
                                final authController = Get.find<AuthController>();
                                authController.deleteAccount();
                              },
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: 16,
                              ),
                              label: Text(
                                'delete_account'.tr,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox()),

                const SizedBox(height: 24),
              ],
            )),
          ),

      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: color == const Color(0xFFE0E0E0)
                      ? const Color(0xFF55B7B6)
                      : Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(Map<String, dynamic> address) {
    Get.dialog(
      AlertDialog(
        title: Text('delete_address'.tr),
        content: Text('delete_address_confirmation'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              try {
                await controller.deleteAddress(address['id']);
                Get.snackbar(
                  'success'.tr,
                  'address_deleted_successfully'.tr,
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 5),
                );
              } catch (e) {
                Get.snackbar(
                  'error'.tr,
                  'failed_to_delete_address'.tr,
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 5),

                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text('delete'.tr),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(Map<String, dynamic> address) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${address['area']}, ${address['city']}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              Row(
                children: [
                  Obx(() => controller.isLogin.value
                      ? IconButton(
                          icon: const Icon(Icons.edit, size: 20, color: Color(0xFF55B7B6)),
                          onPressed: () {
                            Get.toNamed('/address', arguments: address);
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFF55B7B6).withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        )
                      : const SizedBox()),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                    onPressed: () {
                      _showDeleteConfirmationDialog(address);
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.red.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${address['street']}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          Text(
            '${address['floor']} ${'floor'.tr}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          Text(
            '${'apt_no'.tr} ${address['apartment']}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.home, size: 16, color: Colors.black54),
              const SizedBox(width: 4),
              Text(
                getTranslationKey(address['type'] ?? 'Home').tr,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 
