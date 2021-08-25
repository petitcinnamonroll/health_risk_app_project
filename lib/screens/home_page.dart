import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prostate_predict/ui_constants.dart';
import 'package:prostate_predict/data/user_data.dart';
import 'package:prostate_predict/screens/riskhome_screen.dart';
import 'package:prostate_predict/widgets/screen_widgets.dart';
import 'package:provider/provider.dart';
import '../widgets/homepage_widgets.dart';
import 'package:percent_indicator/percent_indicator.dart';


class HomePage extends StatelessWidget {
  final List<RiskSelectOption> calculatorOptions = getRiskSelectOptions();
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      extendBodyBehindAppBar: true,
      appBar: HomeAppBar(context, _key),
      endDrawer: buildSideBar(context),
      backgroundColor: kDarkPurple,
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.all(20.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Welcome',
                          style: TextStyle(
                            fontFamily: 'Avenir',
                            fontSize: 44,
                            color: const Color(0xffffffff),
                            fontWeight: FontWeight.w900,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40,),
                  PercentCircle(),
                  SizedBox(height: 60,),
                  RiskListView(riskList: calculatorOptions),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
