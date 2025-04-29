import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart'; // For handling PlatformException
import 'package:permission_handler/permission_handler.dart'; // Import the permission_handler package


class FingerprintAuthScreen extends StatefulWidget {
  const FingerprintAuthScreen({super.key});

  @override
  _FingerprintAuthScreenState createState() => _FingerprintAuthScreenState();
}

class _FingerprintAuthScreenState extends State<FingerprintAuthScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _canCheckBiometrics = false;
  bool _isAuthenticating = false;
  String _authorized = 'Not Authorized';
  String _authError = 'No Error'; // Store any error message
  bool _hasBiometrics = false;
  List<BiometricType> _availableBiometrics = <BiometricType>[];


  // Function to check biometric availability and permissions
  Future<void> _checkAndRequestPermissions() async {
    try {
      // Request biometric permission.  Important for Android!
      final status = await Permission.sensors.request();

      if (status.isGranted) {
        _checkBiometrics(); //check the device capability
        _getAvailableBiometrics();
      } else {
        setState(() {
          _authError = 'Biometric permission denied.';
          _authorized = 'Failed';
        });
        _showSnackBar('Biometric permission was denied. Please enable it in settings.'); //show message to user
      }
    } on PlatformException catch (e) {
      setState(() {
        _authError = 'Error requesting permission: ${e.message}';
        _authorized = 'Failed';
      });
      _showSnackBar('Error requesting biometric permission: ${e.message}');
    }
  }

  //check the device capability
  Future<void> _checkBiometrics() async {
    late bool canCheck;
    try {
      canCheck = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      canCheck = false;
      setState(() {
        _authError = 'Error checking biometrics: ${e.message}';
        _authorized = 'Failed';
      });
      _showSnackBar('Error checking biometrics: ${e.message}');
    }
    if (!mounted) {
      return;
    }

    setState(() {
      _canCheckBiometrics = canCheck;
    });
  }

  //get the avaliable biometrics
  Future<void> _getAvailableBiometrics() async {
    late List<BiometricType> availableBiometrics;
    try {
      availableBiometrics = await auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      availableBiometrics = <BiometricType>[];
      setState(() {
        _authError = 'Error getting available biometrics: ${e.message}';
        _authorized = 'Failed';
      });
      _showSnackBar('Error getting available biometrics: ${e.message}');
    }
    if (!mounted) {
      return;
    }

    setState(() {
      _availableBiometrics = availableBiometrics;
      _hasBiometrics = availableBiometrics.isNotEmpty;
    });
  }

  //show message to user
  void _showSnackBar(String message) {
    if (mounted) { //check the context
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  // Function to authenticate with biometrics
  Future<void> _authenticateWithBiometrics() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
      _authorized = 'Authenticating';
      _authError = 'No Error'; // Clear any previous error
    });

    try {
      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Scan your fingerprint to authenticate', //show to user
        options: const AuthenticationOptions(
          useErrorDialogs: false, // Suppress the default error dialogs
          stickyAuth: true, // Keep authentication session active
        ),
      );

      setState(() {
        _authorized = didAuthenticate ? 'Authorized' : 'Not Authorized';
      });
      if (didAuthenticate) {
        // Navigate to the main part of your application upon successful authentication.
        // For example:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainApp()), // Replace MainApp()
        );
      }
    } on PlatformException catch (e) {
      setState(() {
        _authorized = 'Failed';
        _authError = 'Error: ${e.message}';
      });
      _showSnackBar('Authentication error: ${e.message}'); // Show error
    } finally {
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _checkAndRequestPermissions(); //check all the permissions
  }

  @override
  void dispose() {
    auth.stopAuthentication(); //cancel
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fingerprint Authentication'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Current State: $_authorized\nError: $_authError', style: textStyle?.headlineSmall),
            const SizedBox(height: 16),
            Text('Can check biometrics: $_canCheckBiometrics\n'
                'Has biometrics: $_hasBiometrics\n'
                'Available biometrics: $_availableBiometrics\n',
                style: textStyle?.bodySmall),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _authenticateWithBiometrics,
              child: const Text('Authenticate with Biometrics'),
            ),
          ],
        ),
      ),
    );
  }
}

//dummy main app
class MainApp extends StatelessWidget{
  const MainApp({super.key});
  @override
  Widget build(BuildContext context){
    return const Scaffold(
      body: Center(
        child: Text("Welcome to Main App"),
      ),
    );
  }
}
