import '../models/models.dart';
import 'sequence_detector.dart';

class ScoreCalculator {
  static int calculateNewPoints(Board before, Board after) {
    final beforeSequences = SequenceDetector.detectSequences(before);
    final afterSequences = SequenceDetector.detectSequences(after);
    
    int newPoints = 0;
    for (final seq in afterSequences) {
      if (!beforeSequences.contains(seq)) {
        newPoints++;
      }
    }
    return newPoints;
  }
}
