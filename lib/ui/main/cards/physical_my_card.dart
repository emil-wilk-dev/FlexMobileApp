// ignore_for_file: prefer_const_constructors

import 'package:co/ui/main/cards/manage_limits.dart';
import 'package:co/ui/widgets/all_transaction_field.dart';
import 'package:co/ui/widgets/custom_result_modal.dart';
import 'package:co/ui/widgets/custom_spacer.dart';
import 'package:co/utils/mutations.dart';
import 'package:co/utils/queries.dart';
import 'package:co/utils/token.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:localstorage/localstorage.dart';

class PhysicalMyCards extends StatefulWidget {
  const PhysicalMyCards({Key? key}) : super(key: key);

  @override
  PhysicalMyCardsState createState() => PhysicalMyCardsState();
}

class PhysicalMyCardsState extends State<PhysicalMyCards> {
  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  bool showCardDetail = true;
  bool freezeMode = false;
  final LocalStorage storage = LocalStorage('token');
  final LocalStorage userStorage = LocalStorage('user_info');
  String getUserAccountSummary = Queries.QUERY_USER_ACCOUNT_SUMMARY;
  String freezeMutation = FXRMutations.MUTATION_FREEZE_FINANCE_ACCOUNT;
  String unFreezeMutation = FXRMutations.MUTATION_FREEZE_FINANCE_ACCOUNT;

  handleCloneSetting() {}

  handleMonthlySpendLimit() {}

  handleAction(index, userAccountSummary) {
    if (index == 0) _showFreezeModalDialog(context, userAccountSummary);
    if (index == 1) {
      Navigator.of(context).push(
        CupertinoPageRoute(builder: (context) => const ManageLimits()),
      );
    }
  }

