import 'package:equatable/equatable.dart';

class OperationStack<E> extends Equatable {

  final List<E> list;

  void push(E value) => list.add(value);

  E pop() => list.removeLast();
  E drain() => list.removeAt(0);

  E get peek => list.last;

  bool get isEmpty => list.isEmpty;
  bool get isNotEmpty => list.isNotEmpty;

  @override
  String toString() => list.toString();

  OperationStack(this.list);

  @override
  List<Object?> get props => [list];
}