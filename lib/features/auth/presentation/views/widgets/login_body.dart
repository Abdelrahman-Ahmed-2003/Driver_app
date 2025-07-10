import 'package:dirver/core/constant/asset_images.dart';
import 'package:dirver/core/sharedWidgets/logo_widget.dart';
import 'package:dirver/core/utils/colors_app.dart';
import 'package:dirver/core/utils/utils.dart';
import 'package:dirver/features/auth/presentation/state_managment/auth_provider.dart';
import 'package:dirver/features/auth/presentation/views/widgets/way_to_login.dart';
import 'package:dirver/features/driver_or_rider/presentation/views/driver_or_rider_view.dart';
import 'package:dirver/features/splash_screen/presentation/views/widgets/text_in_splash.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginBody extends StatelessWidget {
  const LoginBody({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Center(
      child: SingleChildScrollView(
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: BorderSide(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.cardBorderDark.withOpacity(0.10)
                  : AppColors.cardBorderLight.withOpacity(0.08),
              width: 1.2,
            ),
          ),
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.cardDark.withOpacity(0.92)
              : AppColors.cardLight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const LogoWidget(),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.asset(AssetImages.handShake, height: 180),
                ),
                const SizedBox(height: 18),
                TextInSplash(
                  text: 'Ease your Transportation with us',
                ),
                const SizedBox(height: 24),
                authProvider.isLoading == true?
                  const LinearProgressIndicator():
                
                WayToLogin(
                  text: "Google",
                  colorButton: AppColors.primaryColor,
                  colorText: AppColors.whiteColor,
                  onPressed: () async {
                    final user = await authProvider.signInWithGoogle();
                    if (user != null && context.mounted) {
                      Navigator.pushReplacementNamed(context, DriverOrRiderView.routeName);
                    } else if (authProvider.errorMessage != null && context.mounted) {
                      errorMessage(context, authProvider.errorMessage!);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
