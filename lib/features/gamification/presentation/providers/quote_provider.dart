import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/quote_model.dart';

final quoteProvider = Provider<List<QuoteModel>>((ref) {
  return const [
    QuoteModel(
      text: 'Movement is a medicine for creating change in a person.',
      author: 'Carol Welch',
      category: 'Health',
    ),
    QuoteModel(
      text: 'The only bad workout is the one that did not happen.',
      author: 'Unknown',
      category: 'Fitness',
    ),
    QuoteModel(
      text: 'Do something today that your future self will thank you for.',
      author: 'Sean Patrick Flanery',
      category: 'Motivation',
    ),
  ];
});