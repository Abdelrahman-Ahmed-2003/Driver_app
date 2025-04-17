import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:pinput/pinput.dart';

class OTPScreen extends StatefulWidget {
  final String verificationId;
  OTPScreen({required this.verificationId});

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  TextEditingController otpController = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;
  bool isResendEnabled = false;
  int countdownTime = 60;

  void verifyOTP() async {
    String otp = otpController.text.trim();
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: widget.verificationId,
      smsCode: otp,
    );

    try {
      await auth.signInWithCredential(credential);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("OTP Verified Successfully!")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid OTP!")),
      );
    }
  }

  void startResendTimer() {
    setState(() {
      isResendEnabled = false;
      countdownTime = 60;
    });

    Future.delayed(Duration(seconds: 60), () {
      setState(() {
        isResendEnabled = true;
      });
    });
  }

  void resendOTP() async {
    setState(() {
      isResendEnabled = false;
      countdownTime = 60;
    });

    await auth.verifyPhoneNumber(
      phoneNumber: "+20**********", // Replace with stored phone number
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.message}")),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("OTP Resent!")),
        );
        startResendTimer();
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  @override
  void initState() {
    super.initState();
    startResendTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("OTP Verification")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Enter the 6-digit OTP sent to your phone."),
            SizedBox(height: 20),

            /// OTP Input Box
            Pinput(
              length: 6,
              controller: otpController,
              defaultPinTheme: PinTheme(
                width: 50,
                height: 50,
                textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            SizedBox(height: 20),

            /// Countdown Timer
            TimerCountdown(
              format: CountDownTimerFormat.secondsOnly,
              endTime: DateTime.now().add(Duration(seconds: countdownTime)),
              onEnd: () {
                setState(() {
                  isResendEnabled = true;
                });
              },
              timeTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 20),

            /// Verify Button
            ElevatedButton(
              onPressed: verifyOTP,
              child: Text("Verify OTP"),
            ),

            /// Resend OTP Button
            TextButton(
              onPressed: isResendEnabled ? resendOTP : null,
              child: Text(
                "Resend OTP",
                style: TextStyle(
                  color: isResendEnabled ? Colors.blue : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
