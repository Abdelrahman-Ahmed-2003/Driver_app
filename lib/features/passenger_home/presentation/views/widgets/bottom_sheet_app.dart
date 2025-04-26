import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dirver/core/utils/colors_app.dart';
import 'package:dirver/features/passenger_home/presentation/provider/content_of_trip_provider.dart';
import 'package:dirver/features/passenger_home/presentation/provider/tripProvider.dart';
import 'package:dirver/features/passenger_home/presentation/views/widgets/address_field.dart';
import 'package:dirver/features/passenger_home/presentation/views/widgets/list_view_widget.dart';
import 'package:dirver/features/passenger_home/presentation/views/widgets/price_field.dart';
import 'package:dirver/features/passenger_home/presentation/views/widgets/search_button.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class BottomSheetWidget extends StatelessWidget {
  const BottomSheetWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const TripStatusStreamer(),
          _buildClearLocationButton(context),
          _buildMainContent(),
        ],
      ),
    );
  }

  Widget _buildClearLocationButton(BuildContext context) {
    final tripProvider = context.watch<TripProvider>();
    return Align(
      alignment: Alignment.bottomRight,
      child: Container(
        decoration: BoxDecoration(
          color: tripProvider.tripStream != null ? AppColors.greyColor : AppColors.primaryColor,
          borderRadius: const BorderRadius.all(Radius.circular(25)),
        ),
        height: 50,
        width: 50,
        margin: const EdgeInsets.only(right: 12, bottom: 8),
        child: IconButton(
          onPressed: () {
            if(tripProvider.tripStream != null) return;
            final provider = context.read<ContentOfTripProvider>();
            provider.toController.clear();
            provider.priceController.clear();
            provider.setFrom('');
            provider.setPrice('');
            provider.setDest(LatLng(0, 0));
            provider.setCurrentPoints(LatLng(0, 0));
            provider.points.clear();
            provider.lastDest = null;
          },
          icon: const Icon(Icons.wrong_location_outlined, color: AppColors.whiteColor),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.blackColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      height: 250,
      width: double.infinity,
      child: const Column(
        children: [
          ListViewWidget(),
          AddressField(hintText: 'To'),
          PriceField(),
          SearchButton(),
        ],
      ),
    );
  }
}

class TripStatusStreamer extends StatelessWidget {
  const TripStatusStreamer({super.key});

  @override
  Widget build(BuildContext context) {
    final tripProvider = context.watch<TripProvider>();

    return StreamBuilder<DocumentSnapshot>(
      stream: tripProvider.tripStream,
      builder: (context, snapshot) {
        final status = tripProvider.getCurrentStatus(snapshot.data);

        if (status == 'not_created' || status == 'unknown' || status == 'cancelled') {
          return const SizedBox.shrink(); // Hide when no trip or cancelled
        }

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: _getStatusColor(status).withValues(
  alpha: 0.4, // 0.2 * 255
  
),

            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getStatusIcon(status),
                color: _getStatusColor(status),
              ),
              const SizedBox(width: 8),
              Text(
                _getStatusText(status),
                style: TextStyle(
                  color: _getStatusColor(status),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'waiting':
        return AppColors.orangeColor;
      case 'in_progress':
        return AppColors.blueColor;
      case 'completed':
        return AppColors.grenColor;
      case 'cancelled':
        return AppColors.redColor;
      default:
        return AppColors.greyColor;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'waiting':
        return Icons.access_time;
      case 'in_progress':
        return Icons.directions_car;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'waiting':
        return 'Waiting for driver';
      case 'in_progress':
        return 'Trip in progress';
      case 'completed':
        return 'Trip completed';
      case 'cancelled':
        return 'Trip cancelled';
      default:
        return 'Status: ${status.toUpperCase()}';
    }
  }
}

