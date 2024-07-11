import 'package:demetiapp/core/presentation/bloc/todo_list_bloc.dart';
import 'package:demetiapp/core/theme/theme.dart';
import 'package:demetiapp/core/utils/logger/dementiapp_logger.dart';
import 'package:demetiapp/core/utils/network_status.dart';
import 'package:demetiapp/core/utils/utils.dart';
import 'package:demetiapp/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'add_new_button_widget.dart';
import 'tasks_list_widget.dart';

class ToDoListWidget extends StatefulWidget {
  const ToDoListWidget({super.key});

  @override
  State<ToDoListWidget> createState() => _ToDoListWidgetState();
}

class _ToDoListWidgetState extends State<ToDoListWidget> {
  ScrollController scrollController = ScrollController();
  final GlobalKey<RefreshIndicatorState> refreshKey = GlobalKey();
  late NetworkStatus networkStatus;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    networkStatus = context.read<NetworkStatus>();
    networkStatus.addListener(_handleNetworkNotifications);
  }

  void _handleNetworkNotifications() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: networkStatus.isOnline
            ? AppColors.lightColorGreen
            : AppColors.lightColorRed,
        content: Row(
          children: [
            networkStatus.isOnline
              ? const Icon(Icons.check, color: AppColors.lightColorWhite,)
              : const Icon(Icons.signal_wifi_connected_no_internet_4_outlined, color: AppColors.lightColorWhite,),
            const SizedBox(width: 15,),
            Text(
              networkStatus.isOnline
                ? S.of(context).listScreenListWidgetOnline
                : S.of(context).listScreenListWidgetOfline,
            ),
          ],
          // leading: networkStatus.isOnline
          // ? const Icon(Icons.fmd_good, color: AppColors.lightColorWhite,)
          // : const Icon(Icons.offline_bolt_outlined, color: AppColors.lightColorWhite,),
          // title: Text(
          //   networkStatus.isOnline
          //       ? S.of(context).listScreenListWidgetOnline
          //       : S.of(context).listScreenListWidgetOfline,
          // ),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void _addNewTask(
    ScrollController scrollController,
    BuildContext context,
  ) async {
    BlocProvider.of<ToDoListBloc>(context).add(TaskCreateEvent());
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
    return BlocListener<ToDoListBloc, ToDoListState>(
      listener: (context, state) {
        DementiappLogger.infoLog(
          'ToDoList widget: Current state: ${state.toString()}',
        );
        switch (state) {
          case CreateInProgressState():
            context.push('/add_new');
          case EditInProgressState():
            context.push('/add_new', extra: state.task);
          case CreatingSuccessState() || EditingSuccessState():
            BlocProvider.of<ToDoListBloc>(context).add(GetTasksEvent());
          case ErrorState():
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: const Color.fromARGB(255, 186, 45, 45),
                content: Text(state.errorDescription),
                duration: const Duration(seconds: 4),
              ),
            );
        }
      },
      child: BlocBuilder<ToDoListBloc, ToDoListState>(
        builder: (context, state) {
          if (state is SuccessState) {
            return Scaffold(
              backgroundColor: AppColors.lightBackPrimary,
              body: NestedScrollView(
                controller: scrollController,
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    SliverPersistentHeader(
                      delegate: _SliverAppBarDelegate(),
                      pinned: true,
                    ),
                  ];
                },
                body: RefreshIndicator(
                  color: AppColors.lightColorRed,
                  backgroundColor: AppColors.lightColorWhite,
                  key: refreshKey,
                  onRefresh: () async {
                    BlocProvider.of<ToDoListBloc>(context).add(GetTasksEvent());
                  },
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
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
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8.0)),
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
                ),
              ),
              floatingActionButton: FloatingActionButton(
                key: const ValueKey('FloatingAddNewButton'),
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
          } else {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  color: Colors.red,
                ),
              ),
            );
          }
        },
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
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
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
          if (state is SuccessState) {
            return Container(
              height: containerHeight,
              decoration: BoxDecoration(
                color: AppColors.lightBackPrimary,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black45,
                    blurRadius: containerBlurRadius,
                    spreadRadius: containerSpreadRadius,
                    offset: Offset(0, containerShadowOffset),
                  ),
                ],
              ),
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
                                S.of(context).listScreenAppBarCompletedN(
                                      state.completedTasks,
                                    ),
                                style: TextStyle(
                                  fontSize: subtitleSize,
                                  color: AppColors.lightColorGray,
                                ),
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () {
                                bloc.add(
                                  ChangeFilterEvent(
                                    tasks: state.tasks,
                                    completedTasks: state.completedTasks,
                                    filter: state.filter == TasksFilter.showAll
                                        ? true
                                        : false,
                                  ),
                                );
                              },
                              icon: state.filter == TasksFilter.showOnly
                                  ? const Icon(
                                      Icons.visibility,
                                      size: 30,
                                      color: AppColors.lightColorGrayLight,
                                    )
                                  : const Icon(
                                      Icons.visibility_off,
                                      size: 30,
                                      color: AppColors.lightColorRed,
                                    ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: topTitlePadding,
                        left: leftTitlePadding,
                        child: Text(
                          S.of(context).listScreenAppBarTitle,
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
            return Center(
              child: Text(S.of(context).listScreenAppBarError),
            );
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
