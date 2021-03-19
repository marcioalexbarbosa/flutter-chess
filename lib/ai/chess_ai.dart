import 'dart:math';

// import 'package:chess/chess.dart';
import '../chess_core/chess.dart';

_board2D(Chess chess) {
  var board = chess.board;

  var output = [], row = [];

  for (var i = 0; i <= 119; i++) {
    row.add(board[i]);
    if ((i + 1) & 0x88 != 0) {
      output.add(row);
      row = [];
      i += 8;
    }
  }

  return output;
}

/// Evaluates current chess board relative to player
/// @param {string} color - Players color, either 'b' or 'w'
/// @return {Number} board value relative to player
_evaluateBoard(Chess chess, Color color) {
  var board2D = _board2D(chess);

  // Sets the value for each piece using standard piece value
  var pieceValue = {
    PieceType.PAWN: 100,
    PieceType.KNIGHT: 350,
    PieceType.BISHOP: 350,
    PieceType.ROOK: 525,
    PieceType.QUEEN: 1000,
    PieceType.KING: 10000
  };

// Loop through all pieces on the board and sum up total
  var value = 0;
  board2D.forEach((row) {
    row.forEach((piece) {
      if (piece != null) {
        // Subtract piece value if it is opponent's piece
        value += pieceValue[piece.type] * (piece.color == color ? 1 : -1);
      }
    });
  });

  return value;

}

/// Calculates the best move using Minimax with Alpha Beta Pruning.
/// @param {Number} depth - How many moves ahead to evaluate
/// @param {Object} game - The game to evaluate
/// @param {string} playerColor - Players color, either 'b' or 'w'
/// @param {Number} alpha
/// @param {Number} beta
/// @param {Boolean} isMaximizingPlayer - If current turn is maximizing or minimizing player
/// @return {Array} The best move value, and the best move
Future<List<dynamic>> calcBestMove(depth, game, playerColor,
    {double alpha = double.negativeInfinity,
    double beta = double.infinity,
    isMaximizingPlayer = true}) async {

  print("calcBestMove...${Random().nextDouble()}");

// Base case: evaluate board
  if (depth == 0) {
    var value = _evaluateBoard(game, playerColor);
    return [value, null];
  }

// Recursive case: search possible moves
  String bestMove; // best move not set yet
  var possibleMoves = game.moves();

// Set random order for possible moves
  possibleMoves.shuffle();

// Set a default best move value
  var bestMoveValue =
      isMaximizingPlayer ? double.negativeInfinity : double.infinity;

// Search through all possible moves
  for (var i = 0; i < possibleMoves.length; i++) {
    var move = possibleMoves[i];
// Make the move, but undo before exiting loop
    game.move(move);
// Recursively get the value from this move
    var list = await calcBestMove(depth - 1, game, playerColor,
        alpha: alpha, beta: beta, isMaximizingPlayer: !isMaximizingPlayer);

    var value = list[0];

    print("list=$list");

    if (isMaximizingPlayer) {
// Look for moves that maximize position
      if (value > bestMoveValue) {
        bestMoveValue = value;
        bestMove = move;
      }
      alpha = max(alpha, value);
    } else {
// Look for moves that minimize position
      if (value < bestMoveValue) {
        bestMoveValue = value;
        bestMove = move;
      }
      beta = min(beta, value);
    }
// Undo previous move
    game.undo();
// Check for alpha beta pruning
    if (beta <= alpha) {
      break;
    }
  }
// Return the best move, or the only move
  var defaultMove = possibleMoves.length > 0 ? possibleMoves[0] : null;
  return [bestMoveValue, bestMove != null && bestMove.isNotEmpty ? bestMove :
  defaultMove];
}
