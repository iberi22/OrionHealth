// This file is DISABLED — ObjectBox generator not available.
// The app uses InMemoryVectorIndex instead (see memory_module.dart).
// To re-enable: fix build_runner + objectbox_generator, then uncomment.
//
// import 'dart:math' as math;
// import 'dart:typed_data';
// import '../objectbox.g.dart';
// import 'vector_index.dart';
//
// /// ObjectBox entity to store vectors with an HNSW index.
// @Entity()
// class ObxVectorDoc {
//   @Id()
//   int id = 0;
//   @Unique()
//   String docKey;
//   String? content;
//   @HnswIndex(dimensions: 768, distanceType: VectorDistanceType.cosine)
//   @Property(type: PropertyType.floatVector)
//   List<double>? vector;
//   ObxVectorDoc({required this.docKey, this.content, this.vector});
// }
//
// class ObjectBoxVectorIndex implements VectorIndex {
//   ...
// }
