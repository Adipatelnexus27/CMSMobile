import "package:flutter/material.dart";

import "../features/claim_submission/presentation/claim_submission_page.dart";

class CmsApp extends StatelessWidget {
  const CmsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "CMS Mobile",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF005F73)),
        useMaterial3: true,
      ),
      home: const ClaimSubmissionPage(),
    );
  }
}
