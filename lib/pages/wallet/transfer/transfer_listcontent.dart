import 'dart:async';

import 'package:beewallet/component/custom_refresher.dart';
import 'package:beewallet/component/empty_data.dart';
import 'package:beewallet/component/trasnfer_listcell.dart';
import 'package:beewallet/model/node/node_model.dart';
import 'package:beewallet/model/tokens/collection_tokens.dart';
import 'package:beewallet/model/transrecord/trans_record.dart';
import 'package:beewallet/net/chain_services.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../public.dart';

class TransferListContent extends StatefulWidget {
  TransferListContent({Key? key, required this.type}) : super(key: key);
  final int type;

  @override
  State<TransferListContent> createState() => _TransferListContentState();
}

class _TransferListContentState extends State<TransferListContent>
    with AutomaticKeepAliveClientMixin {
  RefreshController refreshController = RefreshController();

  List<TransRecordModel> _dappListData = [];
  MCollectionTokens? _tokens;
  TRWallet? _trWalletInfo;
  StreamSubscription? _transupTE;
  String? _fingerprint;
  int? _before;
  int _page = 1;
  void initState() {
    // TODO: implement initState
    super.initState();

    //刷新包
    _transupTE = eventBus.on<MtransListUpdate>().listen((event) {
      _initData(isRefresh: true);
    });
    _tokens = Provider.of<CurrentChooseWalletState>(context, listen: false)
        .chooseTokens();
    _trWalletInfo =
        Provider.of<CurrentChooseWalletState>(context, listen: false)
            .currentWallet;
    LogUtil.v("initState " + widget.type.toString());
    _initData(isRefresh: true);
  }

  @override
  void dispose() {
    _transupTE?.cancel();
    super.dispose();
  }

  void _initData({required bool isRefresh}) async {
    if (isRefresh == true) {
      _fingerprint = null;
      _before = null;
      _page = 1;
    } else {
      _page += 1;
    }
    KCoinType coinType = _trWalletInfo!.coinType!.geCoinType();
    KTransDataType kTransDataType = KTransDataType.ts_all;
    for (var element in KTransDataType.values) {
      if (widget.type == element.index) {
        kTransDataType = element;
        break;
      }
    }

    String from = _trWalletInfo?.walletAaddress ?? "";
    List<TransRecordModel> datas = [];
    datas = await ChainServices.requestETHTranslist(
        kTransDataType: kTransDataType,
        from: from,
        page: _page,
        tokens: _tokens!);

    if (mounted) {
      setState(() {
        if (isRefresh == true) {
          _dappListData.clear();
        }
        _dappListData.addAll(datas);
      });
    }

    refreshController.loadComplete();
    refreshController.refreshCompleted(resetFooterState: true);

    if (datas.isEmpty) {
      refreshController.loadNoData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomRefresher(
        onRefresh: () {
          _initData(isRefresh: true);
        },
        onLoading: () {
          _initData(isRefresh: false);
        },
        child: _dappListData.isEmpty
            ? EmptyDataPage()
            : ListView.builder(
                itemCount: _dappListData.length,
                itemBuilder: (BuildContext tx, int index) {
                  TransRecordModel model = _dappListData[index];
                  return TransferListCell(
                    model: model,
                    from: _trWalletInfo?.walletAaddress ?? "",
                  );
                },
              ),
        refreshController: refreshController);
  }

  // @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
