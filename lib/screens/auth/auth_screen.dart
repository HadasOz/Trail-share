import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  bool _isLogin = true;
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      if (_isLogin) {
        await _authService.login(_emailCtrl.text.trim(), _passwordCtrl.text);
      } else {
        await _authService.register(_emailCtrl.text.trim(), _passwordCtrl.text, _nameCtrl.text.trim());
      }
    } catch (e) {
      setState(() => _error = 'שגיאה: ${e.toString()}');
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2E7D32), Color(0xFF81C784)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.terrain, size: 64, color: Colors.green),
                        const SizedBox(height: 8),
                        const Text('Trail Share', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        const Text('שתף את המסלול שלך', style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 24),
                        if (!_isLogin)
                          TextFormField(
                            controller: _nameCtrl,
                            decoration: const InputDecoration(labelText: 'שם מלא', prefixIcon: Icon(Icons.person)),
                            validator: (v) => v!.isEmpty ? 'הכנס שם' : null,
                          ),
                        if (!_isLogin) const SizedBox(height: 12),
                        TextFormField(
                          controller: _emailCtrl,
                          decoration: const InputDecoration(labelText: 'אימייל', prefixIcon: Icon(Icons.email)),
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) => v!.isEmpty ? 'הכנס אימייל' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _passwordCtrl,
                          decoration: const InputDecoration(labelText: 'סיסמה', prefixIcon: Icon(Icons.lock)),
                          obscureText: true,
                          validator: (v) => v!.length < 6 ? 'סיסמה חייבת להיות לפחות 6 תווים' : null,
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 12),
                          Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                        ],
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: _loading
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : Text(_isLogin ? 'התחברות' : 'הרשמה', style: const TextStyle(fontSize: 16)),
                          ),
                        ),
                        TextButton(
                          onPressed: () => setState(() { _isLogin = !_isLogin; _error = null; }),
                          child: Text(_isLogin ? 'אין לך חשבון? הירשם' : 'יש לך חשבון? התחבר'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
