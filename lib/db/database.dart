import 'dart:async';
import 'package:beewallet/model/contacts/contact_address.dart';
import 'package:beewallet/model/dapps_record/dapps_record.dart';
import 'package:beewallet/model/nft/nft_model.dart';
import 'package:beewallet/model/token_price/tokenprice.dart';
import 'package:beewallet/model/tokens/collection_tokens.dart';
import 'package:beewallet/model/transrecord/trans_record.dart';
import 'package:beewallet/model/wallet/tr_wallet.dart';
import 'package:beewallet/model/wallet/tr_wallet_info.dart';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
part 'database.g.dart';

//flutter packages pub run build_runner build
// updateTokenData
// findTokensBySQL
// updateNFTSData
// findNFTBySQL
const int dbCurrentVersion = 3;

@Database(version: dbCurrentVersion, entities: [
  TRWallet,
  TRWalletInfo,
  ContactAddress,
  DAppRecordsDBModel,
  TokenPrice,
  MCollectionTokens,
  TransRecordModel,
  NFTModel
])
abstract class FlutterDatabase extends FloorDatabase {
  WalletDao get walletDao;
  WalletInfoDao get walletInfoDao;
  ContactAddressDao get addressDao;
  DAppRecordsDao get dAppRecordsDao;
  TokenPriceDao get tokenPriceDao;
  MCollectionTokenDao get tokensDao;
  TransRecordModelDao get transListDao;
  NFTModelDao get nftDao;
}
