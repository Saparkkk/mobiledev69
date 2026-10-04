import 'package:dartz/dartz.dart';
import '../models/house_model.dart';
import '../models/appointment_model.dart';

abstract class HouseRepository {
  Future<Either<String, List<HouseModel>>> getHouses();
  Future<Either<String, void>> createAppointment(AppointmentModel appt);
  Future<Either<String, void>> updateAppointment(String id, AppointmentModel appt);
  Future<Either<String, void>> deleteAppointment(String id);
  Future<Either<String, List<AppointmentModel>>> getAppointments();
}