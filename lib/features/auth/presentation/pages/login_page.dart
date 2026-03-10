import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "../bloc/auth_bloc.dart";
import "../bloc/auth_event.dart";
import "../bloc/auth_state.dart";

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<AuthBloc>().add(
          AuthLoginRequested(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isLoading = state.status == AuthStatus.loading;

                    return Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "CMS Mobile Login",
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Sign in to access assigned claims and investigation workflows.",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: "Email",
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Email is required.";
                              }

                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: "Password",
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Password is required.";
                              }

                              return null;
                            },
                          ),
                          if (state.errorMessage != null && state.errorMessage!.trim().isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Text(
                              state.errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _submit,
                              child: Text(isLoading ? "Signing In..." : "Login"),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
