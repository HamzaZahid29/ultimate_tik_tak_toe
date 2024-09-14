import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(GetMaterialApp(home: Home()));
}

class GameManager extends GetxController {
  RxInt _currentPlayer = 0.obs;
  RxInt numberOfRows = 3.obs;

  void changePlayer() {
    if (_currentPlayer.value == 0) {
      _currentPlayer.value = 1;
    } else {
      _currentPlayer.value = 0;
    }
  }

  List<int> defList = [-1, -1];
  RxList<List<int>> p1data = [
    [-1, -1]
  ].obs;
  RxList<List<int>> p2data = [
    [-1, -1]
  ].obs;

  void resetGame() {
    p1data.value = [
      [-1, -1]
    ];
    p2data.value = [
      [-1, -1]
    ];
  }

  void addP1Data(int a, int b) {
    ListEquality listEquality = ListEquality();
    print(p1data.value);
    if (p1data.any((element) => listEquality.equals(element, [a, b])) ||
        p2data.any((element) => listEquality.equals(element, [a, b]))) {
      print('Contains');
    } else {
      var newData = [a, b];
      if (_currentPlayer.value == 0) {
        p1data.add(newData);
        gameOverCheck();
      } else {
        p2data.add(newData);
        gameOverCheck();
      }
    }
  }

  void gameOverCheck() {
    if (isGameOver(p1data, p2data)) {
      Get.dialog(Container(
        height: 100,
        decoration: BoxDecoration(color: Colors.white),
        child: Text('player $_currentPlayer won'),
      ));
      resetGame();
    } else {
      changePlayer();
    }
  }

  bool isGameOver(List<List<int>> _p1data, List<List<int>> _p2data) {
    print('game over checked');
    List<List<int>> diagonalList = [];
    List<List<int>> diagonalListAlt = [];

    diagonalList.add(defList);
    diagonalListAlt.add(defList);

    for (int i = 0; i < numberOfRows.value; i++) {
      diagonalList.add([i, i]);
      diagonalListAlt.add([i, numberOfRows.value - i - 1]);
    }

    return (checkSubset(diagonalList, _p1data) ||
        checkSubset(diagonalList, _p2data) ||
        checkSubset(diagonalListAlt, _p1data) ||
        checkSubset(diagonalListAlt, _p2data) ||
        checkForRow(_p1data) ||
        checkForRow(_p2data)||checkForCol(_p1data) ||
        checkForCol(_p2data));
  }

  bool checkForRow(List<List<int>> pData) {
    for (int j = 0; j < numberOfRows.value; j++) {
      List<List<int>> diagonalList = [];
      diagonalList.add(defList);

      for (int i = 0; i < numberOfRows.value; i++) {
        diagonalList.add([j, i]);
      }
      if (checkSubset(pData, diagonalList)) {
        return true;
      }
    }
    return false;
  }
  bool checkForCol(List<List<int>> pData) {
    for (int j = 0; j < numberOfRows.value; j++) {
      List<List<int>> diagonalList = [];
      diagonalList.add(defList);

      for (int i = 0; i < numberOfRows.value; i++) {
        diagonalList.add([i, j]);
      }
      if (checkSubset(pData, diagonalList)) {
        return true;
      }
    }
    return false;
  }

  bool checkSubset(List<List<int>> playerList, List<List<int>> possibleList) {
    DeepCollectionEquality equality = DeepCollectionEquality();
    List<List<int>> sortedPlayerList = List.from(playerList)
      ..sort((a, b) => compareLists(a, b));
    List<List<int>> sortedPossibleList = List.from(possibleList)
      ..sort((a, b) => compareLists(a, b));
    return equality.equals(sortedPlayerList, sortedPossibleList);
  }

  int compareLists(List<int> a, List<int> b) {
    for (int i = 0; i < a.length && i < b.length; i++) {
      if (a[i] != b[i]) {
        return a[i].compareTo(b[i]);
      }
    }
    return a.length.compareTo(b.length);
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    ListEquality listEquality = ListEquality();

    final gameManager = Get.put(GameManager());
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                gameManager.numberOfRows.value += 1;
              },
              icon: Icon(Icons.add)),
          IconButton(
              onPressed: () {
                gameManager.numberOfRows.value -= 1;
              },
              icon: Icon(Icons.remove)),
        ],
        title: Text('TickTacToe'),
      ),
      body: Obx(() => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List.generate(
                  gameManager.numberOfRows.value,
                  (a) => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                            gameManager.numberOfRows.value,
                            (b) => GameWidget(GestureDetector(
                                  onTap: () {
                                    List<int> temp = [a, b];
                                    if (gameManager.p1data.value
                                        .contains(temp)) {
                                      print('Contains');
                                    } else {
                                      print(temp);
                                      gameManager.addP1Data(a, b);
                                      print(gameManager.p1data.value);
                                    }
                                  },
                                  child: Icon(
                                    gameManager.p1data.any((element) =>
                                            listEquality
                                                .equals(element, [a, b]))
                                        ? Icons.close
                                        : gameManager.p2data.any((element) =>
                                                listEquality
                                                    .equals(element, [a, b]))
                                            ? Icons.circle_outlined
                                            : Icons.filter_none,
                                    size: 50,
                                    color: gameManager.p1data.any((element) =>
                                            listEquality
                                                .equals(element, [a, b]))
                                        ? Colors.red
                                        : gameManager.p2data.any((element) =>
                                                listEquality
                                                    .equals(element, [a, b]))
                                            ? Colors.black
                                            : Colors.transparent,
                                  ),
                                ))),
                      )),
            ),
          )),
    );
  }
}

class GameWidget extends StatelessWidget {
  Widget? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.black)),
        child: icon != null
            ? icon
            : SizedBox(
                height: 50,
                width: 50,
              ));
  }

  GameWidget(this.icon);
}
