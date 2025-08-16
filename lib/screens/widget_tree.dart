import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:socplus/pages/home_page.dart';
import 'package:socplus/pages/profile_page.dart';
import 'package:socplus/screens/about_screen.dart';
import 'package:socplus/screens/upload_post_screen.dart';
import 'package:socplus/services/auth_service.dart';
import 'package:socplus/widgets/search_app_bar.dart';

List<Widget> pages = [HomePage(), ProfilePage()];

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  final searchController = TextEditingController();

  Widget selectedPage = pages[0];
  PreferredSizeWidget? get appBar {
    if (selectedPage == pages[0]) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: Theme.of(context).colorScheme.surface,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor:
              Theme.of(context).colorScheme.surfaceContainer,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      );
      return SearchAppBar();
    } else if (selectedPage == pages[1]) {
      // return PreferredSize(
      //   preferredSize: Size(MediaQuery.of(context).size.width, 65),
      //   child: Container(
      //     height: double.infinity,
      //     width: double.infinity,
      //     padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      //     decoration: BoxDecoration(
      //       color: Theme.of(context).colorScheme.surface,
      //       borderRadius: BorderRadius.only(
      //         bottomLeft: Radius.circular(10),
      //         bottomRight: Radius.circular(10),
      //       ),
      //     ),
      //     child: Align(
      //       alignment: Alignment.centerLeft,
      //       child: Text("Profile Page", style: TextStyle(
      //         fontSize: 20,
      //         fontWeight: FontWeight.w500
      //       ),),
      //     ),
      //   ),
      // );
      return AppBar(title: Text("Profile Page"));
    } else {
      return null;
    }
  }

  Widget? get drawer {
    if (selectedPage == pages[1]) {
      return SafeArea(
        child: Drawer(
          child: Column(
            children: [
              InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return AboutScreen();
                },)),
                child: ListTile(title: Text("About")),
              ),
              InkWell(
                onTap: () => AuthService.logOut(context),
                child: ListTile(title: Text("Log out")),
              ),
            ],
          ),
        ),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: selectedPage,
      endDrawer: drawer,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) {
                return UploadPostScreen();
              },
            ),
          );
        },
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (value) {
          selectedPage = pages[value];
          setState(() {});
        },
        selectedIndex: pages.indexOf(selectedPage),
        destinations: [
          NavigationDestination(icon: Icon(Icons.home), label: "Home"),
          NavigationDestination(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
