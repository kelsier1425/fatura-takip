import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_constants.dart';

class IconPickerGrid extends StatelessWidget {
  final IconData selectedIcon;
  final Color selectedColor;
  final Function(IconData) onIconSelected;

  const IconPickerGrid({
    Key? key,
    required this.selectedIcon,
    required this.selectedColor,
    required this.onIconSelected,
  }) : super(key: key);

  static const List<IconData> icons = [
    // General
    Icons.category_outlined,
    Icons.star_outline,
    Icons.favorite_outline,
    Icons.bookmark_outline,
    Icons.lightbulb_outline,
    Icons.palette_outlined,
    
    // Personal
    Icons.person_outline,
    Icons.face_outlined,
    Icons.accessibility_outlined,
    Icons.wc_outlined,
    Icons.spa_outlined,
    Icons.self_improvement_outlined,
    
    // Health
    Icons.medical_services_outlined,
    Icons.local_hospital_outlined,
    Icons.healing_outlined,
    Icons.medication_outlined,
    Icons.psychology_outlined,
    Icons.fitness_center_outlined,
    
    // Clothing & Fashion
    Icons.checkroom_outlined,
    Icons.style_outlined,
    Icons.diamond_outlined,
    Icons.watch_outlined,
    Icons.shopping_bag_outlined,
    Icons.local_mall_outlined,
    
    // Transportation
    Icons.directions_car_outlined,
    Icons.directions_bus_outlined,
    Icons.directions_subway_outlined,
    Icons.flight_outlined,
    Icons.local_taxi_outlined,
    Icons.two_wheeler_outlined,
    
    // Entertainment
    Icons.movie_outlined,
    Icons.music_note_outlined,
    Icons.games_outlined,
    Icons.sports_soccer_outlined,
    Icons.sports_basketball_outlined,
    Icons.theater_comedy_outlined,
    
    // Technology
    Icons.computer_outlined,
    Icons.phone_android_outlined,
    Icons.tablet_outlined,
    Icons.tv_outlined,
    Icons.headphones_outlined,
    Icons.camera_alt_outlined,
    
    // Home & Living
    Icons.home_outlined,
    Icons.bed_outlined,
    Icons.chair_outlined,
    Icons.kitchen_outlined,
    Icons.bathtub_outlined,
    Icons.yard_outlined,
    
    // Utilities
    Icons.electrical_services_outlined,
    Icons.water_drop_outlined,
    Icons.local_fire_department_outlined,
    Icons.wifi_outlined,
    Icons.phone_outlined,
    Icons.router_outlined,
    
    // Food & Dining
    Icons.restaurant_outlined,
    Icons.local_cafe_outlined,
    Icons.local_pizza_outlined,
    Icons.cake_outlined,
    Icons.wine_bar_outlined,
    Icons.fastfood_outlined,
    
    // Shopping & Groceries
    Icons.shopping_cart_outlined,
    Icons.store_outlined,
    Icons.local_grocery_store_outlined,
    Icons.receipt_outlined,
    Icons.credit_card_outlined,
    Icons.attach_money_outlined,
    
    // Child & Baby
    Icons.child_care_outlined,
    Icons.baby_changing_station_outlined,
    Icons.toys_outlined,
    Icons.school_outlined,
    Icons.sports_esports_outlined,
    Icons.child_friendly_outlined,
    
    // Pets
    Icons.pets_outlined,
    Icons.cruelty_free_outlined,
    
    // Subscriptions & Services
    Icons.subscriptions_outlined,
    Icons.play_circle_outline,
    Icons.video_library_outlined,
    Icons.library_music_outlined,
    Icons.cloud_outlined,
    Icons.storage_outlined,
    
    // Work & Business
    Icons.work_outline,
    Icons.business_outlined,
    Icons.corporate_fare_outlined,
    Icons.meeting_room_outlined,
    Icons.event_outlined,
    Icons.schedule_outlined,
    
    // Travel & Vacation
    Icons.flight_takeoff_outlined,
    Icons.hotel_outlined,
    Icons.luggage_outlined,
    Icons.beach_access_outlined,
    Icons.landscape_outlined,
    Icons.camera_outlined,
    
    // Sports & Fitness
    Icons.sports_outlined,
    Icons.pool_outlined,
    Icons.hiking_outlined,
    Icons.surfing_outlined,
    Icons.snowboarding_outlined,
    Icons.golf_course_outlined,
    
    // Education
    Icons.school_outlined,
    Icons.menu_book_outlined,
    Icons.calculate_outlined,
    Icons.science_outlined,
    Icons.language_outlined,
    Icons.brush_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: icons.length,
        itemBuilder: (context, index) {
          final icon = icons[index];
          final isSelected = selectedIcon.codePoint == icon.codePoint;

          return GestureDetector(
            onTap: () => onIconSelected(icon),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected 
                    ? selectedColor 
                    : selectedColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: isSelected
                    ? Border.all(
                        color: selectedColor,
                        width: 2,
                      )
                    : null,
              ),
              child: Icon(
                icon,
                color: isSelected 
                    ? Colors.white 
                    : selectedColor,
                size: 20,
              ),
            ),
          )
          .animate()
          .fadeIn(
            delay: Duration(milliseconds: index * 10),
            duration: AppConstants.shortAnimation,
          )
          .scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1, 1),
            delay: Duration(milliseconds: index * 10),
            duration: AppConstants.shortAnimation,
          );
        },
      ),
    );
  }
}