  handleShowCardDetail() {
    setState(() {
      showCardDetail = !showCardDetail;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String accessToken = storage.getItem("jwt_token");
    return GraphQLProvider(client: Token().getLink(accessToken), child: home());
  }

  Widget home() {
    var orgId = userStorage.getItem('orgId');
    return Query(
        options: QueryOptions(
          document: gql(getUserAccountSummary),
          variables: {'orgId': orgId},
          // pollInterval: const Duration(seconds: 10),
        ),
        builder: (QueryResult result,
            {VoidCallback? refetch, FetchMore? fetchMore}) {
          if (result.hasException) {
            return Text(result.exception.toString());
          }

          if (result.isLoading) {
            return Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(top: hScale(30)),
                child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF60C094))));
          }
          var userAccountSummary =
              result.data!['readUserFinanceAccountSummary'];
          return mainHome(userAccountSummary);
        });
  }

  Widget mainHome(userAccountSummary) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: wScale(24)),
        child: Column(children: [
          const CustomSpacer(size: 31),
          cardDetailField(userAccountSummary),
          const CustomSpacer(size: 10),
          Column(
            children: [
              spendLimitField(userAccountSummary),
              const CustomSpacer(size: 20),
              actionButtonField(userAccountSummary),
              const CustomSpacer(size: 20),
              userAccountSummary['data']['physicalCard'] == null
                  ? SizedBox()
                  : AllTransaction(
                      cardID: userAccountSummary['data']['physicalCard']['id']),
            ],
          )
        ]));
  }

  Widget cardDetailField(userAccountSummary) {
    return Container(
      width: wScale(327),
      padding: EdgeInsets.only(
          left: wScale(16), right: wScale(16), bottom: hScale(16)),
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
            color: const Color(0xFF106549).withOpacity(0.1),
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
          cardTitle(userAccountSummary),
          const CustomSpacer(size: 10),
          cardField(userAccountSummary),
          const CustomSpacer(size: 14),
          cardValueField(userAccountSummary)
        ],
      ),
    );
  }

  Widget cardTitle(userAccountSummary) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('My Card',
            style: TextStyle(
                fontSize: fSize(14),
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A2831))),
        userAccountSummary['data']['physicalCard'] == null
            ? SizedBox()
            : TextButton(
                style: TextButton.styleFrom(
                  primary: const Color(0xff60C094),
                  padding: EdgeInsets.zero,
                  textStyle: TextStyle(
                      fontSize: fSize(12),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff60C094),
                      decoration: TextDecoration.underline),
                ),
                onPressed: () {
                  handleCloneSetting();
                },
                child: const Text('Clone Settings',
                    style: TextStyle(decoration: TextDecoration.underline)),
              ),
      ],
    );
  }

  Widget cardField(userAccountSummary) {
    return Container(
        width: wScale(295),
        height: wScale(187),
        padding: EdgeInsets.all(hScale(16)),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/physical_card_detail.png"),
            colorFilter: new ColorFilter.mode(
                Colors.black.withOpacity(
                    userAccountSummary['data']['physicalCard'] == null
                        ? 0.5
                        : 1),
                BlendMode.dstATop),
            fit: BoxFit.contain,
          ),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: userAccountSummary['data'] == null
            ? SizedBox()
            : userAccountSummary['data']['physicalCard'] == null
                ? SizedBox()
                : Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [const SizedBox(), eyeIconField()],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                userAccountSummary['data']['physicalCard']
                                    ['accountName'],
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w300,
                                    fontSize: fSize(14))),
                            const CustomSpacer(size: 6),
                            Row(children: [
                              Text(
                                  showCardDetail
                                      ? userAccountSummary['data']
                                              ['physicalCard']
                                          ['permanentAccountNumber']
                                      : '* * * *  * * * *  * * * *  * * * *',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: fSize(16))),
                              SizedBox(width: wScale(7)),
                              const Icon(Icons.content_copy,
                                  color: Color(0xff30E7A9), size: 14.0)
                            ]),
                          ],
                        ),
                        Row(children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Valid Thru',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: fSize(10))),
                              Text(
                                  showCardDetail
                                      ? userAccountSummary['data']
                                          ['physicalCard']['expiryDate']
                                      : 'MM / DD',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: fSize(11),
                                      fontWeight: FontWeight.bold))
                            ],
                          ),
                          SizedBox(width: wScale(10)),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('CVV',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: fSize(10))),
                              Text(
                                  showCardDetail
                                      ? userAccountSummary['data']
                                          ['physicalCard']['cvv']
                                      : '* * *',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: fSize(11),
                                      fontWeight: FontWeight.bold))
                            ],
                          ),
                          SizedBox(width: wScale(6)),
                          const Icon(Icons.content_copy,
                              color: Color(0xff30E7A9), size: 14.0)
                        ])
                      ]));
  }

  Widget cardValueField(userAccountSummary) {
    var availableLimit = userAccountSummary['data']['physicalCard'] == null
        ? {}
        : userAccountSummary['data']['physicalCard']['financeAccountLimits'][0]
            ['availableLimit'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Available Limit',
            style: TextStyle(
                fontSize: fSize(14),
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A2831))),
        Container(
            padding: EdgeInsets.only(
                left: wScale(16),
                right: wScale(16),
                top: hScale(5),
                bottom: hScale(5)),
            decoration: BoxDecoration(
              color: const Color(0xFFDEFEE9),
              borderRadius: BorderRadius.all(
                Radius.circular(hScale(16)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    userAccountSummary['data']['physicalCard'] == null
                        ? ""
                        : "${userAccountSummary['data']['physicalCard']['currencyCode']}  ",
                    style: TextStyle(
                        fontSize: fSize(12),
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF30E7A9),
                        height: 1)),
                Text(
                    userAccountSummary['data'] == null
                        ? '0'
                        : userAccountSummary['data']['physicalCard'] == null
                            ? '0'
                            : "${availableLimit.toString()}",
                    style: TextStyle(
                        fontSize: fSize(14),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF30E7A9)))
              ],
            ))
      ],
    );
  }

  Widget eyeIconField() {
    return Container(
        height: hScale(34),
        width: hScale(34),
        // padding: EdgeInsets.all(hScale(17)),
        decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(hScale(17)),
              topRight: Radius.circular(hScale(17)),
              bottomLeft: Radius.circular(hScale(17)),
              bottomRight: Radius.circular(hScale(17)),
            )),
        child: IconButton(
          padding: const EdgeInsets.all(0),
          // icon: const Icon(Icons.remove_red_eye_outlined, color: Color(0xff30E7A9),),
          icon: Image.asset(
              showCardDetail ? 'assets/hide_eye.png' : 'assets/show_eye.png',
              fit: BoxFit.contain,
              height: hScale(16)),
          iconSize: hScale(17),
          onPressed: () {
            handleShowCardDetail();
          },
        ));
  }

  Widget spendLimitField(userAccountSummary) {
    var limitData = userAccountSummary['data']['physicalCard'] == null
        ? {"limitValue": 0}
        : userAccountSummary['data']['physicalCard']['financeAccountLimits'][0];
    double percentage = userAccountSummary['data']['physicalCard'] == null
        ? 0
        : (1 - limitData['availableLimit'] / limitData['limitValue']) as double;
    return Container(
      width: wScale(327),
      padding: EdgeInsets.only(
          left: wScale(16),
          right: wScale(16),
          top: hScale(16),
          bottom: hScale(16)),
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
            color: const Color(0xFF106549).withOpacity(0.1),
            spreadRadius: 4,
            blurRadius: 20,
            offset: const Offset(0, 1), // changes position of shadow
          ),
        ],
      ),
      child: TextButton(
          style: TextButton.styleFrom(
            primary: const Color(0xFFFFFFFF),
            padding: EdgeInsets.zero,
          ),
          onPressed: () {
            handleMonthlySpendLimit();
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Monthly Spend Limit',
                      style: TextStyle(
                          fontSize: fSize(14),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A2831))),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            userAccountSummary['data']['physicalCard'] == null
                                ? ""
                                : "${userAccountSummary['data']['physicalCard']['currencyCode']} ",
                            style: TextStyle(
                                fontSize: fSize(10),
                                fontWeight: FontWeight.w600,
                                height: 1,
                                color: const Color(0xFF1A2831))),
                        Text(limitData['limitValue'].toString(),
                            style: TextStyle(
                                fontSize: fSize(14),
                                fontWeight: FontWeight.w600,
                                height: 1,
                                color: const Color(0xFF1A2831))),
                      ])
                ],
              ),
              const CustomSpacer(size: 12),
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                child: LinearProgressIndicator(
                  value: percentage,
                  backgroundColor: const Color(0xFFF4F4F4),
                  color: percentage < 0.8
                      ? const Color(0xFF30E7A9)
                      : percentage < 0.9
                          ? const Color(0xFFFEB533)
                          : const Color(0xFFEB5757),
                  minHeight: hScale(10),
                ),
              ),
              const CustomSpacer(size: 12),
              Row(
                children: [
                  Image.asset(
                      percentage < 0.8
                          ? 'assets/emoji1.png'
                          : percentage < 0.9
                              ? 'assets/emoji2.png'
                              : 'assets/emoji3.png',
                      fit: BoxFit.contain,
                      width: wScale(18)),
                  SizedBox(width: wScale(10)),
                  Text(
                      percentage < 0.8
                          ? 'Great job, you are within your allocated limit!'
                          : percentage < 0.9
                              ? 'Careful! You are almost at the limit.'
                              : 'You have reached the limit.',
                      style: TextStyle(
                          fontSize: fSize(12), color: const Color(0xFF70828D))),
                  percentage >= 0.8
                      ? Container(
                          height: hScale(12),
                          child: TextButton(
                              style: TextButton.styleFrom(
                                  padding: EdgeInsets.all(0)),
                              onPressed: () {},
                              child: Text('Add more!',
                                  style: TextStyle(
                                      fontSize: fSize(12),
                                      color: const Color(0xFF30E7A9)))))
                      : SizedBox()
                ],
              )
            ],
          )),
    );
  }

  Widget actionButton(imageUrl, text, index, userAccountSummary) {
    return Container(
        width: wScale(102),
        // height: hScale(82),
        padding:
            EdgeInsets.symmetric(vertical: hScale(16), horizontal: wScale(16)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF106549).withOpacity(0.1),
              spreadRadius: 4,
              blurRadius: 40,
              offset: const Offset(0, 1), // changes position of shadow
            ),
          ],
        ),
        child: TextButton(
            style: TextButton.styleFrom(
                primary: const Color(0xFFFFFFFF), padding: EdgeInsets.zero),
            onPressed: () {
              userAccountSummary['data']['physicalCard'] != null
                  ? handleAction(index, userAccountSummary)
                  : null;
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  imageUrl,
                  fit: BoxFit.contain,
                  height: hScale(28),
                  width: wScale(28),
                ),
                const CustomSpacer(
                  size: 10,
                ),
                Text(
                  text,
                  style: TextStyle(
                      fontSize: fSize(12),
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF70828D)),
                  textAlign: TextAlign.center,
                ),
              ],
            )));
  }

  Widget actionButtonField(userAccountSummary) {
    return SizedBox(
      width: wScale(327),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        actionButton('assets/free.png', 'Freeze Card', 0, userAccountSummary),
        actionButton('assets/limit.png', 'Edit Limit', 1, userAccountSummary),
        actionButton('assets/cancel.png', 'Cancel Card', 2, userAccountSummary),
      ]),
    );
  }

  _showFreezeModalDialog(context, userAccountSummary) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Padding(
              padding: EdgeInsets.symmetric(horizontal: wScale(40)),
              child: Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  child: freezeMutationField(userAccountSummary)));
        });
  }

  _showResultModalDialog(context, success, message) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Padding(
              padding: EdgeInsets.symmetric(horizontal: wScale(40)),
              child: Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  child: CustomResultModal(
                      status: success,
                      title: success ? "Success" : "Failed",
                      message: message)));
        });
  }

  Widget freezeModalField(runMutation, userAccountSummary) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
          padding: EdgeInsets.symmetric(vertical: hScale(25)),
          child: Column(children: [
            Image.asset('assets/snow_icon.png',
                fit: BoxFit.contain, height: wScale(30)),
            const CustomSpacer(size: 15),
            Text('Editing spend limit?',
                style: TextStyle(
                    fontSize: fSize(14), fontWeight: FontWeight.w700)),
            const CustomSpacer(size: 10),
            Text(
              'To make changes to the spend limit\nassigned to this card, please reach out to\nyour company administrator.',
              style:
                  TextStyle(fontSize: fSize(12), fontWeight: FontWeight.w400),
              textAlign: TextAlign.center,
            ),
          ])),
      Container(height: 1, color: const Color(0xFFD5DBDE)),
      Container(
          height: hScale(50),
          child: Row(
            children: [
              Expanded(
                  flex: 1,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      primary: const Color(0xff30E7A9),
                      textStyle: TextStyle(
                          fontSize: fSize(16), color: const Color(0xff30E7A9)),
                    ),
                    onPressed: () => Navigator.of(context, rootNavigator: true)
                        .pop('dialog'),
                    child: const Text('Cancel'),
                  )),
              Container(width: 1, color: const Color(0xFFD5DBDE)),
              Expanded(
                  flex: 1,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      primary: const Color(0xff30E7A9),
                      textStyle: TextStyle(
                          fontSize: fSize(16), color: const Color(0xff30E7A9)),
                    ),
                    onPressed: () {
                      var orgId = userStorage.getItem('orgId');
                      var accountId =
                          userAccountSummary['data']['physicalCard']['id'];
                      runMutation(
                          {'financeAccountId': accountId, "orgId": orgId});
                      Navigator.of(context, rootNavigator: true).pop('dialog');
                    },
                    child: const Text('Ok'),
                  ))
            ],
          ))
    ]);
  }

  Widget freezeMutationField(userAccountSummary) {
    String accessToken = storage.getItem("jwt_token");
    String cardStatus =
        userAccountSummary['data']['physicalCard']['cardStatus'];
    return GraphQLProvider(
        client: Token().getLink(accessToken),
        child: Mutation(
            options: MutationOptions(
              document: gql(cardStatus == 'ACTIVE'
                  ? freezeMutation
                  : cardStatus == 'SUSPENDED'
                      ? unFreezeMutation
                      : ''),
              update: (GraphQLDataProxy cache, QueryResult? result) {
                return cache;
              },
              onCompleted: (resultData) {
                var success = resultData['freezeFinanceAccount']['success'];
                var message = resultData['freezeFinanceAccount']['message'];
                if (success)
                  setState(() {
                    freezeMode = true;
                  });
                _showResultModalDialog(context, success, message);
              },
            ),
            builder: (RunMutation runMutation, QueryResult? result) {
              return freezeModalField(runMutation, userAccountSummary);
            }));
  }
}
