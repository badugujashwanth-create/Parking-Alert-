import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';

class HowItWorksScreen extends StatelessWidget {
  const HowItWorksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final steps = [
      AppStrings.howItWorksStep1,
      AppStrings.howItWorksStep2,
      AppStrings.howItWorksStep3,
      AppStrings.howItWorksStep4,
    ];
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.howItWorksTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.separated(
          itemCount: steps.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            return ListTile(
              leading: CircleAvatar(
                child: Text('${index + 1}'),
              ),
              title: Text(steps[index]),
            );
          },
        ),
      ),
    );
  }
}
