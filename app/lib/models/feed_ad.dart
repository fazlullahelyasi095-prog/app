class FeedAd {
  final int id;
  final String title;
  final String description;
  final String? image;
  final String? video;
  final String? destinationUrl;
  final String callToAction;
  final String campaignName;
  final String deliveryToken;

  const FeedAd({
    required this.id,
    required this.title,
    required this.description,
    required this.callToAction,
    required this.campaignName,
    required this.deliveryToken,
    this.image,
    this.video,
    this.destinationUrl,
  });

  factory FeedAd.fromJson(Map<String, dynamic> json) => FeedAd(
    id: int.parse('${json['id']}'),
    title: '${json['title'] ?? ''}',
    description: '${json['description'] ?? ''}',
    image: json['image']?.toString(),
    video: json['video']?.toString(),
    destinationUrl: json['destination_url']?.toString(),
    callToAction: '${json['call_to_action'] ?? 'Learn more'}',
    campaignName: '${json['campaign_name'] ?? ''}',
    deliveryToken: '${json['deliveryToken'] ?? ''}',
  );
}
