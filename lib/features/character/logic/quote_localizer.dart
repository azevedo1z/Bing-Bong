import '../../../core/i18n/app_locale.dart';
import '../../../core/i18n/quote_translations.dart';

String localizeQuote(String assetKey, AppLocale locale) {
  if (locale == AppLocale.pt) {
    final translated = kQuotePt[assetKey];
    if (translated != null) return translated;
  }
  return _extractQuote(assetKey);
}

String _extractQuote(String assetKey) {
  var quote = assetKey.split('/').last.replaceAll('.mp3', '');
  if (quote.endsWith('_')) {
    quote = '${quote.substring(0, quote.length - 1)}?';
  }
  return quote.replaceAll('_', "'");
}
