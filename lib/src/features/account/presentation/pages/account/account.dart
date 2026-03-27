import 'package:flutter/material.dart';
import 'package:online_course/core/utils/dummy_data.dart';
import 'package:online_course/src/features/account/presentation/pages/account/widgets/account_appbar.dart';
import 'package:online_course/src/features/account/presentation/pages/account/widgets/account_profile_block.dart';
import 'package:online_course/src/features/account/presentation/pages/account/widgets/account_section1.dart';
import 'package:online_course/src/features/account/presentation/pages/account/widgets/account_section2.dart';
import 'package:online_course/src/features/account/presentation/pages/account/widgets/account_section3.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ REMOVED: backgroundColor - uses theme
      body: CustomScrollView(
        slivers: <Widget>[
          const SliverAppBar(
            // ✅ REMOVED: backgroundColor - uses theme
            pinned: true,
            snap: true,
            floating: true,
            title: AccountAppBar(),
          ),
          SliverToBoxAdapter(child: _buildBody())
        ],
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      child: Column(
        children: [
          AccountProfileBlock(profile: profile),
          const SizedBox(height: 30),
          // const AccountRecordBlock(), // Uncomment if needed
          // const SizedBox(height: 20),
          const AccountBlock1(),
          const SizedBox(height: 16),
          const AccountBlock2(),
          const SizedBox(height: 16),
          const AccountBlock3(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
