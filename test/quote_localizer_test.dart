import 'package:flutter_test/flutter_test.dart';
import 'package:bingbong/core/i18n/app_locale.dart';
import 'package:bingbong/features/character/logic/quote_localizer.dart';

void main() {
  group('localizeQuote', () {
    test('English derives the quote from the filename', () {
      expect(localizeQuote('audio/maybe.mp3', AppLocale.en), 'maybe');
    });

    test('English replaces underscores with apostrophes', () {
      expect(
        localizeQuote('audio/please don_t.mp3', AppLocale.en),
        "please don't",
      );
    });

    test('English turns a trailing underscore into a question mark', () {
      expect(
        localizeQuote(
          'audio/if i say yes will you take me with you_.mp3',
          AppLocale.en,
        ),
        'if i say yes will you take me with you?',
      );
    });

    test('Portuguese uses the override when present', () {
      expect(localizeQuote('audio/yes.mp3', AppLocale.pt), 'sim');
      expect(
        localizeQuote('audio/im bing bong.mp3', AppLocale.pt),
        'eu sou o bing bong',
      );
    });

    test('Portuguese falls back to the base text for untranslated lines', () {
      expect(localizeQuote('audio/nahhh.mp3', AppLocale.pt), 'nahhh');
      expect(localizeQuote('audio/uhhhhhh.mp3', AppLocale.pt), 'uhhhhhh');
    });
  });
}
