import 'package:flutter/material.dart';
import '../services/database_service.dart';

class LoginScreen extends StatefulWidget {
  final bool isDarkMode; // Estado do tema escuro
  final VoidCallback onToggleTheme; // Callback para alternar o tema

  const LoginScreen({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final isValidUser = await DatabaseService.instance.validateUser(email, password);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (isValidUser) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login realizado com sucesso!')),
        );
        Navigator.pushNamed(context, '/home');
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('E-mail ou senha incorretos!')),
        );
      }
    }
  }

  void _navigateToRegister() {
    if (mounted) {
      Navigator.pushNamed(context, '/register');
    }
  }

  void _continueAsGuest() {
    if (mounted) {
      Navigator.pushNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDarkMode ? Colors.black : Colors.purple[800],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Botão de alternância de tema no canto superior direito
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(
                      widget.isDarkMode ? Icons.brightness_7 : Icons.brightness_2,
                      color: Colors.white,
                    ),
                    onPressed: widget.onToggleTheme,
                  ),
                ),
                // Área decorativa superior com ícone e texto
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(Icons.note_alt_outlined, size: 100, color: Colors.white),
                      const SizedBox(height: 16),
                      Text(
                        "Remember me",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Lembre-se de tudo!",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                // Formulário de login
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: "E-mail",
                            labelStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, insira o e-mail';
                            }
                            if (!RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                .hasMatch(value)) {
                              return 'Insira um e-mail válido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: "Senha",
                            labelStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, insira a senha';
                            }
                            if (value.length < 6) {
                              return 'A senha deve ter pelo menos 6 caracteres';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            minimumSize: const Size.fromHeight(50),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text("Entrar"),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton(
                          onPressed: _isLoading ? null : _navigateToRegister,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white),
                            minimumSize: const Size.fromHeight(50),
                          ),
                          child: const Text(
                            "Criar uma conta",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: _isLoading ? null : _continueAsGuest,
                          child: const Text(
                            "Continuar como visitante",
                            style: TextStyle(color: Colors.white70),
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
