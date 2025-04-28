import 'package:dirver/core/utils/colors_app.dart';
import 'package:dirver/features/passenger/presentation/views/widgets/address_field.dart';
import 'package:dirver/features/passenger/presentation/views/widgets/choose_driver_button.dart';
import 'package:dirver/features/passenger/presentation/views/widgets/clear_location_button.dart';
import 'package:dirver/features/passenger/presentation/views/widgets/list_view_widget.dart';
import 'package:dirver/features/passenger/presentation/views/widgets/price_field.dart';
import 'package:dirver/features/passenger/presentation/views/widgets/trip_button.dart';
import 'package:flutter/material.dart';

class BottomSheetWidget extends StatelessWidget {
  const BottomSheetWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // const TripStatusStreamer(),
          Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ChooseDriverButton(),
                ClearLocationButton(),
              ],
            ),
          ),
          
          _buildMainContent(context),
        ],
      ),
    );
  }



  Widget _buildMainContent(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackColor.withValues(alpha: 0.1),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ListViewWidget(),
          const SizedBox(height: 12),
          const AddressField(hintText: 'Destination'),
          const SizedBox(height: 12),
          const PriceField(),
          const SizedBox(height: 16),
          const TripButton(),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}

// class TripStatusStreamer extends StatelessWidget {
//   const TripStatusStreamer({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final tripProvider = context.watch<TripProvider>();

//     return StreamBuilder<DocumentSnapshot>(
//       stream: tripProvider.tripStream,
//       builder: (context, snapshot) {
//         final status = tripProvider.getCurrentStatus(snapshot.data);

//         if (status == 'not_created' || status == 'unknown' || status == 'cancelled') {
//           return const SizedBox.shrink();
//         }

//         return Container(
//           padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
//           margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
//           decoration: BoxDecoration(
//             color: _getStatusColor(status).withValues(alpha: 0.1),
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(
//               color: _getStatusColor(status).withValues(alpha: 0.2),
//               width: 1,
//             ),
//           ),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(4),
//                 decoration: BoxDecoration(
//                   color: _getStatusColor(status).withValues(alpha: 0.2),
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(
//                   _getStatusIcon(status),
//                   color: _getStatusColor(status),
//                   size: 18,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Text(
//                 _getStatusText(status),
//                 style: TextStyle(
//                   color: _getStatusColor(status),
//                   fontWeight: FontWeight.w600,
//                   fontSize: 14,
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Color _getStatusColor(String status) {
//     switch (status) {
//       case 'waiting':
//         return AppColors.orangeColor;
//       case 'in_progress':
//         return AppColors.primaryColor;
//       case 'completed':
//         return AppColors.grenColor;
//       case 'cancelled':
//         return AppColors.redColor;
//       default:
//         return AppColors.greyColor;
//     }
//   }

//   IconData _getStatusIcon(String status) {
//     switch (status) {
//       case 'waiting':
//         return Icons.access_time;
//       case 'in_progress':
//         return Icons.directions_car;
//       case 'completed':
//         return Icons.check_circle;
//       case 'cancelled':
//         return Icons.cancel;
//       default:
//         return Icons.help_outline;
//     }
//   }

//   String _getStatusText(String status) {
//     switch (status) {
//       case 'waiting':
//         return 'Waiting for driver';
//       case 'in_progress':
//         return 'Trip in progress';
//       case 'completed':
//         return 'Trip completed';
//       case 'cancelled':
//         return 'Trip cancelled';
//       default:
//         return 'Status: ${status.toUpperCase()}';
//     }
//   }
// }