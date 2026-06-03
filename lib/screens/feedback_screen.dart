import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../provider/auth_provider.dart';
import '../utils/theme.dart';
import '../services/exception_handler.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.currentUser?.email != null) {
      _emailController.text = auth.currentUser!.email!;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final user = auth.currentUser;

      // Saving to Firestore 'feedbacks' collection
      await FirebaseFirestore.instance.collection('feedbacks').add({
        'userId': user?.uid ?? 'anonymous',
        'email': _emailController.text.trim(),
        'feedback': _feedbackController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'platform': 'mac', // From user_information
        'recipientEmail': 'userfeedbackvectorlabz@gmail.com',
      });

      if (mounted) {
        ExceptionHandler.showSuccess('Feedback submitted successfully!');
        Navigator.pop(context);
      }
    } catch (e) {
      ExceptionHandler.handleException(e);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      appBar: AppBar(
        title: const Text('User Feedback'),
        backgroundColor: AppTheme.secondaryColor,
        foregroundColor: AppTheme.primaryColor,
        leading: IconButton(
          icon: Icon(
            AppTheme.backButtonIcon,
            size: AppTheme.backButtonIconSize(context),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppTheme.responsivePadding(context)),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'We value your feedback!',
                style: TextStyle(
                  fontSize: AppTheme.responsiveFont(context, phone: 20, tablet: 24),
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Please let us know how we can improve your experience. You can also reach us at userfeedbackvectorlabz@gmail.com',
                style: TextStyle(
                  fontSize: AppTheme.responsiveFont(context, phone: 14, tablet: 16),
                  color: AppTheme.primaryColor.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 30),

              _buildLabel('Your Email'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _emailController,
                hintText: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Email is required';
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              _buildLabel('Feedback'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _feedbackController,
                hintText: 'Write your feedback here...',
                maxLines: 6,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Feedback cannot be empty';
                  return null;
                },
              ),
              const SizedBox(height: 40),

              // Submit Button
              SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitFeedback,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: AppTheme.secondaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Submit Feedback',
                          style: TextStyle(
                            fontSize: AppTheme.responsiveFont(context, phone: 16, tablet: 18),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: AppTheme.responsiveFont(context, phone: 14, tablet: 16),
        fontWeight: FontWeight.w600,
        color: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(
        color: AppTheme.primaryColor,
        fontSize: AppTheme.responsiveFont(context, phone: 16, tablet: 18),
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: AppTheme.primaryColor.withOpacity(0.5)),
        filled: true,
        fillColor: AppTheme.tilescolor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.stokecolor, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.stokecolor, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }
}
