import 'package:demetiapp/core/extensions/context_extensions.dart';
import 'package:demetiapp/core/presentation/bloc/todo_list_bloc.dart';
import 'package:demetiapp/core/utils/logger/dementiapp_logger.dart';
import 'package:demetiapp/core/utils/network_status.dart';
import 'package:demetiapp/core/utils/utils.dart';
import 'package:demetiapp/generated/l10n.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
            ? context.colors.colorGreen
            : context.colors.colorRed,
        content: Row(
          children: [
            networkStatus.isOnline
                ? Icon(
                    Icons.wifi,
                    color: context.colors.colorWhite,
                  )
                : Icon(
                    Icons.wifi_off,
                    color: context.colors.colorWhite,
                  ),
            const SizedBox(
              width: 15,
            ),
            Text(
              networkStatus.isOnline
                  ? S.of(context).listScreenListWidgetOnline
                  : S.of(context).listScreenListWidgetOfline,
              style: context.textStyles.subhead
                  .copyWith(color: context.colors.colorWhite),
            ),
          ],
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
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
    FirebaseAnalytics.instance.logEvent(
      name: 'pressed_floating_action_button',
      parameters: <String, Object>{
        'key': widget,
      },
    );
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
                backgroundColor: context.colors.colorRed,
                content: Row(
                  children: [
                    Icon(
                      Icons.warning,
                      color: context.colors.colorWhite,
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    Text(
                      state.errorDescription,
                      style: context.textStyles.subhead
                          .copyWith(color: context.colors.colorWhite),
                    ),
                  ],
                ),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                margin: const EdgeInsets.all(10.0),
                duration: const Duration(seconds: 2),
              ),
            );
        }
      },
      child: BlocBuilder<ToDoListBloc, ToDoListState>(
        builder: (context, state) {
          if (state is SuccessState) {
            return Scaffold(
              backgroundColor: context.colors.backPrimary,
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
                  color: context.colors.colorRed,
                  backgroundColor: context.colors.colorWhite,
                  key: refreshKey,
                  onRefresh: () async {
                    BlocProvider.of<ToDoListBloc>(context).add(GetTasksEvent());
                  },
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.only(
                          left: 10.0,
                          right: 10.0,
                          bottom: 3.0,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                              final tasksNotEmpty =
                                  state.filteredTasks.isNotEmpty;
                              return Card(
                                color: context.colors.backSecondary,
                                semanticContainer: false,
                                shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8.0)),
                                ),
                                elevation: 4.0,
                                child: Column(
                                  children: [
                                    tasksNotEmpty
                                        ? const TasksList()
                                        : Container(
                                            height: 0,
                                          ),
                                    AddNewButton(
                                      onTap: () {
                                        _addNewTask(scrollController, context);
                                      },
                                    ),
                                    ElevatedButton(
                                      child: const Text('generate exception'),
                                      onPressed: () {
                                        DementiappLogger.errorLog(
                                          'Thrown test exception!',
                                        );
                                        throw Exception('Thrown Exception');
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
              floatingActionButton: AnimatedFAB(
                key: const ValueKey('FloatingAddNewButton'),
                onPressed: () {
                  _addNewTask(scrollController, context);
                },
                backgroundColor: context.colors.colorRed,
                iconColor: context.colors.colorWhite,
              ),
            );
          } else {
            return Scaffold(
              backgroundColor: context.colors.backPrimary,
              body: Center(
                child: CircularProgressIndicator(
                  color: context.colors.colorRed,
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class AnimatedFAB extends StatefulWidget {
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color iconColor;

  const AnimatedFAB({
    Key? key,
    required this.onPressed,
    required this.backgroundColor,
    required this.iconColor,
  }) : super(key: key);

  @override
  _AnimatedFABState createState() => _AnimatedFABState();
}

class _AnimatedFABState extends State<AnimatedFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          widget.onPressed();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(_) {
    _controller.forward();
  }

  void _onTapUp(_) {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: () {
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: FloatingActionButton(
              onPressed: () {},
              backgroundColor: widget.backgroundColor,
              child: Icon(
                Icons.add,
                color: widget.iconColor,
              ),
            ),
          );
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
    double titleSize =
        interpolate(context.textStyles.largeTitle.fontSize!, 30, progress);
    double subtitleSize =
        interpolate(context.textStyles.title.fontSize!, 10, progress);
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
                color: context.colors.backPrimary,
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
                                  color: context.colors.colorGray,
                                ),
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
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
                                  ? Icon(
                                      Icons.visibility,
                                      size: 30,
                                      color: context.colors.colorGrayLight,
                                    )
                                  : Icon(
                                      Icons.visibility_off,
                                      size: 30,
                                      color: context.colors.colorRed,
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
