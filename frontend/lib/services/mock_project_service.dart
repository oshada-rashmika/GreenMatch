class MockProjectService {
  Future<List<Map<String, dynamic>>> fetchAnonymousProjects() async {
    await Future.delayed(
      const Duration(seconds: 1),
    ); // Simulate network latency
    return [
      {
        "id": "proj_123",
        "title": "Predictive ML for Data Storage",
        "abstract": "Using Machine Learning to predict error-prone sequences.",
        "techStack": ["Python", "TensorFlow", "FastAPI"],
        "researchArea": "Artificial Intelligence",
        "status": "pending",
      },
      {
        "id": "proj_124",
        "title": "Decentralized Logistics App",
        "abstract": "A smart city tracking system for urban parcel delivery.",
        "techStack": ["Flutter", "NestJS", "Supabase"],
        "researchArea": "Web & Mobile",
        "status": "pending",
      },
    ];
  }
}
