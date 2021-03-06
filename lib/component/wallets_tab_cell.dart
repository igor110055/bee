import 'package:beewallet/component/empty_data.dart';
import 'package:beewallet/component/nft_typecell.dart';
import 'package:beewallet/model/nft/nft_model.dart';
import 'package:beewallet/model/tokens/collection_tokens.dart';
import 'package:beewallet/pages/wallet/transfer/receive_page.dart';
import 'package:beewallet/pages/wallet/transfer/transfer_list.dart';
import 'package:beewallet/pages/wallet/wallets/nft_listdata.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';

import '../public.dart';

class WalletsTabList extends StatelessWidget {
  const WalletsTabList({Key? key}) : super(key: key);

  Widget _assetsCell(BuildContext context, MCollectionTokens collectToken,
      String currencySymbolStr, CurrentChooseWalletState provider, int index) {
    String imgname = collectToken.iconPath ?? "";
    String token = collectToken.token ?? "";
    String tokenPrice = "≈$currencySymbolStr" + collectToken.priceString;
    String balance = provider.currentWallet?.hiddenAssets == true
        ? "****"
        : collectToken.balanceString;
    String assets = provider.currentWallet?.hiddenAssets == true
        ? "****"
        : "$currencySymbolStr ${collectToken.assets}";

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        provider.updateTokenChoose(context, index, pushTransList: true);
      },
      child: SwipeActionCell(
        key: ObjectKey(collectToken),
        trailingActions: <SwipeAction>[
          SwipeAction(
              color: Colors.transparent,
              content: Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(bottom: 8.width),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LoadAssetsImage(
                      "icons/icon_cell_to.png",
                      width: 28,
                      height: 28,
                    ),
                    Text('transferetype_transfer'.local(),
                        style: TextStyle(
                            color: ColorUtils.redColor,
                            fontSize: 12.font,
                            fontWeight: FontWeightUtils.regular))
                  ],
                ),
              ),
              onTap: (handler) async {
                provider.updateTokenChoose(context, index, pushPayments: true);
              }),
        ],
        leadingActions: [
          SwipeAction(
              color: Colors.transparent,
              content: Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(bottom: 8.width),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LoadAssetsImage(
                      "icons/icon_cell_receive.png",
                      width: 28,
                      height: 28,
                    ),
                    Text('transferetype_receive'.local(),
                        style: TextStyle(
                            color: ColorUtils.fromHex("#FF00C99A"),
                            fontSize: 12.font,
                            fontWeight: FontWeightUtils.regular))
                  ],
                ),
              ),
              onTap: (handler) async {
                provider.walletcellTapReceive(context, index);
              }),
        ],
        child: Container(
          height: 68.width,
          margin: EdgeInsets.only(bottom: 8.width),
          padding: EdgeInsets.symmetric(horizontal: 12.width),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  LoadTokenAssetsImage(imgname, width: 36, height: 36),
                  8.rowWidget,
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        token,
                        style: TextStyle(
                          fontWeight: FontWeightUtils.medium,
                          fontSize: 16.font,
                          color: ColorUtils.fromHex("#FF000000"),
                        ),
                      ),
                      4.columnWidget,
                      Text(
                        tokenPrice,
                        style: TextStyle(
                          fontWeight: FontWeightUtils.regular,
                          fontSize: 11.font,
                          color: ColorUtils.fromHex("#66000000"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    balance,
                    style: TextStyle(
                      fontWeight: FontWeightUtils.bold,
                      fontSize: 18.font,
                      color: ColorUtils.fromHex("#FF000000"),
                    ),
                  ),
                  4.columnWidget,
                  Text(
                    assets,
                    style: TextStyle(
                      fontWeight: FontWeightUtils.regular,
                      fontSize: 11.font,
                      color: ColorUtils.fromHex("#66000000"),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _nftCell(BuildContext context, NFTModel nftInfo,
      String currencySymbolStr, CurrentChooseWalletState provider, int index) {
    String imgname = nftInfo.url ?? "";
    List nftId = [];
    if (nftInfo.nftId!.isNotEmpty) {
      nftId = nftInfo.nftId!.split(",");
    }
    int sum = nftId.length;
    String name = nftInfo.contractName ?? "";
    name = name.contractAddress();
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        provider.tapNFTInfo(context, nftInfo);
      },
      child: SwipeActionCell(
        key: ObjectKey(nftInfo),
        leadingActions: [
          SwipeAction(
              color: Colors.transparent,
              content: Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(bottom: 8.width),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LoadAssetsImage(
                      "icons/icon_add_unable.png",
                      width: 28,
                      height: 28,
                    ),
                    Text('homepage_receivenft'.local(),
                        style: TextStyle(
                            color: ColorUtils.fromHex("#FF00C99A"),
                            fontSize: 12.font,
                            fontWeight: FontWeightUtils.regular))
                  ],
                ),
              ),
              onTap: (handler) async {
                provider.walletcellTapReceive(context, index, tapNFT: true);
              }),
        ],
        child: NFTTypeCell(nftInfo: nftInfo),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.width),
      child: Consumer<CurrentChooseWalletState>(
        builder: (_, provider, child) {
          int homeTokenType = provider.homeTokenType;
          List<dynamic> datas =
              homeTokenType == 0 ? provider.tokens : provider.nftContracts;
          return datas.isEmpty
              ? EmptyDataPage()
              : ListView.builder(
                  itemCount: datas.length,
                  itemBuilder: (BuildContext context, int index) {
                    final currencySymbolStr = provider.currencySymbolStr;
                    dynamic collectToken = datas[index];
                    return homeTokenType == 0
                        ? _assetsCell(context, collectToken, currencySymbolStr,
                            provider, index)
                        : _nftCell(context, collectToken, currencySymbolStr,
                            provider, index);
                  },
                );
        },
      ),
    );
  }
}
