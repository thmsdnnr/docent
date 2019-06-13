import 'package:flutter/material.dart';
import "./FlashCard.dart";

class FlashCardDisplayer extends StatefulWidget {
  FlashCardDisplayer({Key key, this.flashCard}) : super(key: key);
  final FlashCard flashCard;

  @override
  _FlashCardDisplayerState createState() => _FlashCardDisplayerState();
}

class _FlashCardDisplayerState extends State<FlashCardDisplayer> {
  final FlashCardSide frontSideOfCard = FlashCardSide.front;
  final FlashCardSide backSideOfCard = FlashCardSide.back;

  FlashCardSide sideToDisplay = FlashCardSide.front;
  PageController controller;
  int _cardGrade = -1;

  @override
  initState() {
    super.initState();
  }

  void _flipCard() {
    setState(() {
      if (sideToDisplay == FlashCardSide.front) {
        sideToDisplay = FlashCardSide.back;
      } else {
        sideToDisplay = FlashCardSide.front;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    EdgeInsets contentPadding = EdgeInsets.all(24.0);
    // Pad out the top of the card more if we are displying the rating row at bottom.
    if (sideToDisplay == backSideOfCard) {
      contentPadding = EdgeInsets.fromLTRB(24.0, 48.0, 24.0, 0);
    }
    List<Widget> childList = [
      Expanded(
          flex: 1,
          child: Center(
            child: SingleChildScrollView(
                padding: contentPadding,
                child: Text(
                  sideToDisplay == FlashCardSide.front
                      ? widget.flashCard.front
                      : widget.flashCard.back,
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 32),
                  textAlign: TextAlign.center,
                )),
          ))
    ];
    if (sideToDisplay == backSideOfCard) {
      childList.add(Wrap(
          spacing: 8.0,
          children: List<Widget>.generate(
            6,
            (int index) {
              return ChoiceChip(
                backgroundColor: Colors.cyan.shade100,
                selectedColor: Colors.orange,
                // shape: StadiumBorder(side: BorderSide()),
                selected: index == _cardGrade,
                label: Text("$index",
                    style: TextStyle(fontSize: 20, color: Colors.black)),
                onSelected: (bool selected) {
                  setState(() {
                    _cardGrade = selected ? index : null;
                  });
                },
              );
            },
          ).toList()));
    }
    return GestureDetector(
        child: FractionallySizedBox(
          widthFactor: 0.9,
          heightFactor: 0.9,
          child: Card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: childList,
            ),
          ),
        ),
        onTap: () {
          _flipCard();
        });
  }
}
