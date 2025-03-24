import 'package:bloc/bloc.dart';
import 'package:pd_app/api/PatientService.dart';
import 'package:pd_app/model/Patient.dart';

class PatientListCubit extends Cubit<PatientListUiState> {
  PatientListCubit() : super(PatientListUiState());

  void fetch() async {
    state.patients = await PatientService.getPatientList();
    emit(state);
  }
}

class PatientListUiState {
  List<Patient> patients = [];
}
