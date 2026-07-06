import 'package:isar/isar.dart';

part 'network_peer.g.dart';

enum PeerStatus {
  online,
  offline,
  blocked,
}

@collection
class NetworkPeer {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String peerId;

  late String name;

  late String address;

  late int port;

  @Enumerated(EnumType.name)
  late PeerStatus status;

  late DateTime lastSeen;

  String? publicKey;

  NetworkPeer({
    this.id = Isar.autoIncrement,
    required this.peerId,
    required this.name,
    required this.address,
    required this.port,
    required this.status,
    required this.lastSeen,
    this.publicKey,
  });
}
