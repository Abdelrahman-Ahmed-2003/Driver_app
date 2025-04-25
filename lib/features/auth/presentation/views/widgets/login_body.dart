import 'package:dirver/core/constant/asset_images.dart';
import 'package:dirver/core/sharedWidgets/logo_widget.dart';
import 'package:dirver/core/utils/colors_app.dart';
import 'package:dirver/core/utils/utils.dart';
import 'package:dirver/features/auth/presentation/state_managment/auth_bloc.dart';
import 'package:dirver/features/auth/presentation/state_managment/auth_state.dart';
import 'package:dirver/features/auth/presentation/views/widgets/way_to_login.dart';
import 'package:dirver/features/driver_or_rider/presentation/views/driver_or_rider_view.dart';
import 'package:dirver/features/splash_screen/presentation/views/widgets/text_in_splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class LoginBody extends StatelessWidget {
  const LoginBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          const LogoWidget(),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          Image.asset(AssetImages.handShake, height: 300),
          TextInSplash(text: 'Ease your Transportation with us'),
          const Spacer(),
          // WayToLogin(
          //   text: 'Phone number',
          //   colorButton: Colors.black,
          //   colorText: Colors.white,
          //   onPressed: () {
          //     Navigator.pushReplacementNamed(
          //       context,
          //       MaterialPageRoute(builder: (context) => const Fields()),
          //     );
          //   },
          // ),
          const SizedBox(height: 10),
          BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is LoginSuccess) {
                errorMessage(context, "login success");
                Navigator.pushReplacementNamed(
                    context, DriverOrRiderView.routeName);
              } else if (state is LoginFailure) {
                errorMessage(context, state.errorMessage);
              }
                },
                builder:(context, state) {
                  if (state is LoginLoading) {
                return const LinearProgressIndicator();
              }
              return WayToLogin(
            text: "Google",
            colorButton: AppColors.primaryColor,
            colorText: AppColors.blackColor,
            onPressed: () async {
              final authCubit = context.read<AuthBloc>();
              authCubit.signInWithGoogle();
            },
          );
              
                },
              )
        ],
      ),
    );
  }
}
