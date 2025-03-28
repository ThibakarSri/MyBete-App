import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mybete_app/diabete_options.dart';
import 'package:mybete_app/sign_up_screen.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Change the email controller to username controller
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  // Change email error to username error
  String? _usernameError;
  String? _passwordError;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Define color palette
  final Color primaryColor = const Color(0xFF5FB8DD);
  final Color secondaryColor = const Color(0xFF5EB7CF);
  final Color lightBlueBackground = const Color(0xFFC5EDFF);
  final Color veryLightBlue = const Color(0xFFAEECFF);
  final Color mediumBlue = const Color(0xFF89D0ED);
  final Color darkTextColor = const Color(0xFF333333);
  final Color mediumTextColor = const Color(0xFF666666);
  final Color lightTextColor = const Color(0xFF999999);

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Start the animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Update the validation method for username
  void _validateUsername() {
    final username = usernameController.text.trim();
    if (username.isEmpty) {
      setState(() {
        _usernameError = "Username is required";
      });
    }
    else {
      setState(() {
        _usernameError = null;
      });
    }
  }

  void _validatePassword() {
    final password = passwordController.text;
    if (password.isEmpty) {
      setState(() {
        _passwordError = "Password is required";
      });
    } else if (password.length < 6) {
      setState(() {
        _passwordError = "Password must be at least 6 characters";
      });
    } else {
      setState(() {
        _passwordError = null;
      });
    }
  }

  // Update the login method to use username instead of email
  Future<void> login() async {
    _validateUsername();
    _validatePassword();

    if (_usernameError != null || _passwordError != null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // First, query Firestore to get the email associated with the username
      final querySnapshot = await _firestore
          .collection("users")
          .doc(usernameController.text.trim())
          .get();

      if (!querySnapshot.exists) {
        setState(() {
          _usernameError = "Username not found";
          _isLoading = false;
        });
        return;
      }

      // Get the email from the document
      final userEmail = querySnapshot.data()?["email"] as String;

      // Now use the email to authenticate with Firebase
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: userEmail,
        password: passwordController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => DiabeteOptions(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: const Interval(0.4, 1.0))
            );

            return FadeTransition(
              opacity: fadeAnimation,
              child: SlideTransition(position: offsetAnimation, child: child),
            );
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      String errorMessage = "An error occurred. Please try again.";
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            errorMessage = "No user found with this username.";
            break;
          case 'wrong-password':
            errorMessage = "Incorrect password.";
            break;
          case 'invalid-email':
            errorMessage = "Invalid username format.";
            break;
          case 'user-disabled':
            errorMessage = "This account has been disabled.";
            break;
          default:
            errorMessage = "Authentication failed: ${e.message}";
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: Colors.red.shade800,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          )
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToSignUp() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => SignupPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: const Interval(0.4, 1.0))
          );

          return FadeTransition(
            opacity: fadeAnimation,
            child: SlideTransition(position: offsetAnimation, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  void _signInWithGoogle() {
    // Implement Google Sign In
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Google Sign In - Coming soon",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        )
    );
  }

  void _signInWithApple() {
    // Implement Apple Sign In
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Apple Sign In - Coming soon",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive design
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 450,
                  minHeight: screenSize.height * 0.8,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Card(
                        elevation: 4,
                        shadowColor: Colors.black12,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(isSmallScreen ? 20.0 : 28.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Header with animation
                              _buildAnimatedHeader(isSmallScreen),

                              SizedBox(height: isSmallScreen ? 24 : 32),

                              // Tab Bar
                              Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  color: lightBlueBackground,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: primaryColor,
                                          borderRadius: BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                              color: primaryColor.withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () {},
                                            borderRadius: BorderRadius.circular(16),
                                            child: Center(
                                              child: Text(
                                                "Log In",
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                  fontSize: isSmallScreen ? 14 : 16,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: _navigateToSignUp,
                                            borderRadius: BorderRadius.circular(16),
                                            child: Center(
                                              child: Text(
                                                "Sign Up",
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w600,
                                                  color: darkTextColor,
                                                  fontSize: isSmallScreen ? 14 : 16,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: isSmallScreen ? 24 : 32),

                              // Email Field with animation
                              _buildAnimatedEmailField(isSmallScreen),

                              SizedBox(height: isSmallScreen ? 16 : 20),

                              // Password Field with animation
                              _buildAnimatedPasswordField(isSmallScreen),

                              const SizedBox(height: 8),

                              // Forgot Password
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(0, 0),
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    "Forgot password?",
                                    style: GoogleFonts.poppins(
                                      color: secondaryColor,
                                      fontWeight: FontWeight.w500,
                                      fontSize: isSmallScreen ? 13 : 14,
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: isSmallScreen ? 24 : 32),

                              // Sign In Button with animation
                              _buildAnimatedSignInButton(isSmallScreen),

                              SizedBox(height: isSmallScreen ? 24 : 32),

                              // Or With Divider
                              _buildAnimatedDivider(isSmallScreen),

                              SizedBox(height: isSmallScreen ? 24 : 32),

                              // Google Sign In with animation
                              _buildAnimatedGoogleButton(isSmallScreen),

                              SizedBox(height: isSmallScreen ? 16 : 20),

                              // Apple Sign In with animation
                              _buildAnimatedAppleButton(isSmallScreen),
                            ],
                          ),
                        ),
                      ),
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

  // Extracted methods for animations to avoid the 'delay' parameter error
  Widget _buildAnimatedHeader(bool isSmallScreen) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Column(
        children: [
          Text(
            "Welcome to MyBete",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 24 : 28,
              fontWeight: FontWeight.bold,
              color: darkTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Login or Sign up to access your account",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 14 : 16,
              color: mediumTextColor,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // Update the _buildAnimatedEmailField method to show username field instead
  Widget _buildAnimatedEmailField(bool isSmallScreen) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(30 * (1 - value), 0),
            child: child,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: lightBlueBackground,
              borderRadius: BorderRadius.circular(16),
              border: _usernameError != null
                  ? Border.all(color: Colors.red.shade400, width: 1.5)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: veryLightBlue.withOpacity(0.5),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: usernameController,
              onChanged: (_) {
                if (_usernameError != null) {
                  _validateUsername();
                }
              },
              onSubmitted: (_) => _validateUsername(),
              style: GoogleFonts.poppins(
                fontSize: isSmallScreen ? 14 : 16,
                color: darkTextColor,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: "Username",
                hintStyle: GoogleFonts.poppins(
                  color: lightTextColor,
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: Icon(
                  Icons.person_outline,
                  color: mediumTextColor,
                  size: isSmallScreen ? 20 : 22,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  vertical: isSmallScreen ? 16 : 18,
                ),
              ),
            ),
          ),
          if (_usernameError != null)
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 6),
              child: Text(
                _usernameError!,
                style: GoogleFonts.poppins(
                  color: Colors.red.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnimatedPasswordField(bool isSmallScreen) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(30 * (1 - value), 0),
            child: child,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: lightBlueBackground,
              borderRadius: BorderRadius.circular(16),
              border: _passwordError != null
                  ? Border.all(color: Colors.red.shade400, width: 1.5)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: veryLightBlue.withOpacity(0.5),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: passwordController,
              obscureText: _obscurePassword,
              onChanged: (_) {
                if (_passwordError != null) {
                  _validatePassword();
                }
              },
              onSubmitted: (_) => _validatePassword(),
              style: GoogleFonts.poppins(
                fontSize: isSmallScreen ? 14 : 16,
                color: darkTextColor,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: "Password",
                hintStyle: GoogleFonts.poppins(
                  color: lightTextColor,
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: Icon(
                  Icons.lock_outline,
                  color: mediumTextColor,
                  size: isSmallScreen ? 20 : 22,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: mediumTextColor,
                    size: isSmallScreen ? 20 : 22,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  vertical: isSmallScreen ? 16 : 18,
                ),
              ),
            ),
          ),
          if (_passwordError != null)
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 6),
              child: Text(
                _passwordError!,
                style: GoogleFonts.poppins(
                  color: Colors.red.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnimatedSignInButton(bool isSmallScreen) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _isLoading ? null : login,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade300,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            shadowColor: primaryColor.withOpacity(0.5),
          ),
          child: _isLoading
              ? SizedBox(
            height: isSmallScreen ? 20 : 24,
            width: isSmallScreen ? 20 : 24,
            child: const CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
              : Text(
            "Sign In",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: isSmallScreen ? 15 : 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedDivider(bool isSmallScreen) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: Colors.grey.shade300,
              thickness: 1.2,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Or With",
              style: GoogleFonts.poppins(
                color: mediumTextColor,
                fontWeight: FontWeight.w500,
                fontSize: isSmallScreen ? 13 : 14,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: Colors.grey.shade300,
              thickness: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedGoogleButton(bool isSmallScreen) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: OutlinedButton.icon(
          onPressed: _signInWithGoogle,
          icon: Container(
            width: isSmallScreen ? 18 : 22,
            height: isSmallScreen ? 18 : 22,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/google_logo.png'),
                fit: BoxFit.contain,
              ),
            ),
          ),
          label: Text(
            "Sign up with Google",
            style: GoogleFonts.poppins(
              color: darkTextColor,
              fontWeight: FontWeight.w500,
              fontSize: isSmallScreen ? 14 : 15,
            ),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            side: BorderSide(
              color: mediumBlue,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedAppleButton(bool isSmallScreen) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: OutlinedButton.icon(
          onPressed: _signInWithApple,
          icon: Icon(
            Icons.apple,
            size: isSmallScreen ? 22 : 24,
            color: darkTextColor,
          ),
          label: Text(
            "Sign up with Apple",
            style: GoogleFonts.poppins(
              color: darkTextColor,
              fontWeight: FontWeight.w500,
              fontSize: isSmallScreen ? 14 : 15,
            ),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            side: BorderSide(
              color: mediumBlue,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}

