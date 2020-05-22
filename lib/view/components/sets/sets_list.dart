import 'package:flutter/material.dart';
import 'package:pebbl/logic/texts.dart';
import 'package:pebbl/model/audio_set.dart';
import 'package:pebbl/presenter/sets_presenter.dart';
import 'package:provider/provider.dart';

class SetsList extends StatelessWidget {
  const SetsList({Key key}) : super(key: key);

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
              category: items[index],
            );
          },
          itemCount: items.length),
    );
  }
}

class SetsListCategoryListItem extends StatelessWidget {
  final SetCategory category;
  const SetsListCategoryListItem({Key key, this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final sets =
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: H1Text(category.name,fontSize: 28,),
          ),
          ...category.sets.map(
            (audioSet) => SetsListSetItem(
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
  const SetsListSetItem({Key key, @required this.audioSet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24,0,24,24),
      child: BodyText2(audioSet.name,fontSize: 14,),
    );
  }
}
