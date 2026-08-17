// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../../app/theme/app_colors.dart';
// import '../../../step_tracking/presentation/widgets/glass_step_card.dart';
// import '../providers/auth_provider.dart';
//
// class LoginScreen extends ConsumerStatefulWidget {
//   const LoginScreen({super.key});
//
//   @override
//   ConsumerState<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends ConsumerState<LoginScreen> {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//
//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Text(
//                 'BUILD UP',
//                 style: TextStyle(
//                   fontSize: 32,
//                   fontWeight: FontWeight.bold,
//                   color: AppColors.textPrimary,
//                   letterSpacing: 2.0,
//                 ),
//               ),
//               const SizedBox(height: 40),
//               GlassCard(
//                 padding: const EdgeInsets.all(24),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     const Text(
//                       'Sign In',
//                       style: TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                         color: AppColors.textPrimary,
//                       ),
//                     ),
//                     const SizedBox(height: 24),
//                     TextField(
//                       controller: _emailController,
//                       decoration: InputDecoration(
//                         hintText: 'Email',
//                         hintStyle: const TextStyle(color: AppColors.textSecondary),
//                         filled: true,
//                         fillColor: AppColors.backgroundDark.withOpacity(0.5),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide.none,
//                         ),
//                       ),
//                       style: const TextStyle(color: AppColors.textPrimary),
//                     ),
//                     const SizedBox(height: 16),
//                     TextField(
//                       controller: _passwordController,
//                       obscureText: true,
//                       decoration: InputDecoration(
//                         hintText: 'Password',
//                         hintStyle: const TextStyle(color: AppColors.textSecondary),
//                         filled: true,
//                         fillColor: AppColors.backgroundDark.withOpacity(0.5),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide.none,
//                         ),
//                       ),
//                       style: const TextStyle(color: AppColors.textPrimary),
//                     ),
//                     const SizedBox(height: 24),
//                     ElevatedButton(
//                       onPressed: () {
//                         ref.read(authProvider.notifier).signIn(
//                           _emailController.text,
//                           _passwordController.text,
//                         );
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppColors.primaryEmerald,
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                       child: const Text(
//                         'Login',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }