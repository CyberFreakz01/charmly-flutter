import 'package:charmly_flutter/app/charmly_theme.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Charmly theme tokens match source palette', () {
    expect(CharmlyTokens.background.value, 0xFF1B1324);
    expect(CharmlyTokens.foreground.value, 0xFFFFF7F1);
    expect(CharmlyTokens.card.value, 0xFF281B34);
    expect(CharmlyTokens.primary.value, 0xFFFF8A75);
    expect(CharmlyTokens.secondary.value, 0xFF382744);
    expect(CharmlyTokens.muted.value, 0xFF30203D);
    expect(CharmlyTokens.mutedForeground.value, 0xFFBBAABD);
    expect(CharmlyTokens.accent.value, 0xFFBBA1FF);
    expect(CharmlyTokens.border.value, 0xFF453453);
    expect(CharmlyTokens.input.value, 0xFF594366);
    expect(CharmlyTokens.radius, 18);
  });
}
