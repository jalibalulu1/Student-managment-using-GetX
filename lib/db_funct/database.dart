import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:student_manag/db_funct/data_model.dart';

File? image;
String img = '';
RxList<Stud_model> studentListNotifier = <Stud_model>[].obs;

class Cont extends GetxController {
  RxList<Stud_model> searchData = <Stud_model>[].obs;


  pickimage() async {
    final pimage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pimage == null) {
      return;
    } else {
      image = File(pimage.path);
      update();
      final bytes = File(pimage.path).readAsBytesSync();
      img = base64Encode(bytes);
    }
  }

  Future<void> addStudent(Stud_model value) async {
    final studentDB = await Hive.openBox<Stud_model>('student_db');
    final _id = await studentDB.add(value);
    value.id = _id;
    studentDB.put(value.id, value);
    studentListNotifier.clear();
    studentListNotifier.addAll(studentDB.values);
    // studentListNotifier.notifyListeners();
    update();
  }

  Future<void> getAllstud([String? value]) async {
    final studentDB = await Hive.openBox<Stud_model>('student_db');
    studentListNotifier.clear();
    studentListNotifier.addAll(studentDB.values);
    update();
  }

  Future<void> deletestudent(int id) async {
    final studentDB = await Hive.openBox<Stud_model>('student_db');
    await studentDB.delete(id);
    getAllstud();
  }

  Future<void> UpdateStudent(Stud_model value) async {
    final studentDB = await Hive.openBox<Stud_model>('student_db');
    await studentDB.put(value.id, value);
    getAllstud();
  }

  getSearchResult(String value) {
    searchData.clear();
    for (var index in studentListNotifier) {
      if (index.name.toString().toLowerCase().contains(
            value.toLowerCase(),
          )) {
        Stud_model data = Stud_model(
          name: index.name,
          age: index.age,
          regnum: index.regnum,
          class1: index.class1,
          img: index.img,
        );
        searchData.add(data);
        update();
      }
    }
  }
}
