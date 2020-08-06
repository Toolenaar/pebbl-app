import 'package:flutter/material.dart';
import 'package:pebbl/logic/colors.dart';
import 'package:pebbl/logic/texts.dart';
import 'package:pebbl/model/audio_set.dart';
import 'package:pebbl/presenter/sets_presenter.dart';

import 'package:provider/provider.dart';

class SetsList extends StatefulWidget {
  final Function(GroupedByCategory) onCategorySelected;
  final Function close;
  const SetsList({Key key, @required this.onCategorySelected, @required this.close}) : super(key: key);

  @override
  _SetsListState createState() => _SetsListState();
}

class _SetsListState extends State<SetsList> {
  GroupedByCategory _selectedCategory;

  Widget _buildSetsList() {
    var items = context.select<SetsPresenter, List<GroupedByCategory>>((value) => value.setCategories);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        child: ListView.separated(
            separatorBuilder: (context, index) {
              return const SizedBox(
                height: 16,
              );
            },
            itemBuilder: (context, index) {
              return SetsListCategoryListItem(
                onSetSelected: (categoryGroup) {
                  _selectedCategory = categoryGroup;
                  widget.onCategorySelected(categoryGroup);
                  setState(() {});
                },
                category: items[index],
              );
            },
            itemCount: items.length),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildSetsList();
    // return TracksList(
    //   close: widget.close,
    //   categoryGroup: _selectedCategory,
    //   onBackPressed: () {
    //     setState(() {
    //       _selectedCategory = null;
    //     });
    //   },
    // );
  }
}

class SetsListCategoryListItem extends StatelessWidget {
  final GroupedByCategory category;
  final Function(GroupedByCategory) onSetSelected;
  const SetsListCategoryListItem({Key key, this.category, @required this.onSetSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorTheme = category.category.colorTheme;
    return GestureDetector(
      onTap: () {
        onSetSelected(category);
      },
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: colorTheme.backgroundColor,
          border: Border.all(
            color: colorTheme.accentColor,
          ),
        ),
        child: H1Text(
          category.category.name,
          color: colorTheme.accentColor,
          fontSize: 28,
        ),
      ),
    );
  }
}

class DownloadProgress extends StatelessWidget {
  final double progress;

  const DownloadProgress({Key key, this.progress = 1}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorTheme = AppColors.getActiveColorTheme(context);

    return Stack(
      children: <Widget>[
        Container(
          height: 16,
          width: 16,
          decoration: BoxDecoration(
            color: colorTheme.accentColor40,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: 16,
                height: 16 * progress,
                color: colorTheme.accentColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
