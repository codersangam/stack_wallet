/* 
 * This file is part of Stack Wallet.
 * 
 * Copyright (c) 2023 Cypher Stack
 * All Rights Reserved.
 * The code is distributed under GPLv3 license, see LICENSE file for details.
 * Generated by Cypher Stack on 2023-05-26
 *
 */

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stackwallet/providers/db/main_db_provider.dart';
import 'package:stackwallet/providers/global/secure_store_provider.dart';
import 'package:stackwallet/services/coins/ethereum/ethereum_wallet.dart';
import 'package:stackwallet/services/coins/manager.dart';
import 'package:stackwallet/services/ethereum/ethereum_token_service.dart';
import 'package:stackwallet/services/transaction_notification_tracker.dart';
import 'package:stackwallet/utilities/logger.dart';

class ContractWalletId implements Equatable {
  final String walletId;
  final String tokenContractAddress;

  ContractWalletId({
    required this.walletId,
    required this.tokenContractAddress,
  });

  @override
  List<Object?> get props => [walletId, tokenContractAddress];

  @override
  bool? get stringify => true;
}

/// provide the wallet for a given wallet id
final walletProvider =
    ChangeNotifierProvider.family<Manager?, String>((ref, arg) => null);

/// provide the token wallet given a contract address and eth wallet id
final tokenWalletProvider =
    ChangeNotifierProvider.family<EthTokenWallet?, ContractWalletId>(
        (ref, arg) {
  final ethWallet =
      ref.watch(walletProvider(arg.walletId).select((value) => value?.wallet))
          as EthereumWallet?;
  final contract =
      ref.read(mainDBProvider).getEthContractSync(arg.tokenContractAddress);

  if (ethWallet == null || contract == null) {
    Logging.instance.log(
      "Attempted to access a token wallet with walletId=${arg.walletId} where"
      " contractAddress=${arg.tokenContractAddress}",
      level: LogLevel.Warning,
    );
    return null;
  }

  final secureStore = ref.watch(secureStoreProvider);

  return EthTokenWallet(
    token: contract,
    ethWallet: ethWallet,
    secureStore: secureStore,
    tracker: TransactionNotificationTracker(
      walletId: arg.walletId,
    ),
  );
});
