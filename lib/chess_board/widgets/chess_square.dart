import 'package:flutter/material.dart';
import '../types.dart';
import 'chess_piece.dart';
import 'square.dart';

class ChessSquare extends StatelessWidget {
  final String name;
  final Color color;
  final double size;
  final Piece piece;
  final void Function(ShortMove move) onDrop;
  final void Function(HalfMove move) onClick;
  final bool highlight;

  ChessSquare({
    this.name,
    @required this.color,
    @required this.size,
    this.highlight = false,
    this.piece,
    this.onDrop,
    this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<HalfMove>(
      onWillAccept: (data) {
        return data.square != name;
      },
      onAccept: (data) {
        if (onDrop != null) {
          onDrop(ShortMove(
            from: data.square,
            to: name,
            promotion: 'q',
          ));
        }
      },
      builder: (context, candidateData, rejectedData) {
        return InkWell(
          onTap: () {
            if (onClick != null) {
              onClick(HalfMove(name, piece));
            }
          },
          child: Square(
            size: size,
            color: color,
            highlight: highlight,
            child: piece != null
                ? ChessPiece(
                    squareName: name,
                    squareColor: color,
                    piece: piece,
                    size: size,
                  )
                : null,
          ),
        );
      },
    );
  }
}
