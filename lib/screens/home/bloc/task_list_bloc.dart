import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:todo_list/data/data.dart';
import 'package:todo_list/data/repo/repository.dart';

part 'task_list_event.dart';
part 'task_list_state.dart';

class TaskListBloc extends Bloc<TaskListEvent, TaskListState> {
  final Repository<TaskEntity> repository;
  TaskListBloc(this.repository) : super(TaskListInitial()) {
    on<TaskListEvent>((event, emit) async {
      if (event is TaskListStarted || event is TaskListSearch) {
        final String searchTerm;
        emit(TaskListLoading());
         await Future.delayed(const Duration(seconds: 0));
        if (event is TaskListSearch) {
          searchTerm = event.searchTerm;
          // print("Search Term: $searchTerm");  // Debugging
        } else {
          searchTerm = '';
        }
        try {
          // throw Exception('test');
          final items = await repository.getAll(searchKeyword: searchTerm);

          if (items.isNotEmpty) {
            emit(TaskListSuccess(items));
          } else {
            emit(TaskListEmpty());
          }
        } catch (e) {
          emit(TaskListError(
              errorMessage: "Unknown Error! Please Try Again Later"));
        }
      } else if (event is TaskListDeletAll){
        await repository.deleteAll();
        emit(TaskListEmpty());
      }
    });
  }
}
