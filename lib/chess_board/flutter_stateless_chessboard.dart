import 'package:flutter/material.dart';
import 'types.dart';
import 'utils.dart';
import 'widgets/chess_square.dart';

final zeroToSeven = List.generate(8, (index) => index);

class Chessboard extends StatefulWidget {
  final String fen;
  final double size;
  final String orientation; // 'w' | 'b'
  final void Function(ShortMove move) onMove;
  final Color lightSquareColor;
  final Color darkSquareColor;

  Chessboard({
    @required this.fen,
    @required this.size,
    this.orientation = 'w',
    this.onMove,
    this.lightSquareColor = const Color.fromRGBO(240, 217, 181, 1),
    this.darkSquareColor = const Color.fromRGBO(181, 136, 99, 1),
  });

  @override
  State<StatefulWidget> createState() {
    return _ChessboardState();
  }
}

class _ChessboardState extends State<Chessboard> {
  HalfMove _clickMove;

  @override
  Widget build(BuildContext context) {
    final squareSize = widget.size / 8;
    final pieceMap = getPieceMap(widget.fen);

    return Container(
      width: widget.size,
      height: widget.size,
      child: Row(
        children: zeroToSeven.map((fileIndex) {
          return Column(
            children: zeroToSeven.map((rankIndex) {
              final square =
                  getSquare(rankIndex, fileIndex, widget.orientation);
              final color = (rankIndex + fileIndex) % 2 == 0
                  ? widget.lightSquareColor
                  : widget.darkSquareColor;
              return ChessSquare(
                name: square,
                color: color,
                size: squareSize,
                highlight: _clickMove?.square == square,
                piece: pieceMap[square],
                onDrop: (move) {
                  if (widget.onMove != null) {
                    widget.onMove(move);
                    setClickMove(null);
                  }
                },
                onClick: (halfMove) {
                  if (_clickMove != null) {
                    if (_clickMove.square == halfMove.square) {
                      setClickMove(null);
                    } else if (_clickMove.piece.color ==
                        halfMove.piece?.color) {
                      setClickMove(halfMove);
                    } else {
                      widget.onMove(ShortMove(
                        from: _clickMove.square,
                        to: halfMove.square,
                        promotion: 'q',
                      ));
                    }
                    setClickMove(null);
                  } else if (halfMove.piece != null) {
                    setClickMove(halfMove);
                  }
                },
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }

  void setClickMove(HalfMove move) {
    setState(() {
      _clickMove = move;
    });
  }
}
