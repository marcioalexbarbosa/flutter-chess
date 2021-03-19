import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'chess_board/flutter_stateless_chessboard.dart';

// import 'package:chess/chess.dart' as ch;
import 'chess_core/chess.dart' as ch;

import 'ai/chess_ai.dart';
import 'utils.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _fen = ch.Chess.DEFAULT_POSITION;
  String _statusText = "sua vez...";
  String _historyText = "";
  int _themeValue = 0;
  Color _darkSquareColor = Color.fromARGB(250, 100, 18, 161);
  Color _lightSquareColor = Color.fromARGB(250, 154, 77, 210);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size; //Size.fromWidth(400.0);
    double width = size.width > 400.0 ? 400.0 : size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text("Flutter Chess"),
      ),
      body: Container(
        margin: EdgeInsets.all(5.0),
          child: Column(
        children: <Widget>[
          _chessboard(width),
          _status(),
          _history(),
          _newGame(),
          _theme(),
          // _sentence()
        ],
      )),
    );
  }

  _status() {
    return Text(_statusText,
        style: TextStyle(color: Color.fromARGB(250, 128, 41, 1), fontSize: 30));
  }

  _history() {
    return Text(_historyText,
        style: TextStyle(color: Color.fromARGB(250, 29, 28, 28), fontSize: 15));
  }

  _newGame() {
    return TextButton(
        child: Text('Novo jogo'),
        style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(Colors.amberAccent),
            backgroundColor: MaterialStateProperty.all(Colors.deepPurpleAccent),
            padding: MaterialStateProperty.all(
                EdgeInsets.symmetric(vertical: 5, horizontal: 50))),
        onPressed: () {
          setState(() {
            _fen = ch.Chess.DEFAULT_POSITION;
            _historyText = '';
          });
        });
  }

  void _themeValueChange(int value) {
    setState(() {
      _themeValue = value;
      switch (_themeValue) {
        case 0:
          _darkSquareColor = Color.fromARGB(250, 100, 18, 161);
          _lightSquareColor = Color.fromARGB(250, 154, 77, 210);
          break;
        case 1:
          _darkSquareColor = Color.fromARGB(250, 1, 128, 96);
          _lightSquareColor = Color.fromARGB(250, 197, 212, 64);
          break;
        case 2:
          _darkSquareColor = Color.fromARGB(250, 29, 52, 184);
          _lightSquareColor = Color.fromARGB(250, 80, 104, 173);
          break;
      }
    });
  }

  _theme() {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        new Radio(
            value: 0, groupValue: _themeValue, onChanged: _themeValueChange),
        new Text(
          'Purple',
          style: new TextStyle(fontSize: 16.0),
        ),
        new Radio(
            value: 1, groupValue: _themeValue, onChanged: _themeValueChange),
        new Text(
          'Green',
          style: new TextStyle(fontSize: 16.0),
        ),
        new Radio(
            value: 2, groupValue: _themeValue, onChanged: _themeValueChange),
        new Text(
          'Blue',
          style: new TextStyle(fontSize: 16.0),
        ),
      ],
    );
  }

  _chessboard(double width) {
    return Chessboard(
      darkSquareColor: _darkSquareColor,
      lightSquareColor: _lightSquareColor,
      fen: _fen,
      size: width,
      onMove: (move) {
        ch.Chess game = _loadGame(_fen);

        var from = game.get(move.from).type.name;

        from = from == 'p' ? '' : from.toUpperCase();

        var moveResult = makeMove(_fen, {
          'from': move.from,
          'to': move.to,
          'promotion': 'q',
        });

        var status = moveResult['status'];
        if (status.isNotEmpty) {
          _statusText = status;
          return;
        }
        var nextFen = moveResult['fen'];
        var capture = moveResult['capture'];

        var moveAlg = '$from${capture ? 'x' : ''}${move.to}';

        if (moveAlg == 'Kg1') {
          moveAlg = 'O-O';
        } else if (moveAlg == 'Kc1') {
          moveAlg = 'O-O-O';
        }

        if (nextFen != null) {
          setState(() {
            _fen = nextFen;
            game = _loadGame(_fen);
            _statusText = "pensando...${game.in_check ? ' (CHECK!)' : ''}";
            _historyText = '$_historyText $moveAlg';
          });

          Future.delayed(Duration(milliseconds: 400)).then((_) {
            game = _loadGame(_fen);
            var depths = [2, 2, 2, 2, 2, 3, 3];
            depths.shuffle();

            Future<List<dynamic>> future =
                calcBestMove(
                    depths.first,
                    game,
                    game.turn
            );

            future.then((List<dynamic> value) {
              final nextMove = value[1];

              if (nextMove != null && nextMove.indexOf('#') == -1) {
                setState(() {
                  moveResult = makeMove(_fen, nextMove);
                  var status = moveResult['status'];
                  if (status.isNotEmpty) {
                    _statusText = status;
                    return;
                  }
                  _fen = moveResult['fen'];
                  capture = moveResult['capture'];
                  game = _loadGame(_fen);
                  _statusText = "sua vez...${game.in_check ? ' (CHECK!)' : ''}";
                  _historyText = '$_historyText $nextMove';
                });
              } else {
                setState(() {
                  _statusText = 'fim de jogo!';
                  if (nextMove != null) {
                    moveResult = makeMove(_fen, nextMove);
                    _fen = moveResult['fen'];
                  }
                  game = _loadGame(_fen);
                  if (game.in_checkmate) {
                    _statusText = '$_statusText CHECKMATE!';
                  }
                });
                return;
              }
            });
          });
        }
      },
    );
  }

  ch.Chess _loadGame(String fen) {
    return ch.Chess.fromFEN(fen);
  }
}
