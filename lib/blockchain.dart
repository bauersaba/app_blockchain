import 'dart:convert';
import 'block.dart';
import 'transaction.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:hex/hex.dart';

class Blockchain {
  final List<Block> _chain;
  final List<Transaction> _currentTransactions;

  Blockchain(this._chain, this._currentTransactions) {
    newBlock(100, "1");
  }
  Block newBlock(int proof, String previousHash) {
    if (previousHash == null) {
      previousHash = hash(_chain.last);
    }

    var block = new Block(
      _chain.length,
      new DateTime.now().millisecondsSinceEpoch,
      _currentTransactions,
      proof,
      previousHash,
    );
    _currentTransactions.clear(); // = [] ?
    _chain.add(block);
    return block;
  }

  int newTransaction(String sender, String recipient, double amount) {
    _currentTransactions.add(new Transaction(sender, recipient, amount));
    return lastBlock.index + 1;
  }

  Block get lastBlock {
    return _chain.last;
  }

  String hash(Block block) {
    String blockStr = jsonEncode(block.toJson());
    var bytes = Utf8Encoder().convert(blockStr);
    var converted = crypto.sha256.convert(bytes).bytes;
    return HEX.encode(converted);
  }

  int proofOfWork(int lastProof) {
    var proof = 0;
    while (!validProof(lastProof, proof)) {
      proof++;
    }

    return proof;
  }

  bool validProof(int lastProof, int proof) {
    var guess = Utf8Encoder().convert("${lastProof}${proof}");
    //var guess = UTF8.encode("${lastProof}${proof}");
    var guessHash = crypto.sha256.convert(guess).bytes;
    return HEX.encode(guessHash).substring(0, 4) == "0000";
  }
}
