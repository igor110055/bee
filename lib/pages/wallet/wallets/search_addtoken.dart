import 'package:beewallet/component/assets_cell.dart';
import 'package:beewallet/component/custom_refresher.dart';
import 'package:beewallet/component/empty_data.dart';
import 'package:beewallet/component/nft_typecell.dart';
import 'package:beewallet/model/nft/nft_model.dart';
import 'package:beewallet/model/tokens/collection_tokens.dart';
import 'package:beewallet/net/url.dart';
import 'package:beewallet/net/wallet_services.dart';
import 'package:beewallet/pages/wallet/wallets/search_tokenmanager.dart';
import 'package:beewallet/utils/custom_toast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../public.dart';
import 'custom_addnft.dart';
import 'custom_addtokens.dart';

class SearchAddToken extends StatefulWidget {
  SearchAddToken({Key? key}) : super(key: key);

  @override
  State<SearchAddToken> createState() => _SearchAddTokenState();
}

class _SearchAddTokenState extends State<SearchAddToken> {
  TextEditingController searchController = TextEditingController();
  RefreshController _refreshController = RefreshController();

  int _homeTokenType = 0;
  int _page = 1;
  List _datas = [];

  @override
  void initState() {
    super.initState();
    _homeTokenType =
        Provider.of<CurrentChooseWalletState>(context, listen: false)
            .homeTokenType;
    _initData(_page);
  }

  void _initData(int page, {String? keywords}) async {
    if (_homeTokenType == 1) {
      _initNFTData(page, keywords: keywords);
      return;
    }
    HWToast.showLoading();
    final TRWallet trWallet =
        Provider.of<CurrentChooseWalletState>(context, listen: false)
            .currentWallet!;
    String? chainType = "";
    String walletID = trWallet.walletID!;
    _page = page;
    List indexTokens = [];
    bool popular = false;
    if (keywords == null || keywords.isEmpty) {
      popular = true;
      indexTokens = await WalletServices.getpopularToken(chainType: chainType);
    } else {
      if (await keywords.checkAddress(KCoinType.BSC) == true) {
        indexTokens = await WalletServices.gettokenList(page, 20,
            tokenName: null,
            tokenContractAddress: keywords,
            chainType: chainType);
      } else {
        indexTokens = await WalletServices.gettokenList(page, 20,
            tokenName: keywords,
            tokenContractAddress: null,
            chainType: chainType);
      }
    }

    List<MCollectionTokens> tokens = [];
    KNetType netType = RequestURLS.getHost() == RequestURLS.testUrl
        ? KNetType.Testnet
        : KNetType.Mainnet;
    for (var item in indexTokens) {
      MCollectionTokens token = MCollectionTokens();
      token.token = item["tokenName"] ?? "";
      token.decimals = item["amountPrecision"] as int;
      token.contract = item["tokenContractAddress"] ?? "";
      token.digits = item["pricePrecision"] ?? 4;
      String tokenIconUrl = item["tokenIconUrl"] ?? "";
      String chainIconUrl = item["chainIconUrl"] ?? "";
      token.iconPath = tokenIconUrl + "," + chainIconUrl;
      token.coinType = item["chainType"] ?? "";
      KCoinType? cointYPE = token.coinType!.chainTypeGetCoinType();
      token.chainType = cointYPE?.index;
      token.tokenType =
          token.contract == "0x0000000000000000000000000000000000000000"
              ? KTokenType.native.index
              : KTokenType.token.index;

      token.kNetType = netType.index;
      if (token.chainType == null) {
        assert(token.chainType != null, "???????????????????????? ");
        continue;
      }
      token.owner = walletID;
      token.tokenID = token.createTokenID(walletID);
      tokens.add(token);
    }
    List<MCollectionTokens> statesTokens =
        await MCollectionTokens.findTokens(walletID, netType.index);
    for (var item in tokens) {
      for (var stateTokens in statesTokens) {
        if (item.tokenID == stateTokens.tokenID) {
          item.state = 1;
        }
      }
    }
    if (_page == 1 || popular == true) {
      _datas.clear();
    }
    HWToast.hiddenAllToast();
    _refreshController.loadComplete();
    _refreshController.refreshCompleted();
    setState(() {
      _datas.addAll(tokens);
    });
  }

