// ignore_for_file: avoid_print, must_be_immutable

import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/shared/components/components.dart';
import 'package:todo_app/shared/cubit/cubit.dart';
import 'package:todo_app/shared/cubit/states.dart';

class HomeLayout extends StatelessWidget {
  HomeLayout({super.key});

  var scaffoldkey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();

  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit, AppStates>(
        listener: (context, state) {
          if (state is AppInsertDatabaseState) {
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          AppCubit cubit = AppCubit.get(context);
          return Scaffold(
            key: scaffoldkey,

            //1
            appBar: AppBar(
              title: Text(cubit.titles[cubit.currentIndex]),
            ),

            // 2-
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                if (cubit.isBottomSheetShown) {
                  if (formKey.currentState!.validate()) {
                    cubit.insertToDatabase(
                        title: titleController.text,
                        date: dateController.text,
                        time: timeController.text);
                  }
                } else {
                  scaffoldkey.currentState!
                      .showBottomSheet(
                        (context) => Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(20.0),
                          child: Form(
                            key: formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                //1-Text Field At BottomSheet

                                defaultFormField(
                                    controller: titleController,
                                    type: TextInputType.text,
                                    validate: ((String? value) {
                                      if (value!.isEmpty) {
                                        return "Text can't be with Empty";
                                      }
                                      return null;
                                    }),
                                    label: 'Task Title',
                                    prefix: Icons.title),

                                const SizedBox(
                                  height: 20.0,
                                ),

                                //2-Text Field At BottomSheet

                                defaultFormField(
                                  controller: timeController,
                                  type: TextInputType.datetime,
                                  validate: ((String? value) {
                                    if (value!.isEmpty) {
                                      return "Time can't be with empty";
                                    }
                                    return null;
                                  }),
                                  label: 'Task Time',
                                  prefix: Icons.watch_later_outlined,
                                  onTap: () {
                                    showTimePicker(
                                            context: context,
                                            initialTime: TimeOfDay.now())
                                        .then((value) {
                                      timeController.text =
                                          value!.format(context).toString();
                                    });
                                  },
                                ),

                                const SizedBox(
                                  height: 20.0,
                                ),

                                //3-Text Field At BottomSheet

                                defaultFormField(
                                  controller: dateController,
                                  type: TextInputType.datetime,
                                  validate: ((String? value) {
                                    if (value!.isEmpty) {
                                      return "Date can't be with empty";
                                    }
                                    return null;
                                  }),
                                  label: 'Task Date',
                                  prefix: Icons.calendar_today,
                                  onTap: () {
                                    showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.parse('2070-02-27'),
                                    ).then((value) {
                                      if (value != null) {
                                        dateController.text =
                                            DateFormat.yMMMd().format(value);
                                      } else {
                                        // Handle the case where the user canceled the date selection.
                                      }
                                    }).catchError((error) {
                                      // Handle any errors that occur during date selection.
                                      print("Error selecting date: $error");
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        elevation: 20.0,
                      )
                      .closed
                      .then((value) {
                    cubit.changeBottomSheetState(
                        isShow: false, icon: Icons.edit);
                    dateController.text = "";
                    timeController.text = "";
                    titleController.text = "";
                  });
                  cubit.changeBottomSheetState(isShow: true, icon: Icons.add);
                }
              },
              child: Icon(cubit.fabicon),
            ),
            //3
            bottomNavigationBar: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: cubit.currentIndex,
                onTap: (index) {
                  cubit.changeIndex(index);
                },
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.menu),
                    label: "Tasks",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.check_circle_outline),
                    label: "Done",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.archive_outlined),
                    label: "Archive",
                  ),
                ]),
            //4
            body: ConditionalBuilder(
              condition: state is! AppGetDatabaseLoadingState,
              builder: (context) => cubit.screen[cubit.currentIndex],
              fallback: (context) =>
                  const Center(child: CircularProgressIndicator()),
            ),
          );
        },
      ),
    );
  }
}
