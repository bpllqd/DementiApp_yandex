import 'package:flutter/material.dart';

class ToDoListWidget extends StatelessWidget {
  const ToDoListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: <Widget>[
        SliverPersistentHeader(
          delegate: _SliverAppBarDelegate(),
          pinned: true,
        ),
        const TasksListWidget(),
      ],
    ),
    );
  }
}

class TasksListWidget extends StatefulWidget {
  const TasksListWidget({
    super.key,
  });

  @override
  State<TasksListWidget> createState() => _TasksListWidgetState();
}

class _TasksListWidgetState extends State<TasksListWidget> {
  List<String> items = List.generate(6, (index) => 'DEMENTIAPP $index');
  bool isChecked = false;

   @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                offset: items.isNotEmpty ? const Offset(0, 2) : const Offset(0, 0),
                color: Colors.black12,
                blurRadius: 3,
                spreadRadius: 1
              )
          ]
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            children:[ 
              if(items.isNotEmpty)
              ...List.generate(items.length, (index){
                return Dismissible(
                  movementDuration: const Duration(milliseconds: 500),
                  key: UniqueKey(),
                  background: const ColoredBox(color: Colors.red),
                  secondaryBackground: const ColoredBox(color: Colors.green),
                  child: ListTile(
                    leading: const Icon(Icons.add_box_outlined),
                    trailing: const Icon(Icons.info_outline),
                    title: Text(items[index]),
                  ),
                );
              }),
              
              InkWell(
                onTap: (){},
                child: const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text('Добавить'),
                ),
              ),
            ]
          ),
        ),
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