class LifetimeStats {
  int createdCount;
  int checkedCount;

  LifetimeStats({this.createdCount = 0, this.checkedCount = 0});

  Map<String, dynamic> toJson() => {
    'createdCount': createdCount,
    'checkedCount': checkedCount,
  };

  factory LifetimeStats.fromJson(Map<String, dynamic> json) {
    return LifetimeStats(
      createdCount: json['createdCount'] ?? 0,
      checkedCount: json['checkedCount'] ?? 0,
    );
  }
}
