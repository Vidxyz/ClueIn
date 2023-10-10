import 'package:equatable/equatable.dart';

abstract class HomePageState extends Equatable {
  const HomePageState();

  @override
  List<Object> get props => [];

}

class HomePageStateInitial extends HomePageState {}

class HomePageSettingsLoading extends HomePageState {

  const HomePageSettingsLoading();
}

class HomePageSettingsFetched extends HomePageState {
  final int primaryColor;

  const HomePageSettingsFetched({
    required this.primaryColor,
  });

  @override
  List<Object> get props => [
    primaryColor,
  ];
}
