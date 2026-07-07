import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../services/app_state.dart';
import '../widgets/theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _uploading = false;

  Future<void> _pickAndUpload() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 75, maxWidth: 400);
    if (picked == null) return;
    setState(() => _uploading = true);
    try {
      // Para web: convertir a base64 y guardar como URL de datos
      final bytes = await picked.readAsBytes();
      final base64 = 'data:image/jpeg;base64,${_toBase64(bytes)}';
      await context.read<AppState>().updateAvatar(base64);
      if (mounted) showMsg(context, '✅ Foto actualizada');
    } catch (e) {
      if (mounted) showMsg(context, '❌ Error al subir foto: $e', isError: true);
    }
    if (mounted) setState(() => _uploading = false);
  }

  String _toBase64(List<int> bytes) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    final result = StringBuffer();
    for (var i = 0; i < bytes.length; i += 3) {
      final b0 = bytes[i];
      final b1 = i + 1 < bytes.length ? bytes[i + 1] : 0;
      final b2 = i + 2 < bytes.length ? bytes[i + 2] : 0;
      result.write(chars[(b0 >> 2) & 0x3F]);
      result.write(chars[((b0 << 4) | (b1 >> 4)) & 0x3F]);
      result.write(i + 1 < bytes.length ? chars[((b1 << 2) | (b2 >> 6)) & 0x3F] : '=');
      result.write(i + 2 < bytes.length ? chars[b2 & 0x3F] : '=');
    }
    return result.toString();
  }

  @override
Widget build(BuildContext context) {
  final user = context.watch<AppState>().currentUser!;

  return Scaffold(
    backgroundColor: kBg,
    appBar: AppBar(
      title: const Text('👤 Mi Perfil'),
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
    body: Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          "assets/images/banners/perfil.jpeg",
          fit: BoxFit.cover,
        ),

        Container(
          color: Colors.black.withOpacity(0.65),
        ),

        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // AVATAR
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: kGold, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: kGold.withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 3,
                            )
                          ],
                        ),
                        child: ClipOval(
                          child: _uploading
                              ? const Center(
                                  child: CircularProgressIndicator(color: kGold),
                                )
                              : (user.avatarUrl != null &&
                                      user.avatarUrl!.isNotEmpty)
                                  ? Image.network(
                                      user.avatarUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          _initials(user),
                                    )
                                  : _initials(user),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _uploading ? null : _pickAndUpload,
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: const BoxDecoration(
                              color: kGold,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 18,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  user.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),

                const SizedBox(height: 4),

                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: roleColor(user.role).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: roleColor(user.role).withOpacity(0.4),
                    ),
                  ),
                  child: Text(
                    user.roleLabel,
                    style: TextStyle(
                      color: roleColor(user.role),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Container(
  width: double.infinity,
  padding: const EdgeInsets.all(18),
  decoration: BoxDecoration(
    color: const Color(0xFF111827).withOpacity(0.45),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: Colors.white.withOpacity(0.08),
    ),
  ),
  child: Column(
    children: [
      StatRow(
        label: 'Estado de cuenta',
        value: user.isActive ? '✅ Activa' : '❌ Suspendida',
        valueColor:
            user.isActive ? const Color(0xFF4ADE80) : Colors.red,
      ),
      StatRow(
        label: 'Tarjeta',
        value: '${user.cardType} Card',
      ),
      StatRow(
        label: 'Saldo SC',
        value: '\$${user.balance.toStringAsFixed(0)} SC',
        valueColor: kGold,
      ),
      StatRow(
        label: 'Miembro desde',
        value: user.createdAt != null
            ? '${user.createdAt!.day}/${user.createdAt!.month}/${user.createdAt!.year}'
            : '-',
      ),
    ],
  ),
),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}   
  Widget _initials(user) => Container(
    color: roleColor(user.role).withOpacity(0.2),
    child: Center(child: Text(user.initials, style: TextStyle(color: roleColor(user.role), fontWeight: FontWeight.bold, fontSize: 38))),
  );
}   
