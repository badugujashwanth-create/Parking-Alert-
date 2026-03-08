class ScanPreview {
  const ScanPreview({
    required this.qrId,
    required this.ownerUid,
    required this.vehicleId,
    required this.vehicleNumber,
    required this.city,
    required this.qrActive,
  });

  final String qrId;
  final String ownerUid;
  final String vehicleId;
  final String vehicleNumber;
  final String city;
  final bool qrActive;
}
