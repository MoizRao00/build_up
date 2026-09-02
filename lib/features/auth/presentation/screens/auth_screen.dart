import 'package:build_up/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../step_tracking/presentation/widgets/glass_step_card.dart';
import '../providers/auth_provider.dart';


class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _submitLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter both email and password'),
            backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(authControllerProvider).signIn(email, password);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString()), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.jetBrainsMono(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  void _showForgotPasswordDialog() {

    final resetEmailController = TextEditingController(text: _emailController.text);

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: GlassCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reset Password',
                  style: GoogleFonts.sora(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Enter your email address. We will send you a link to reset your password.',
                  style: GoogleFonts.sora(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                _buildLabel('Email Address'),
                TextField(
                  controller: resetEmailController,
                  style: const TextStyle(color: Colors.white60),
                  decoration: InputDecoration(
                    hintText: 'runner@gmail.com',
                    hintStyle: const TextStyle(color: Colors.white60),
                    filled: true,
                    fillColor: AppColors.glassCardBackground,
                    prefixIcon: const Icon(Icons.mail_outline, color: Colors.white60),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      final email = resetEmailController.text.trim();
                      if (email.isEmpty) return;

                      try {
                        await ref.read(authControllerProvider).resetPassword(email);
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Password reset link sent to your email.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.sora(
                                  color: AppColors.backgroundDark,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              backgroundColor: AppColors.primaryEmerald,
                              behavior: SnackBarBehavior.floating,
                              margin: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 8,
                              duration: const Duration(seconds: 2),
                            ),
                          );

                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString()),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryEmerald,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      'Send Reset Link',
                      style: GoogleFonts.sora(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.sora(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Text(
                  'BUILD UP',
                  style: GoogleFonts.sora(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryEmerald,
                    letterSpacing: -1.0,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 40),
                GlassCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Email Address'),
                      TextField(
                        controller: _emailController,
                        style: const TextStyle(color: Colors.white60),
                        decoration: InputDecoration(
                          hintText: 'runner@gmail.com',
                          hintStyle: const TextStyle(color: Colors.white60),
                          filled: true,
                          fillColor:AppColors.glassCardBackground,
                          prefixIcon: const Icon(Icons.mail_outline,
                              color: Colors.white60),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding:
                          const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildLabel('Password'),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: GestureDetector(
                              onTap: _showForgotPasswordDialog,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  'Forgot?',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryEmerald,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: Colors.white60),
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          hintStyle: const TextStyle(color: Colors.white60),
                          filled: true,
                          fillColor: AppColors.glassCardBackground,
                          prefixIcon: const Icon(Icons.lock_outline,
                              color: Colors.white60),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.white60,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding:
                          const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 32),
                      if (_isLoading)
                        const Center(
                            child: CircularProgressIndicator(
                                color: AppColors.primaryEmerald))
                      else
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _submitLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryEmerald,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Login',
                              style: GoogleFonts.sora(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 32),
                      // Row(
                      //   children: [
                      //     Expanded(
                      //         child: Divider(
                      //             color: Colors.white.withOpacity(0.1))),
                      //     Padding(
                      //       padding:
                      //       const EdgeInsets.symmetric(horizontal: 16.0),
                      //       child: Text(
                      //         'OR CONNECT',
                      //         style: GoogleFonts.jetBrainsMono(
                      //           fontSize: 10,
                      //           fontWeight: FontWeight.w700,
                      //           color: AppColors.textSecondary,
                      //           letterSpacing: 1.0,
                      //         ),
                      //       ),
                      //     ),
                      //     Expanded(
                      //         child: Divider(
                      //             color: Colors.white.withOpacity(0.1))),
                      //   ],
                      // ),
                      // const SizedBox(height: 24),
                      // Row(
                      //   children: [
                      //     Expanded(
                      //       child: OutlinedButton.icon(
                      //         onPressed: () {},
                      //         icon:
                      //         const Icon(Icons.apple, color: Colors.white),
                      //         label: Text(
                      //           'APPLE',
                      //           style: GoogleFonts.jetBrainsMono(
                      //             color: Colors.white,
                      //             fontWeight: FontWeight.w700,
                      //           ),
                      //         ),
                      //         style: OutlinedButton.styleFrom(
                      //           padding:
                      //           const EdgeInsets.symmetric(vertical: 16),
                      //           side: BorderSide(
                      //               color: Colors.white.withOpacity(0.1)),
                      //           shape: RoundedRectangleBorder(
                      //             borderRadius: BorderRadius.circular(12),
                      //           ),
                      //           backgroundColor: Colors.black.withOpacity(0.2),
                      //         ),
                      //       ),
                      //     ),
                      //     const SizedBox(width: 16),
                      //     Expanded(
                      //       child: OutlinedButton.icon(
                      //         onPressed: () {},
                      //         icon: const Icon(Icons.g_mobiledata,
                      //             color: Colors.white, size: 32),
                      //         label: Text(
                      //           'GOOGLE',
                      //           style: GoogleFonts.jetBrainsMono(
                      //             color: Colors.white,
                      //             fontWeight: FontWeight.w700,
                      //           ),
                      //         ),
                      //         style: OutlinedButton.styleFrom(
                      //           padding:
                      //           const EdgeInsets.symmetric(vertical: 16),
                      //           side: BorderSide(
                      //               color: Colors.white.withOpacity(0.1)),
                      //           shape: RoundedRectangleBorder(
                      //             borderRadius: BorderRadius.circular(12),
                      //           ),
                      //           backgroundColor: Colors.black.withOpacity(0.2),
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignUpScreen()),
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.sora(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      children: [
                        const TextSpan(text: 'New to Build Up? '),
                        TextSpan(
                          text: 'Create Account',
                          style: GoogleFonts.sora(
                            color: AppColors.primaryEmerald,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}