  void _initNFTData(int page, {String? keywords}) async {
    HWToast.showLoading();
    final TRWallet trWallet =
        Provider.of<CurrentChooseWalletState>(context, listen: false)
            .currentWallet!;
    String? chainType = "";
    String walletID = trWallet.walletID!;
    _page = page;
    List<NFTModel> indexnfts = [];
    if (keywords == null || keywords.isEmpty) {
      indexnfts =
          await WalletServices.getNftList(pageNum: page, popularFlag: true);
    } else {
      if (await keywords.checkAddress(KCoinType.BSC) == true) {
        indexnfts = await WalletServices.getNftList(
            pageNum: page, tokenContractAddress: keywords);
      } else {
        indexnfts =
            await WalletServices.getNftList(pageNum: page, tokenName: keywords);
      }
    }

    KNetType netType = RequestURLS.getHost() == RequestURLS.testUrl
        ? KNetType.Testnet
        : KNetType.Mainnet;
    List<NFTModel> statesTokens =
        await NFTModel.findStateTokens(walletID, 1, netType.index);
    for (var item in indexnfts) {
      item.owner = walletID;
      item.kNetType = netType.index;
      item.tokenID = item.createTokenID(walletID);
      for (var stateTokens in statesTokens) {
        if (item.tokenID == stateTokens.tokenID) {
          item.state = 1;
        }
      }
    }
    if (_page == 1) {
      _datas.clear();
    }
    HWToast.hiddenAllToast();
    _refreshController.loadComplete();
    _refreshController.refreshCompleted();
    if (mounted) {
      setState(() {
        _datas.addAll(indexnfts);
      });
    }
  }

  Widget _topSearchView() {
    return Container(
      alignment: Alignment.center,
      height: 44.width,
      padding: EdgeInsets.symmetric(horizontal: 16.width),
      color: Colors.white,
      child: _searchTextField(),
    );
  }

  Widget _searchTextField() {
    return CustomTextField(
      controller: searchController,
      maxLines: 1,
      onChange: (value) {
        _initData(1, keywords: value);
      },
      style: TextStyle(
        color: ColorUtils.fromHex("#FF000000"),
        fontSize: 14.font,
        fontWeight: FontWeightUtils.regular,
      ),
      decoration: CustomTextField.getBorderLineDecoration(
          context: context,
          hintText: _homeTokenType == 0
              ? "tokensetting_searchtip".local()
              : "tokensetting_searchnfttip".local(),
          hintStyle: TextStyle(
            color: ColorUtils.fromHex("#807685A2"),
            fontSize: 14.font,
            fontWeight: FontWeightUtils.regular,
          ),
          focusedBorderColor: ColorUtils.blueColor,
          borderRadius: 22,
          contentPadding: EdgeInsets.symmetric(horizontal: 10.width),
          prefixIcon: LoadAssetsImage(
            "icons/icon_search.png",
            width: 20,
            height: 20,
          ),
          fillColor: ColorUtils.fromHex("#FFF6F8FF")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomPageView(
        title: CustomPageView.getTitle(
            title: _homeTokenType == 0
                ? "tokensetting_addassets".local()
                : "tokensetting_addnfts".local()),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.width),
            child: _homeTokenType == 0
                ? CustomPageView.getCustomIcon("icons/icon_tokensetting.png",
                    () {
                    Routers.push(context, TokenManager());
                  })
                : CustomPageView.getCustomIcon("icons/icon_add.png", () {
                    Routers.push(context, CustomAddNft());
                  }),
          ),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _topSearchView(),
            Expanded(
                child: CustomRefresher(
                    onRefresh: () {
                      _initData(1, keywords: searchController.text);
                    },
                    onLoading: () {
                      _initData(_page + 1, keywords: searchController.text);
                    },
                    child: _datas.length == 0
                        ? _homeTokenType == 0
                            ? EmptyDataPage(
                                emptyTip: "empaty_notoken".local(),
                                bottomBtnTitle: "empaty_addtoken".local(),
                                onTap: () {
                                  Routers.push(context, CustomAddTokens());
                                },
                              )
                            : EmptyDataPage()
                        : ListView.builder(
                            itemCount: _datas.length,
                            itemBuilder: (BuildContext context, int index) {
                              dynamic item = _datas[index];
                              return AssetsCell(
                                onTap: () {
                                  if (item is MCollectionTokens) {
                                    if (item.state == 1) {
                                      MCollectionTokens.deleteTokens([item]);
                                    } else {
                                      item.state = 1;
                                      MCollectionTokens.insertTokens([item]);
                                    }
                                  } else {
                                    if (item.state == 1) {
                                      item.state = 0;
                                      NFTModel.updateTokens(item);
                                    } else {
                                      item.state = 1;
                                      NFTModel.insertTokens([item]);
                                    }
                                  }

                                  searchController.clear();
                                  HWToast.showText(
                                      text: "dialog_modifyok".local());
                                  Future.delayed(const Duration(seconds: 2))
                                      .then((value) => {
                                            _initData(1),
                                          });
                                },
                                token: item,
                              );
                            },
                          ),
                    refreshController: _refreshController))
          ],
        ));
  }
}
