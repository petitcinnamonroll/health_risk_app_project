import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:prostate_predict/screens/riskhome_screen.dart';
import '../calculations.dart';
import 'results_screen.dart';
import 'package:provider/provider.dart';
import '../user_data.dart';
import 'package:health/health.dart';
import '../form_fields.dart';
import 'home_page.dart';

enum FormScreenState {
  DATA_NOT_FETCHED,
  FETCHING_DATA,
  DATA_READY,
  NO_DATA,
  AUTH_NOT_GRANTED
}

typedef Validator<T> = String? Function(T a);
typedef Saver<T> = void Function(T a);

class FormScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
            // Validate returns true if the form is valid, or false otherwise.
          },
        ),
        backgroundColor: Colors.orange,
        elevation: 4,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  new MaterialPageRoute(builder: (context) => new HomePage()),
                );
                // Validate returns true if the form is valid, or false otherwise.
              },
              icon: Icon(Icons.home)),
          IconButton(onPressed: () {}, icon: Icon(Icons.menu))
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.purple, Colors.red],
                begin: Alignment.bottomRight,
                end: Alignment.topLeft),
          ),
        ),
      ),
      body: MyCustomForm(),
      backgroundColor: Colors.pink[50],
    );
  }
}

// Create a Form widget.
class MyCustomForm extends StatefulWidget {
  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class MyCustomFormState extends State<MyCustomForm> {
  final _formKey = GlobalKey<FormState>();
  FormScreenState _state = FormScreenState.DATA_NOT_FETCHED;
  List<HealthDataPoint> _healthDataList = [];

  TextEditingController _ageController = TextEditingController();
  TextEditingController _psaController = TextEditingController();
  /*TextEditingController _tStgController = TextEditingController();
  TextEditingController _gGController = TextEditingController();
  TextEditingController _trTController = TextEditingController();
  TextEditingController _ppcBController = TextEditingController();
  TextEditingController _brcaController = TextEditingController();
  TextEditingController _comoController = TextEditingController();*/

  void _submit(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      // saving calls onSaved: ... for each field (so we have to write it!)
      _formKey.currentState!.save();
      Navigator.push(
        context,
        //TO DO: change to named navigation
        MaterialPageRoute(
            builder: (context) =>
                ResultsScreen()), // instead of new ResultsScreen()
      );
    }
  }

  // this is less relevant now
  String? _validateAge(int? age) {
    RegExp regex = RegExp(r'[1-9]\d*(\.\d+)?');
    if (age == null) {
      return 'Please enter age';
    } else if (!regex.hasMatch(age.toString())) {
      return 'Please enter age as a number';
    } else {
      return null;
    }
    /*
    if (value != null && (value < 35 || value > 95)) {
                      return 'Model only accurate for ages 35-95';
                    }
     */
  }

  String? _validatePSA(String? psa) {
    RegExp regex = RegExp(r'[1-9]\d*(\.\d+)?');
    // trying new regex with no ^ and $
    if (psa == null || psa.isEmpty) {
      return 'Please enter PSA';
    } else if (!regex.hasMatch(psa)) {
      return 'Please enter PSA as a number';
    } else {
      return null;
    }
  }

  // would this work without null check because validated?
  void _saveAge(int? age) {
    Provider.of<UserData>(context, listen: false).setAge(age!);
  }

  void _savePSA(String? psa) {
    Provider.of<UserData>(context, listen: false).setPSA(int.parse(psa!));
  }

  Widget createTextFormField(TextEditingController ctrlr, String field,
      Validator<String?> validator, Saver<String?> saver) {
    return TextFormField(
      controller: ctrlr,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
          hintText: "Your " + field,
          labelText: field,
          labelStyle: TextStyle(fontSize: 24),
          border: InputBorder.none),
      validator: validator,
      onSaved: saver,
    );
  }

  Future fetchData() async {
    /// Get everything from midnight until now
    DateTime startDate = DateTime(2020, 11, 07, 0, 0, 0);
    DateTime endDate = DateTime(2025, 11, 07, 23, 59, 59);

    HealthFactory health = HealthFactory();

    /// Define the types to get.
    List<HealthDataType> types = [
      HealthDataType.STEPS,
      HealthDataType.WEIGHT,
      HealthDataType.HEIGHT,
      HealthDataType.BLOOD_GLUCOSE,
      HealthDataType.DISTANCE_WALKING_RUNNING,
    ];

    setState(() => _state = FormScreenState.FETCHING_DATA);

    /// You MUST request access to the data types before reading them
    bool accessWasGranted = await health.requestAuthorization(types);

    int steps = 0;

    if (accessWasGranted) {
      try {
        /// Fetch new data
        List<HealthDataPoint> healthData =
            await health.getHealthDataFromTypes(startDate, endDate, types);

        /// Save all the new data points
        _healthDataList.addAll(healthData);
      } catch (e) {
        print("Caught exception in getHealthDataFromTypes: $e");
      }

      /// Filter out duplicates
      _healthDataList = HealthFactory.removeDuplicates(_healthDataList);

      /// Print the results
      _healthDataList.forEach((x) {
        print("Data point: $x");
        steps += x.value.round();
      });

      print("Steps: $steps");

      /// Update the UI to display the results
      setState(() {
        _state = _healthDataList.isEmpty
            ? FormScreenState.NO_DATA
            : FormScreenState.DATA_READY;
      });
    } else {
      print("Authorization not granted");
      setState(() => _state = FormScreenState.DATA_NOT_FETCHED);
    }
  }

  @override
  Widget build(BuildContext context) {
    //fetchData();
    return
        // try the SafeArea -- not sure if it makes a difference
        SafeArea(
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          //padding: const EdgeInsets.symmetric(vertical: 16.0),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SliderFormField(onSaved: _saveAge),
              createTextFormField(
                  _psaController, "PSA", _validatePSA, _savePSA),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () => _submit(context),
                  child: Text('Submit'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
