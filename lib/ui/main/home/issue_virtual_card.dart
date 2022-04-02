import 'dart:ui';

import 'package:co/ui/main/home/issue_virtual_card_main.dart';
import 'package:co/ui/widgets/custom_loading.dart';
import 'package:co/ui/widgets/custom_no_internet.dart';
import 'package:co/utils/queries.dart';
import 'package:co/utils/token.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:localstorage/localstorage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';

class IssueVirtaulCard extends StatefulWidget {
  const IssueVirtaulCard({Key? key}) : super(key: key);
  @override
  IssueVirtaulCardState createState() => IssueVirtaulCardState();
}

class IssueVirtaulCardState extends State<IssueVirtaulCard> {
  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  final LocalStorage storage = LocalStorage('token');
  final LocalStorage userStorage = LocalStorage('user_info');
  String queryListEligibleUserCard = Queries.QUERY_LIST_ELIGIBLE_USER_CARD;
  String queryListMerchantGroup = Queries.QUERY_LIST_MERCHANT_GROUP;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String accessToken = storage.getItem("jwt_token");
    return GraphQLProvider(
        client: Token().getLink(accessToken),
        child: Query(
            options: QueryOptions(
              document: gql(queryListEligibleUserCard),
              variables: {
                'orgId': userStorage.getItem('orgId'),
                "accountSubtype": "VIRTUAL"
              },
              
            ),
            builder: (QueryResult eligibleResult,
                {VoidCallback? refetch, FetchMore? fetchMore}) {
              if (eligibleResult.hasException) {
                return CustomNoInternet(handleTryAgain: () {
                  Navigator.of(context)
                      .push(new MaterialPageRoute(
                          builder: (context) => IssueVirtaulCard()))
                      .then((value) => setState(() => {}));
                });
              }

              if (eligibleResult.isLoading) {
                return CustomLoading();
              }

              var eligibleUsers = eligibleResult
                  .data!['listEligibleUsersForCard']['eligibleUsers'];
              return Query(
                  options: QueryOptions(
                    document: gql(queryListMerchantGroup),
                    variables: {"countryCode": "SG"},
                    
                  ),
                  builder: (QueryResult merchantUser,
                      {VoidCallback? refetch, FetchMore? fetchMore}) {
                    if (merchantUser.hasException) {
                      return CustomNoInternet(handleTryAgain: () {
                        Navigator.of(context)
                            .push(new MaterialPageRoute(
                                builder: (context) => IssueVirtaulCard()))
                            .then((value) => setState(() => {}));
                      });
                    }

                    if (merchantUser.isLoading) {
                      return CustomLoading();
                    }

                    var merchantUsers = merchantUser.data!['listMerchantGroups']
                        ['merchantGroup'];

                    // return home(eligibleUsers, merchantUsers);
                    return IssueVirtaulCardMain(
                        eligibleUsers: eligibleUsers,
                        merchantUsers: merchantUsers);
                  });
            }));
  }
}
