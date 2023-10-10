import 'package:equatable/equatable.dart';

abstract class HomePageEvent extends Equatable {
  const HomePageEvent();

  @override
  List<Object> get props => [];
}

class FetchHomePageSettings extends HomePageEvent {
  const FetchHomePageSettings();

  @override
  List<Object> get props => [];
}
