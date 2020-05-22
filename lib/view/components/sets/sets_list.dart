import 'package:flutter/material.dart';
import 'package:pebbl/logic/texts.dart';
import 'package:pebbl/model/audio_set.dart';
import 'package:pebbl/presenter/sets_presenter.dart';
import 'package:provider/provider.dart';

class SetsList extends StatelessWidget {
  final Function(AudioSet) onSetSelected;
  const SetsList({Key key, @required this.onSetSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //todo stream from firebase
    var items = context.select<SetsPresenter, List<SetCategory>>((value) => value.setCategories);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white,
        ),
      ),
      child: ListView.builder(
          itemBuilder: (context, index) {
            return SetsListCategoryListItem(
              onSetSelected: onSetSelected,
              category: items[index],
            );
          },
          itemCount: items.length),
    );
  }
}

class SetsListCategoryListItem extends StatelessWidget {
  final SetCategory category;
  final Function(AudioSet) onSetSelected;
  const SetsListCategoryListItem({Key key, this.category, @required this.onSetSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final sets =
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: H1Text(
              category.name,
              fontSize: 28,
            ),
          ),
          ...category.sets.map(
            (audioSet) => SetsListSetItem(
              onTap: () => onSetSelected(audioSet),
              audioSet: audioSet,
            ),
          ),
          const SizedBox(height: 48)
        ],
      ),
    );
  }
}

class SetsListSetItem extends StatelessWidget {
  final AudioSet audioSet;
  final Function onTap;
  const SetsListSetItem({Key key, @required this.audioSet, @required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final activeSet = context.select<SetsPresenter, AudioSet>((value) => value.activeSet);
    final isActive = activeSet == audioSet;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.fromLTRB(16, 0, 24, 24),
        child: Row(
          children: <Widget>[
            SizedBox(
              height: 16,
              width: 16,
              child: isActive ? Image.asset('assets/img/ic_active_indicator.png') : SizedBox(),
            ),
            const SizedBox(width: 8),
            BodyText2(
              audioSet.name,
              fontSize: 14,
            ),
          ],
        ),
      ),
    );
  }
}
