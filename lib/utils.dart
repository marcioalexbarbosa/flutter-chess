//import 'package:chess/chess.dart' as ch;
import 'chess_core/chess.dart' as ch;

makeMove(String fen, dynamic move) {
  final chess = ch.Chess.fromFEN(fen);

  if (chess.move(move) != null) {
    return {
      'status': '',
      'fen': chess.fen,
      'capture': chess.in_capture,
    };
  } else {
    var status = '';
    if (chess.in_checkmate) {
      status = 'checkmate';
    } else if (chess.in_stalemate) {
      status = 'stalemate';
    }
    return {'status': status};
  }
}
