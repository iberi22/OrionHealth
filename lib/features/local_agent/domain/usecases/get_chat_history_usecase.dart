import 'package:injectable/injectable.dart';
import '../chat_message.dart';
import '../services/vector_store_service.dart';

@injectable
class GetChatHistoryUseCase {
  final VectorStoreService storeService;

  GetChatHistoryUseCase(this.storeService);

  Future<List<ChatMessage>> call() async {
    return storeService.getRecentMessages();
  }
}
