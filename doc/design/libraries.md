# Libraries

| Name                     | Description |
|--------------------------|-------------|
| *libnovacoin_cli*         | RPC client functionality used by *novacoin-cli* executable |
| *libnovacoin_common*      | Home for common functionality shared by different executables and libraries. Similar to *libnovacoin_util*, but higher-level (see [Dependencies](#dependencies)). |
| *libnovacoin_consensus*   | Consensus functionality used by *libnovacoin_node* and *libnovacoin_wallet*. |
| *libnovacoin_crypto*      | Hardware-optimized functions for data encryption, hashing, message authentication, and key derivation. |
| *libnovacoin_kernel*      | Consensus engine and support library used for validation by *libnovacoin_node*. |
| *libnovacoinqt*           | GUI functionality used by *novacoin-qt* and *novacoin-gui* executables. |
| *libnovacoin_ipc*         | IPC functionality used by *novacoin-node*, *novacoin-wallet*, *novacoin-gui* executables to communicate when [`-DWITH_MULTIPROCESS=ON`](multiprocess.md) is used. |
| *libnovacoin_node*        | P2P and RPC server functionality used by *novacoind* and *novacoin-qt* executables. |
| *libnovacoin_util*        | Home for common functionality shared by different executables and libraries. Similar to *libnovacoin_common*, but lower-level (see [Dependencies](#dependencies)). |
| *libnovacoin_wallet*      | Wallet functionality used by *novacoind* and *novacoin-wallet* executables. |
| *libnovacoin_wallet_tool* | Lower-level wallet functionality used by *novacoin-wallet* executable. |
| *libnovacoin_zmq*         | [ZeroMQ](../zmq.md) functionality used by *novacoind* and *novacoin-qt* executables. |

## Conventions

- Most libraries are internal libraries and have APIs which are completely unstable! There are few or no restrictions on backwards compatibility or rules about external dependencies. An exception is *libnovacoin_kernel*, which, at some future point, will have a documented external interface.

- Generally each library should have a corresponding source directory and namespace. Source code organization is a work in progress, so it is true that some namespaces are applied inconsistently, and if you look at [`add_library(novacoin_* ...)`](../../src/CMakeLists.txt) lists you can see that many libraries pull in files from outside their source directory. But when working with libraries, it is good to follow a consistent pattern like:

  - *libnovacoin_node* code lives in `src/node/` in the `node::` namespace
  - *libnovacoin_wallet* code lives in `src/wallet/` in the `wallet::` namespace
  - *libnovacoin_ipc* code lives in `src/ipc/` in the `ipc::` namespace
  - *libnovacoin_util* code lives in `src/util/` in the `util::` namespace
  - *libnovacoin_consensus* code lives in `src/consensus/` in the `Consensus::` namespace

## Dependencies

- Libraries should minimize what other libraries they depend on, and only reference symbols following the arrows shown in the dependency graph below:

<table><tr><td>

```mermaid

%%{ init : { "flowchart" : { "curve" : "basis" }}}%%

graph TD;

novacoin-cli[novacoin-cli]-->libnovacoin_cli;

novacoind[novacoind]-->libnovacoin_node;
novacoind[novacoind]-->libnovacoin_wallet;

novacoin-qt[novacoin-qt]-->libnovacoin_node;
novacoin-qt[novacoin-qt]-->libnovacoinqt;
novacoin-qt[novacoin-qt]-->libnovacoin_wallet;

novacoin-wallet[novacoin-wallet]-->libnovacoin_wallet;
novacoin-wallet[novacoin-wallet]-->libnovacoin_wallet_tool;

libnovacoin_cli-->libnovacoin_util;
libnovacoin_cli-->libnovacoin_common;

libnovacoin_consensus-->libnovacoin_crypto;

libnovacoin_common-->libnovacoin_consensus;
libnovacoin_common-->libnovacoin_crypto;
libnovacoin_common-->libnovacoin_util;

libnovacoin_kernel-->libnovacoin_consensus;
libnovacoin_kernel-->libnovacoin_crypto;
libnovacoin_kernel-->libnovacoin_util;

libnovacoin_node-->libnovacoin_consensus;
libnovacoin_node-->libnovacoin_crypto;
libnovacoin_node-->libnovacoin_kernel;
libnovacoin_node-->libnovacoin_common;
libnovacoin_node-->libnovacoin_util;

libnovacoinqt-->libnovacoin_common;
libnovacoinqt-->libnovacoin_util;

libnovacoin_util-->libnovacoin_crypto;

libnovacoin_wallet-->libnovacoin_common;
libnovacoin_wallet-->libnovacoin_crypto;
libnovacoin_wallet-->libnovacoin_util;

libnovacoin_wallet_tool-->libnovacoin_wallet;
libnovacoin_wallet_tool-->libnovacoin_util;

classDef bold stroke-width:2px, font-weight:bold, font-size: smaller;
class novacoin-qt,novacoind,novacoin-cli,novacoin-wallet bold
```
</td></tr><tr><td>

**Dependency graph**. Arrows show linker symbol dependencies. *Crypto* lib depends on nothing. *Util* lib is depended on by everything. *Kernel* lib depends only on consensus, crypto, and util.

</td></tr></table>

- The graph shows what _linker symbols_ (functions and variables) from each library other libraries can call and reference directly, but it is not a call graph. For example, there is no arrow connecting *libnovacoin_wallet* and *libnovacoin_node* libraries, because these libraries are intended to be modular and not depend on each other's internal implementation details. But wallet code is still able to call node code indirectly through the `interfaces::Chain` abstract class in [`interfaces/chain.h`](../../src/interfaces/chain.h) and node code calls wallet code through the `interfaces::ChainClient` and `interfaces::Chain::Notifications` abstract classes in the same file. In general, defining abstract classes in [`src/interfaces/`](../../src/interfaces/) can be a convenient way of avoiding unwanted direct dependencies or circular dependencies between libraries.

- *libnovacoin_crypto* should be a standalone dependency that any library can depend on, and it should not depend on any other libraries itself.

- *libnovacoin_consensus* should only depend on *libnovacoin_crypto*, and all other libraries besides *libnovacoin_crypto* should be allowed to depend on it.

- *libnovacoin_util* should be a standalone dependency that any library can depend on, and it should not depend on other libraries except *libnovacoin_crypto*. It provides basic utilities that fill in gaps in the C++ standard library and provide lightweight abstractions over platform-specific features. Since the util library is distributed with the kernel and is usable by kernel applications, it shouldn't contain functions that external code shouldn't call, like higher level code targeted at the node or wallet. (*libnovacoin_common* is a better place for higher level code, or code that is meant to be used by internal applications only.)

- *libnovacoin_common* is a home for miscellaneous shared code used by different Bitcoin Core applications. It should not depend on anything other than *libnovacoin_util*, *libnovacoin_consensus*, and *libnovacoin_crypto*.

- *libnovacoin_kernel* should only depend on *libnovacoin_util*, *libnovacoin_consensus*, and *libnovacoin_crypto*.

- The only thing that should depend on *libnovacoin_kernel* internally should be *libnovacoin_node*. GUI and wallet libraries *libnovacoinqt* and *libnovacoin_wallet* in particular should not depend on *libnovacoin_kernel* and the unneeded functionality it would pull in, like block validation. To the extent that GUI and wallet code need scripting and signing functionality, they should be get able it from *libnovacoin_consensus*, *libnovacoin_common*, *libnovacoin_crypto*, and *libnovacoin_util*, instead of *libnovacoin_kernel*.

- GUI, node, and wallet code internal implementations should all be independent of each other, and the *libnovacoinqt*, *libnovacoin_node*, *libnovacoin_wallet* libraries should never reference each other's symbols. They should only call each other through [`src/interfaces/`](../../src/interfaces/) abstract interfaces.

## Work in progress

- Validation code is moving from *libnovacoin_node* to *libnovacoin_kernel* as part of [The libnovacoinkernel Project #27587](https://github.com/novacoin/novacoin/issues/27587)
