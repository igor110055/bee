import 'package:beewallet/component/empty_data.dart';
import 'package:beewallet/model/client/sign_client.dart';
import 'package:beewallet/model/nft/nft_model.dart';
import 'package:beewallet/model/nft/nftinfo.dart';
import 'package:beewallet/net/chain_services.dart';
import 'package:beewallet/net/wallet_services.dart';
import 'package:beewallet/pages/wallet/transfer/transfer_payment.dart';
import 'package:beewallet/utils/custom_toast.dart';

import '../../../public.dart';

class NFTInfo extends StatefulWidget {
  NFTInfo({Key? key, required this.nftModel, required this.tokenid})
      : super(key: key);
  final NFTModel nftModel;
  final String tokenid;

  @override
  State<NFTInfo> createState() => _NFTInfoState();
}

class _NFTInfoState extends State<NFTInfo> {
  NFTIPFSInfo? _infos;
  @override
  void initState() {
    super.initState();
    _getNftInfo();
  }

  void _getNftInfo() async {
    HWToast.showLoading();
    String contractAddress = widget.nftModel.contractAddress ?? "";
    String chainTypeName = widget.nftModel.chainTypeName ?? "";
    KCoinType coinType = chainTypeName.chainTypeGetCoinType()!;
    Map params =
        SignTransactionClient.get721TokenURI(contractAddress, widget.tokenid);
    NFTIPFSInfo? result =
        await ChainServices.requestNFTInfo(coinType: coinType, qparams: params);

    HWToast.hiddenAllToast();
    if (result == null) {
      return;
    }
    if (mounted) {
      setState(() {
        _infos = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPageView(
      title: CustomPageView.getTitle(title: "homepage_nftinfo".local()),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  LoadTokenAssetsImage(
                    _infos?.imageBase64 == null
                        ? WalletServices.getIpfsImageUrl(_infos?.image ?? "")
                        : _infos?.imageBase64 ?? '',
                    isNft: true,
                  ),
                  Container(
                    alignment: Alignment.topLeft,
                    padding: EdgeInsets.only(
                        left: 16.width,
                        right: 16.width,
                        top: 16.width,
                        bottom: 16.width),
                    child: Text(
                      _infos?.description ?? "",
                      style: TextStyle(
                        fontSize: 14.font,
                        color: Color.fromARGB(255, 183, 183, 183),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          NextButton(
            bgc: ColorUtils.blueColor,
            textStyle: TextStyle(
              fontSize: 16.font,
              fontWeight: FontWeightUtils.medium,
              color: Colors.white,
            ),
            margin: EdgeInsets.only(
                left: 16.width, right: 16.width, bottom: 16.width),
            onPressed: () {
              Routers.push(context, TransferPayment(nftInfos: _infos));
            },
            title: "homepage_send".local(),
          ),
        ],
      ),
    );
  }
}
