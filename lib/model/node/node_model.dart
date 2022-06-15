// import 'dart:html';
import 'package:beewallet/utils/sp_manager.dart';
import 'package:floor/floor.dart';
import '../../public.dart';

const String tableName = "nodes_table";

@Entity(tableName: tableName, primaryKeys: ["content", "chainType"])
class NodeModel {
  String? content;
  int? chainType;
  bool? isChoose;
  int? netType; //类型
  int? chainID;
  String? blockExplorerURL;
  String? blockExplorerURLAPI;

  NodeModel(
      {this.content,
      this.chainType,
      this.isChoose,
      this.netType,
      this.chainID,
      this.blockExplorerURL,
      this.blockExplorerURLAPI}); //ID

  static void configNodeData() async {}

  static String getBlockExploreApi(KCoinType kCoinType) {
    String host = "";
    KNetType netType = SPManager.getNetType();
    if (kCoinType == KCoinType.BSC) {
      host = "https://api.bscscan.com";
      if (KNetType.Testnet == netType) {
        host = "https://api-testnet.bscscan.com";
      }
    }

    return host;
  }

  static NodeModel queryNodeByChainType(int chainType) {
    KNetType netType = SPManager.getNetType();
    NodeModel node = NodeModel();
    node.netType = netType.index;
    node.chainType = chainType;
    if (chainType == KCoinType.BSC.index) {
      if (KNetType.Mainnet == netType) {
        node.chainID = 56;
        node.content = "https://bsc-dataseed.binance.org/";
      } else {
        node.chainID = 97;
        // node.content = "https://data-seed-prebsc-1-s1.binance.org:8545";
        node.content = "https://data-seed-prebsc-2-s3.binance.org:8545";
      }
    }

    assert(node.content != null,
        "nodechainType " + chainType.geCoinType().coinTypeString() + "没有节点信息");
    return node;
  }

  // static Future<List<NodeModel>?> queryNodeByIsChoose(bool isChoose) async {
  //   try {
  //     FlutterDatabase? database = await (BaseModel.getDataBae());
  //     return database?.nodeDao.queryNodeByIsChoose(isChoose);
  //   } catch (e) {
  //     LogUtil.v("失败" + e.toString());
  //     return null;
  //   }
  // }

  // static Future<List<NodeModel>?> queryNodeByContent(String content) async {
  //   try {
  //     FlutterDatabase? database = await (BaseModel.getDataBae());
  //     return database?.nodeDao.queryNodeByContent(content);
  //   } catch (e) {
  //     LogUtil.v("失败" + e.toString());
  //     return null;
  //   }
  // }

  // static Future<List<NodeModel>?> queryNodeByIsDefaultAndChainType(
  //     bool isDefault, int chainType) async {
  //   try {
  //     FlutterDatabase? database = await (BaseModel.getDataBae());
  //     return database?.nodeDao
  //         .queryNodeByIsDefaultAndChainType(isDefault, chainType);
  //   } catch (e) {
  //     LogUtil.v("失败" + e.toString());
  //     return null;
  //   }
  // }

  // static Future<List<NodeModel>?> queryNodeByContentAndChainType(
  //     String content, int chainType) async {
  //   try {
  //     FlutterDatabase? database = await (BaseModel.getDataBae());
  //     return database?.nodeDao
  //         .queryNodeByContentAndChainType(content, chainType);
  //   } catch (e) {
  //     LogUtil.v("失败" + e.toString());
  //     return null;
  //   }
  // }

  // static Future<bool> updateNode(NodeModel model) async {
  //   try {
  //     FlutterDatabase? database = await (BaseModel.getDataBae());
  //     database?.nodeDao.updateNode(model);
  //     return true;
  //   } catch (e) {
  //     LogUtil.v("失败" + e.toString());
  //     return false;
  //   }
  // }

  // static Future<bool> updateNodes(List<NodeModel> models) async {
  //   try {
  //     FlutterDatabase? database = await (BaseModel.getDataBae());
  //     database?.nodeDao.updateNodes(models);
  //     return true;
  //   } catch (e) {
  //     LogUtil.v("失败" + e.toString());
  //     return false;
  //   }
  // }
}

@dao
abstract class NodeDao {
  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertNodeDatas(List<NodeModel> list);

  @Query(
      'SELECT * FROM $tableName WHERE chainType = :chainType and isChoose = :isChoose')
  Future<List<NodeModel>> queryNodeByChainType(int chainType, bool isChoose);

  @update
  Future<void> updateNodes(List<NodeModel> models);
}
