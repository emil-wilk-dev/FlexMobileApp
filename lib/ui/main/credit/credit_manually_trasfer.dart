import 'package:flexflutter/constants/constants.dart';
import 'package:flexflutter/ui/widgets/custom_bottom_bar.dart';
import 'package:flexflutter/ui/widgets/custom_header.dart';
import 'package:flexflutter/ui/widgets/custom_main_header.dart';
import 'package:flexflutter/ui/widgets/signup_progress_header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flexflutter/utils/scale.dart';
import 'package:flexflutter/ui/widgets/custom_textfield.dart';
import 'package:flexflutter/ui/widgets/custom_spacer.dart';

class CreditManuallyTransferScreen extends StatefulWidget {
  const CreditManuallyTransferScreen({Key? key}) : super(key: key);

  @override
  CreditManuallyTransferScreenState createState() => CreditManuallyTransferScreenState();
}

class CreditManuallyTransferScreenState extends State<CreditManuallyTransferScreen> {

  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  bool flagCopied = false;

  handleBack() {
    Navigator.of(context).pop();
  }

  handleCopied() {
    setState(() {
      flagCopied = true;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Scaffold(
            body: Stack(
                children:[
                  SizedBox(
                    height: hScale(812),
                    child: SingleChildScrollView(
                        child: Column(
                            children: [
                              const CustomSpacer(size: 44),
                              const CustomMainHeader(title: 'Flex PLUS Credit'),
                              const CustomSpacer(size: 21),
                              titleField(),
                              const CustomSpacer(size: 29),
                              depositFundsField(),
                              const CustomSpacer(size: 19),
                              businessField(),
                              const CustomSpacer(size: 88),
                            ]
                        )
                    )
                  ),
                  const Positioned(
                    bottom: 0,
                    left: 0,
                    child: CustomBottomBar(active: 3),
                  )
                ]
            )
        )
    );
  }

  Widget titleField() {
    return Container(
      width: wScale(327),
      alignment: Alignment.centerLeft,
      child: Text('Flex PLUS Account 123456', style: TextStyle(fontSize: fSize(16), fontWeight: FontWeight.w600, color: const Color(0xFF1A2831))),
    );
  }

  Widget depositFundsField() {
    return Container(
      width: wScale(327),
      padding: EdgeInsets.only(left: wScale(16), right: wScale(16), top: hScale(16), bottom: hScale(16)),
      margin: EdgeInsets.only(bottom: hScale(10)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(hScale(10)),
          topRight: Radius.circular(hScale(10)),
          bottomLeft: Radius.circular(hScale(10)),
          bottomRight: Radius.circular(hScale(10)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.25),
            spreadRadius: 4,
            blurRadius: 20,
            offset: const Offset(0, 1), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Deposit funds to your Flex Business Account', style: TextStyle(fontSize: fSize(16), fontWeight: FontWeight.w500, color: Color(0xFF1A2831))),
          const CustomSpacer(size: 18),
          Text('Bank Account Details', style:TextStyle(color: const Color(0xff465158), fontSize: fSize(16), fontWeight: FontWeight.w600)),
          const CustomSpacer(size: 18),
          Text('Bank Name', style:TextStyle(color: const Color(0xff70828D), fontSize: fSize(12))),
          const CustomSpacer(size: 10),
          Row(
            children: [
              Image.asset('assets/bank_icon.png', fit: BoxFit.contain, width: wScale(20)),
              SizedBox(width: wScale(10)),
              detail('DBS Bank, Singapore')
            ],
          ),
          const CustomSpacer(size: 38),
          Text('Virtual Account Number', style:TextStyle(color: const Color(0xff70828D), fontSize: fSize(12))),
          const CustomSpacer(size: 8),
          Row(
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  primary: const Color(0xff515151),
                  padding: EdgeInsets.zero,
                  textStyle: TextStyle(fontSize: fSize(14), fontWeight: FontWeight.w500, color: const Color(0xff040415)),
                ),
                onPressed: () { handleCopied(); },
                child: const Text('885123000180'),
              ),
              SizedBox(width: wScale(10)),
              flagCopied ? const Icon( Icons.content_copy, color: Color(0xff30E7A9), size: 14.0 ): const SizedBox(),
              SizedBox(width: wScale(4)),
              flagCopied ? Text('Copied', style: TextStyle(fontSize: fSize(14), fontWeight: FontWeight.w500, color: const Color(0xff30E7A9))): const SizedBox(),
            ],
          ),
          const CustomSpacer(size: 24),
          title('Account Name'),
          const CustomSpacer(size: 8),
          detail('FXR BUSINESS SERVICES PTE.LTD.'),
        ],
      ),
    );
  }

  Widget title(text) {
    return Text(text, style:TextStyle(color: const Color(0xff70828D), fontSize: fSize(12)));
  }

  Widget detail(text) {
    return Text(text, style:TextStyle(color: const Color(0xff040415), fontSize: fSize(14), fontWeight: FontWeight.w500));
  }

  Widget businessField() {
    return SizedBox(
        width: wScale(327),
        child: Text('*Funds will be credited within 1 business day',
            style: TextStyle(color: const Color(0xff1DA7FF), fontWeight: FontWeight.w600, fontSize: fSize(12))),
    );
  }

}