import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sales_test_app/src/core/theme/app_colors.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();

  bool _obscure = true;
  late final AnimationController _anim =
  AnimationController(vsync: this, duration: const Duration(milliseconds: 700))
    ..forward();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    _anim.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(LoginSubmitted(_emailCtrl.text, _passCtrl.text));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.failure && state.error != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.error!)));
        }
        if (state.status == AuthStatus.success) {

          Navigator.of(context).pushReplacementNamed('/dashboard');
        }
      },
      builder: (context, state) {
        final loading = state.status == AuthStatus.submitting;

        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(), // dismiss keyboard
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withOpacity(.15),
                  AppColors.secondary.withOpacity(.15),
                  const Color(0xFFD1D5FF).withOpacity(.15),
                ],
              ),
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(
                child: LayoutBuilder(
                  builder: (ctx, c) {
                    final width = c.maxWidth;
                    final height = c.maxHeight;
                    final isWide = width >= 900;
                    final horizontalPad = width < 360
                        ? 12.0
                        : width < 480
                        ? 16.0
                        : 24.0;
                    final cardMaxWidth = math.min(520.0, width - (horizontalPad * 2));

                    final loginCard = FadeTransition(
                      opacity: CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: cardMaxWidth),
                        child: Card(
                          elevation: 10,
                          surfaceTintColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(width < 380 ? 18 : 28),
                            child: Form(
                              key: _formKey,
                              child: AutofillGroup(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      'Welcome back',
                                      style: text.headlineMedium?.copyWith(
                                        fontWeight: FontWeight.w800,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Sign in to manage customers, products & sales',
                                      style: text.bodyMedium?.copyWith(
                                        color: cs.onSurface.withOpacity(.65),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    // EMAIL
                                    TextFormField(
                                      controller: _emailCtrl,
                                      focusNode: _emailFocus,
                                      textInputAction: TextInputAction.next,
                                      keyboardType: TextInputType.emailAddress,
                                      autofillHints: const [AutofillHints.email],
                                      decoration: const InputDecoration(
                                        labelText: 'Email',
                                        prefixIcon: Icon(Icons.email_outlined),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(16)),
                                        ),
                                        filled: true,
                                      ),
                                      onFieldSubmitted: (_) =>
                                          FocusScope.of(context).requestFocus(_passFocus),
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty) {
                                          return 'Email is required';
                                        }
                                        if (!v.contains('@') || !v.contains('.')) {
                                          return 'Enter a valid email';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 14),
                                    // PASSWORD
                                    TextFormField(
                                      controller: _passCtrl,
                                      focusNode: _passFocus,
                                      textInputAction: TextInputAction.done,
                                      obscureText: _obscure,
                                      autofillHints: const [AutofillHints.password],
                                      onFieldSubmitted: (_) => _submit(),
                                      decoration: InputDecoration(
                                        labelText: 'Password',
                                        prefixIcon: const Icon(Icons.lock_outline),
                                        suffixIcon: IconButton(
                                          onPressed: () => setState(() => _obscure = !_obscure),
                                          icon: Icon(
                                            _obscure ? Icons.visibility_off : Icons.visibility,
                                          ),
                                          tooltip: _obscure ? 'Show password' : 'Hide password',
                                        ),
                                        border: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(16)),
                                        ),
                                        filled: true,
                                      ),
                                      validator: (v) =>
                                      (v == null || v.isEmpty) ? 'Password is required' : null,
                                    ),
                                    const SizedBox(height: 20),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 48,
                                      child: ElevatedButton(
                                        onPressed: loading ? null : _submit,
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                        ),
                                        child: loading
                                            ? const SizedBox(
                                          height: 22,
                                          width: 22,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                            : const Text('Sign in'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );

                    // Scrollable layout that works on tiny phones & landscape
                    final scrollable = SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        horizontalPad,
                        24,
                        horizontalPad,
                        // Add bottom padding equal to the keyboard inset so the button stays visible
                        MediaQuery.of(context).viewInsets.bottom + 24,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: height - 48),
                        child: Center(child: loginCard),
                      ),
                    );

                    if (!isWide) {
                      return scrollable; // phones & small tablets
                    }

                    // Wide layout: split screen hero + card
                    return Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 720),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Sales Manager',
                                      style: text.displaySmall?.copyWith(fontWeight: FontWeight.w900),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'A sleek way to manage customers, products and invoices in minutes.',
                                      style: text.titleMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(child: scrollable),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
