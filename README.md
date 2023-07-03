# 合约说明

不同链的相同合约，控制了部署地址是一样的。

## DepositWalletFactory

用户入金钱包的工厂合约，每条链都会有一个该合约实例，通过该工厂合约为每个用户创建各自的钱包合约，由平台的后端程序调用。

`createWallet` 函数用于创建单个钱包合约，参数 `salt` 由链下的 `accountId` 进行哈希计算得出，参数 `account` 为所绑定的账户自己的钱包地址。创建钱包合约时，使用的是 `create2` 的方式，且每个账户的 `salt` 值是唯一的，可保证同一个账户在不同链所生成的钱包合约地址是一样的。

`batchCreateWallets` 函数用于批量创建多个账户的钱包合约。

`batchCollectTokens` 和 `batchCollectETH` 分别用于批量归集多个钱包合约的 tokens 和 ETH 到指定的 `treasury` 合约。requestId 在链上并没有使用，主要是为了方便链下进行对账。

在 Arbitrum，`treasury` 为 `MainTreasury` 合约地址，而在其他链则为 `HotTreasury` 合约地址。

## DepositWallet

每个用户在各条链都有各自的一个入金钱包合约，不同链的入金钱包合约是一样的，用户可通过往该合约地址直接转账来实现充值。而链下程序会扫块监听转账记录，监听到链上的转账记录后就会处理这笔充值。

用户还可以使用已绑定的钱包地址调用 `updateAccount` 函数来更换所绑定的钱包地址。

`collectETH` 和 `collectTokens` 用于将当前钱包合约里的资产归集到 `treasury` 合约。

## HotTreasury

头寸合约，类似 CEX 的热钱包，合约可升级。每条链都会部署一个合约实例。主要实现都在 `BaseTreasury` 合约里。

除了 Arbitrum，其他链的归集操作都会将用户的入金钱包合约里的资产归集到该合约里。

用户可使用所绑定的钱包地址直接调用该合约的 `depositETH` 和 `depositToken` 进行充值操作，链下通过监听充值事件进行处理。

该合约还定义了几个快速出金的接口，所有快速出金都只有 `operator` 才有权限执行，`operator` 会被设置为后端程序专门用于出金审核的地址。

## MainTreasury

锁仓合约，类似 CEX 的冷钱包，合约可升级，只在 Arbitrum 链上使用。

也继承自 `BaseTreasury` 合约，具备了和 `HotTreasury` 合约一样的所有功能。但在此基础上，扩展增加了 ZKP 相关的功能，主要包括更新 ZKP 相关状态变量，以及提供了普通提现和强制提现功能。

`updateZKP` 只能由 `Verifier` 合约触发，主要更新相关的状态变量。其中涉及几个概念：

- `BalanceRoot` 是某代币所有用户余额记录的 MerkleTreeRoot，不同代币有不同的 BalanceRoot
- `WithdrawRoot` 是某代币所有普通提现申请中的 MerkleTreeRoot，不同代币有不同的 WithdrawRoot
- `TotalBalance` 是某代币所有用户的总余额
- `TotalWithdraw` 是某代币所有普通提现中的总额

`generalWithdraw` 用于普通提现，对应于 `WithdrawRoot` 中的一个 leaf 提现记录，也是 `TotalWithdraw` 中的一部分。

`forceWithdraw` 用于强制提现，只能由账户绑定的地址来触发，且只能在 zkp 已经超过 `forceTimeWindow` 的时间都没有更新过的情况下才允许强制提现。
强制提现的资金是 `BalanceRoot` 里的资产记录，也是 `TotalBalance` 中的一部分。

## Verifier

ZKP 校验合约，和 `MainTreasury` 搭配使用，合约可升级，只在 Arbitrum 链上使用。

最核心的是 `submit` 函数，用于提交新的 zkp，进行一些 zkp 校验之后，会触发 `MainTreasury` 合约的 `updateZKP` 函数。

ZKP verify 使用的是 Groth16 算法。

## 合约升级

通过 `proxyAdmin` 的 `update` 函数实现合约升级。
