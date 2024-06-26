import 'package:demetiapp/core/theme/theme.dart';
import 'package:demetiapp/core/utils/logger/dementiapp_logger.dart';
import 'package:demetiapp/core/utils/utils.dart';
import 'package:demetiapp/features/todo_list/presentation/bloc/todo_list_bloc.dart';
import 'package:flutter/material.dart';
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
                    color: Theme.of(context).cardColor,
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
        backgroundColor:
            Theme.of(context).floatingActionButtonTheme.backgroundColor,
        child: const Icon(
          Icons.add,
          color: AppColors.lightColorWhite,
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
      BuildContext context, double shrinkOffset, bool overlapsContent,) {
    // функция рассчета коэффициента изменения скролла
    double progress = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);

    // рассчет всех требуемых размеров для элементов
    double titleSize = interpolate(45, 30, progress);
    double subtitleSize = interpolate(23, 10, progress);
    double topTitlePadding = interpolate(100, 37, progress);
    double leftTitlePadding = interpolate(40, 20, progress);
    double topPositionSubtitle = interpolate(155, 37, progress);
    double containerHeight = interpolate(maxExtent, minExtent, progress);
    double containerShadowOffset = interpolate(-7, 4, progress);
    double containerBlurRadius = interpolate(0, 17, progress);
    double containerSpreadRadius = interpolate(4, 0, progress);
    double subOpacity = interpolate(1, 0, progress);

    if (subOpacity <= 0) subOpacity = 0;
    final bloc = context.read<ToDoListBloc>();

    // обернул в center, поскольку возникала проблема с тем,
    // что maxExtent 200, но paintExtent - 36.
    // Иными словами, виджеты внутри делегата занимали не все доступное
    // пространство, которое я им выделил. Гуглил долго, не нашел ответов,
    // однако могу предположить, что хедеру мешал BlocBuilder
    // в определении доступных размеров
    return Center(
      child: BlocBuilder<ToDoListBloc, ToDoListState>(
        builder: (context, state) {
          if (state is TodoListSuccessState) {
            return Container(
              height: containerHeight,
              decoration:
                  BoxDecoration(color: AppColors.lightColorWhite, boxShadow: [
                BoxShadow(
                    color: Colors.black45,
                    blurRadius: containerBlurRadius,
                    spreadRadius: containerSpreadRadius,
                    offset: Offset(0, containerShadowOffset),),
              ],),
              child: Center(
                child: SizedBox(
                  height: containerHeight,
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
                                          : TaskFilter.showAll,),);
                                  DementiappLogger.infoLog(
                                      'Added ChangeFilterEvent 1',);
                                },
                                icon: state.filter == TaskFilter.showOnly
                                    ? const Icon(
                                        Icons.visibility,
                                        size: 30,
                                        color: AppColors.lightColorGrayLight,
                                      )
                                    : const Icon(
                                        Icons.visibility_off,
                                        size: 30,
                                        color: AppColors.lightColorRed,
                                      ),),
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
              ),
            );
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
