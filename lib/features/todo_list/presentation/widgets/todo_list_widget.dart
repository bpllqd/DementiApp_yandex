import 'package:demetiapp/core/utils/logger/dementiapp_logger.dart';
import 'package:demetiapp/core/utils/utils.dart';
import 'package:demetiapp/features/todo_list/presentation/bloc/todo_list_bloc.dart';
import 'package:flutter/material.dart';
import 'package:demetiapp/core/constants/constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'add_new_button_widget.dart';
import 'tasks_list_widget.dart';

class ToDoListWidget extends StatelessWidget {
  const ToDoListWidget({super.key});

  void _addNewTask(
    ScrollController scrollController,
    BuildContext context,
  ) async {
    await context.push('/add_new');
    DementiappLogger.infoLog('Navigating to add_new');
    scrollController.animateTo(
      0,
      duration: const Duration(
        milliseconds: 500,
      ),
      curve: Curves.linear,
    );
  }

  @override
  Widget build(BuildContext context) {
    ScrollController scrollController = ScrollController();
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        controller: scrollController,
        slivers: <Widget>[
          SliverPersistentHeader(
            delegate: _SliverAppBarDelegate(),
            pinned: true,
          ),
          SliverPadding(
            padding: const EdgeInsets.only(
              left: 4.0,
              right: 4.0,
              bottom: 3.0,
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return Card(
                    color: const Color(lightBackSecondary),
                    semanticContainer: false,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                    elevation: 4.0,
                    child: Column(
                      children: [
                        const TasksList(),
                        AddNewButton(
                          onTap: () {
                            _addNewTask(scrollController, context);
                          },
                        ),
                      ],
                    ),
                  );
                },
                childCount: 1,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addNewTask(scrollController, context);
        },
        elevation: 4,
        backgroundColor: const Color(lightColorRed),
        child: const Icon(
          Icons.add,
          color: Color(lightColorWhite),
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
  double interpolate(double max, double min, double progress) {
    return max - progress * (max - min);
  }

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    // функция рассчета коэффициента изменения скролла
    double progress = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);

    // рассчет всех требуемых размеров для элементов
    double titleSize = interpolate(45, 30, progress);
    double subtitleSize = interpolate(23, 10, progress);
    double topTitlePadding = interpolate(100, 37, progress);
    double leftTitlePadding = interpolate(40, 20, progress);
    double topPositionSubtitle = interpolate(155, 37, progress);
    double subOpacity = interpolate(1, 0, progress);

    if (subOpacity <= 0) subOpacity = 0;
    final bloc = context.read<ToDoListBloc>();

    return BlocBuilder<ToDoListBloc, ToDoListState>(
      builder: (context, state) {
        if (state is TodoListSuccessState) {
          return Container(
            color: Colors.white,
            child: Center(
              child: Stack(
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
                            'Выполнено - ${state.completedTasks}',
                            style: TextStyle(
                              fontSize: subtitleSize,
                            ),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                            onPressed: () {
                              bloc.add(ChangeFilterEvent(
                                  state.filter == TaskFilter.showAll
                                      ? TaskFilter.showOnly
                                      : TaskFilter.showAll));
                              DementiappLogger.infoLog(
                                  'Added ChangeFilterEvent 1');
                            },
                            icon: state.filter == TaskFilter.showOnly
                                ? const Icon(
                                    Icons.visibility,
                                    size: 30,
                                    color: Color(lightColorGrayLight),
                                  )
                                : const Icon(
                                    Icons.visibility_off,
                                    size: 30,
                                    color: Color(lightColorRed),
                                  ))
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
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
