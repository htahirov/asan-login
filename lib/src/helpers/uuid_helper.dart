import 'dart:math';

class UuidHelper {
  static String generateUuid() {
    final random = Random();

    String formatSection(int length) =>
        List.generate(length, (index) => random.nextInt(16).toRadixString(16))
            .join();

    return '${formatSection(8)}-${formatSection(4)}-${formatSection(4)}-${formatSection(4)}-${formatSection(12)}';
  }
}
