import "package:flutter/material.dart";

import "../features/assigned_claims/presentation/assigned_claims_page.dart";
import "../features/claim_submission/presentation/claim_submission_page.dart";
import "../features/investigation/presentation/investigation_page.dart";

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
      initialRoute: "/claim-submission",
      routes: {
        "/claim-submission": (_) => const ClaimSubmissionPage(),
        "/assigned-claims": (_) => const AssignedClaimsPage(),
        "/investigation": (_) => const InvestigationPage(),
      },
    );
  }
}
