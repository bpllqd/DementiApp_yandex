import 'package:flutter/material.dart';

class ToDoListWidget extends StatelessWidget {
  const ToDoListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
        SliverPersistentHeader(
          delegate: _SliverAppBarDelegate(),
          pinned: true,
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              return ListTile(
                tileColor: (index%2) == 0 ? const Color.fromARGB(255, 211, 102, 94) : const Color.fromARGB(255, 116, 199, 119),
                title: Text('Item #$index'),
              );
            },
            childCount: 20,
          ),
        ),
      ],
    ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {

  @override
  double get minExtent => 90;

  @override
  double get maxExtent => 200;

  // функция рассчета текущего размера элемента
  // в зависимости от смещениия скролла
  double interpolate(double max, double min, double progress){
    return max-progress*(max-min);
  }

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    // функция рассчета коэффициента изменения скролла
    double progress = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);

    // рассчет всех требуемых размеров для элементов
    double titleSize = interpolate(45, 30, progress);
    double subtitleSize = interpolate(23, 10, progress);
    double topTitlePadding = interpolate(100, 37, progress);
    double leftTitlePadding = interpolate(40, 20, progress);
    double topPositionSubtitle = interpolate(155, 37, progress);
    double subOpacity = interpolate(1, 0, progress);

    if(subOpacity<=0) subOpacity=0;

    return Container(
      color: Colors.white,
      child: Center(
        child:
          Stack(
            children: [
              Positioned(
                top: topPositionSubtitle,
                left: leftTitlePadding,
                right: 20,
                child: Row(
                  children: [
                    Opacity(
                      opacity: subOpacity,
                      child: Text(
                        'Выполнено - 5',
                        style: TextStyle(
                          fontSize: subtitleSize,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: (){},
                      icon: const Icon(Icons.visibility, size: 30,)
                    )
                  ],
                ),
              ),
              Positioned(
                top: topTitlePadding,
                left: leftTitlePadding,
                child: Text(
                  'Мои дела',
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}