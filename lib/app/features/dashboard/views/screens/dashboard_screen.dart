library dashboard;

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:project_management/app/config/models/training_model.dart';
import 'package:project_management/app/config/routes/app_pages.dart';
import 'package:project_management/app/constans/app_constants.dart';
import 'package:project_management/app/shared_components/chatting_card.dart';
import 'package:project_management/app/shared_components/responsive_builder.dart';
import 'package:project_management/app/shared_components/project_card.dart';
import 'package:project_management/app/shared_components/search_field.dart';
import 'package:project_management/app/shared_components/selection_button.dart';
import 'package:project_management/app/shared_components/training_card.dart';
import 'package:project_management/app/shared_components/today_text.dart';
import 'package:project_management/app/utils/helpers/app_helpers.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../../shared_components/profile_tile.dart';

// models
import '../../../../config/models/profile_model.dart';

// binding
part '../../bindings/dashboard_binding.dart';

// controller
part '../../controllers/dashboard_controller.dart';

// component
part '../components/active_project_card.dart';
part '../components/header.dart';
part '../components/overview_header.dart';

part '../components/recent_messages.dart';
part '../components/sidebar.dart';
part '../components/team_member.dart';

class DashboardScreen extends GetView<DashboardController> {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: controller.scaffoldKey,
      drawer: (ResponsiveBuilder.isDesktop(context))
          ? null
          : Drawer(
              child: Padding(
                padding: const EdgeInsets.only(top: kSpacing),
                child: _Sidebar(data: controller.getSelectedProject()),
              ),
            ),
      body: SingleChildScrollView(
          child: ResponsiveBuilder(
        mobileBuilder: (context, constraints) {
          return Column(children: [
            const SizedBox(height: kSpacing * (kIsWeb ? 1 : 2)),
            _buildHeader(onPressedMenu: () => controller.openDrawer()),
            const SizedBox(height: kSpacing / 2),
            const Divider(),
            _buildProfile(),
            const SizedBox(height: kSpacing),
            _buildTrainingOverview(
              headerAxis: Axis.vertical,
              crossAxisCount: 6,
              crossAxisCellCount: 6,
            ),
            const SizedBox(height: kSpacing * 2),
          ]);
        },
        tabletBuilder: (context, constraints) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: (constraints.maxWidth < 950) ? 6 : 9,
                child: Column(
                  children: [
                    const SizedBox(height: kSpacing * (kIsWeb ? 1 : 2)),
                    _buildHeader(onPressedMenu: () => controller.openDrawer()),
                    const SizedBox(height: kSpacing * 2),
                    _buildTrainingOverview(
                      headerAxis: (constraints.maxWidth < 850)
                          ? Axis.vertical
                          : Axis.horizontal,
                      crossAxisCount: 6,
                      crossAxisCellCount: (constraints.maxWidth < 950)
                          ? 6
                          : (constraints.maxWidth < 1100)
                              ? 3
                              : 2,
                    ),
                    const SizedBox(height: kSpacing * 2),
                  ],
                ),
              ),
              Flexible(
                flex: 4,
                child: Column(
                  children: [
                    const SizedBox(height: kSpacing * (kIsWeb ? 0.5 : 1.5)),
                    _buildProfile(),
                    const Divider(thickness: 1),
                    const SizedBox(height: kSpacing),
                  ],
                ),
              )
            ],
          );
        },
        desktopBuilder: (context, constraints) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: (constraints.maxWidth < 1360) ? 4 : 3,
                child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(kBorderRadius),
                      bottomRight: Radius.circular(kBorderRadius),
                    ),
                    child: _Sidebar(data: controller.getSelectedProject())),
              ),
              Flexible(
                flex: 9,
                child: Column(
                  children: [
                    const SizedBox(height: kSpacing),
                    _buildHeader(),
                    const SizedBox(height: kSpacing * 2),
                    _buildTrainingOverview(
                      crossAxisCount: 6,
                      crossAxisCellCount: (constraints.maxWidth < 1360) ? 3 : 2,
                    ),
                  ],
                ),
              ),
              Flexible(
                flex: 3,
                child: Column(
                  children: [
                    const SizedBox(height: kSpacing / 2),
                    _buildProfile(),
                    const Divider(thickness: 1),
                    const SizedBox(height: kSpacing),
                  ],
                ),
              )
            ],
          );
        },
      )),
    );
  }

  Widget _buildHeader({Function()? onPressedMenu}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpacing),
      child: Row(
        children: [
          if (onPressedMenu != null)
            Padding(
              padding: const EdgeInsets.only(right: kSpacing),
              child: IconButton(
                onPressed: onPressedMenu,
                icon: const Icon(EvaIcons.menu),
                tooltip: "menu",
              ),
            ),
          const Expanded(child: _Header()),
        ],
      ),
    );
  }

  Widget _buildTrainingOverview({
    int crossAxisCount = 6,
    int crossAxisCellCount = 2,
    Axis headerAxis = Axis.horizontal,
  }) {
    return FutureBuilder<List<TrainingModel>>(
      future: controller._getTrainingData(),
      builder:
          (BuildContext context, AsyncSnapshot<List<TrainingModel>> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final trainingData = snapshot.data!;

            return StaggeredGridView.countBuilder(
              crossAxisCount: crossAxisCount,
              itemCount: trainingData.length,
              addAutomaticKeepAlives: false,
              padding: const EdgeInsets.symmetric(horizontal: kSpacing),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final data = trainingData[index];

                return TrainingCard(
                  data: data,
                  onPressedMore: () {
                    Get.toNamed(AppPages.trainingDetails,
                        arguments: {'trainingData': data});
                  },
                  onPressedTask: () {},
                  onPressedContributors: () {},
                  onPressedComments: () {},
                );
              },
              staggeredTileBuilder: (int index) =>
                  StaggeredTile.fit(crossAxisCellCount),
            );
          }
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  Widget _buildProfile() {
    return StreamBuilder<QuerySnapshot<Object?>>(
      stream: controller._getProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Stream is still loading, show a loading indicator
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // Error occurred while fetching the data
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          // No data found
          return const Text('No profile documents found');
        } else {
          // Data has been successfully received
          List<ProfileModel> profiles = [];

          for (var doc in snapshot.data!.docs) {
            // Access the fields of the document
            var name = (doc.data()! as Map)['name'];
            var email = (doc.data()! as Map)['email'];
            var trainings = (doc.data()! as Map)['inBasket']['trainings'];
            var totalPrice = (doc.data()! as Map)['inBasket']['totalPrice'];

            // Create a ProfileModel instance using the retrieved fields
            var profileModel = ProfileModel(
              name: name,
              email: email,
              trainings: trainings,
              totalPrice: totalPrice,
            );

            // Add the profileModel to the list
            profiles.add(profileModel);
          }
          List<String> castedTrainings = profiles[0].trainings!.cast<String>();
          print("##### ${castedTrainings}");

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: kSpacing),
            child: ProfilTile(
              data: profiles[0],
              onPressed: () {
                // var profiles[0].trainings;
                print(
                    "##### dashboard_screen.dart => onPressed() => ProfilTile => _buildProfile() ::: ${profiles[0].trainings}");
                print(
                    "##### dashboard_screen.dart => onPressed() => ProfilTile => _buildProfile() ::: ${profiles[0].totalPrice}");
                Get.toNamed(AppPages.cart, arguments: {
                  'trainings': castedTrainings,
                  "totalPrice": profiles[0].totalPrice
                });
              },
            ),
          );
        }
      },
    );
  }
}
