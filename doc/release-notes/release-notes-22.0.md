22.0 Release Notes
==================

Bitcoin Core version 22.0 is now available from:

  <https://novacoincore.org/bin/novacoin-core-22.0/>

This release includes new features, various bug fixes and performance
improvements, as well as updated translations.

Please report bugs using the issue tracker at GitHub:

  <https://github.com/novacoin/novacoin/issues>

To receive security and update notifications, please subscribe to:

  <https://novacoincore.org/en/list/announcements/join/>

How to Upgrade
==============

If you are running an older version, shut it down. Wait until it has completely
shut down (which might take a few minutes in some cases), then run the
installer (on Windows) or just copy over `/Applications/Bitcoin-Qt` (on Mac)
or `novacoind`/`novacoin-qt` (on Linux).

Upgrading directly from a version of Bitcoin Core that has reached its EOL is
possible, but it might take some time if the data directory needs to be migrated. Old
wallet versions of Bitcoin Core are generally supported.

Compatibility
==============

Bitcoin Core is supported and extensively tested on operating systems
using the Linux kernel, macOS 10.14+, and Windows 7 and newer.  Bitcoin
Core should also work on most other Unix-like systems but is not as
frequently tested on them.  It is not recommended to use Bitcoin Core on
unsupported systems.

From Bitcoin Core 22.0 onwards, macOS versions earlier than 10.14 are no longer supported.

Notable changes
===============

P2P and network changes
-----------------------
- Added support for running Bitcoin Core as an
  [I2P (Invisible Internet Project)](https://en.wikipedia.org/wiki/I2P) service
  and connect to such services. See [i2p.md](https://github.com/novacoin/novacoin/blob/22.x/doc/i2p.md) for details. (#20685)
- This release removes support for Tor version 2 hidden services in favor of Tor
  v3 only, as the Tor network [dropped support for Tor
  v2](https://blog.torproject.org/v2-deprecation-timeline) with the release of
  Tor version 0.4.6.  Henceforth, Bitcoin Core ignores Tor v2 addresses; it
  neither rumors them over the network to other peers, nor stores them in memory
  or to `peers.dat`.  (#22050)

- Added NAT-PMP port mapping support via
  [`libnatpmp`](https://miniupnp.tuxfamily.org/libnatpmp.html). (#18077)

New and Updated RPCs
--------------------

- Due to [BIP 350](https://github.com/novacoin/bips/blob/master/bip-0350.mediawiki)
  being implemented, behavior for all RPCs that accept addresses is changed when
  a native witness version 1 (or higher) is passed. These now require a Bech32m
  encoding instead of a Bech32 one, and Bech32m encoding will be used for such
  addresses in RPC output as well. No version 1 addresses should be created
  for mainnet until consensus rules are adopted that give them meaning
  (as will happen through [BIP 341](https://github.com/novacoin/bips/blob/master/bip-0341.mediawiki)).
  Once that happens, Bech32m is expected to be used for them, so this shouldn't
  affect any production systems, but may be observed on other networks where such
  addresses already have meaning (like signet). (#20861)

- The `getpeerinfo` RPC returns two new boolean fields, `bip152_hb_to` and
  `bip152_hb_from`, that respectively indicate whether we selected a peer to be
  in compact blocks high-bandwidth mode or whether a peer selected us as a
  compact blocks high-bandwidth peer. High-bandwidth peers send new block
  announcements via a `cmpctblock` message rather than the usual inv/headers
  announcements. See BIP 152 for more details. (#19776)

- `getpeerinfo` no longer returns the following fields: `addnode`, `banscore`,
  and `whitelisted`, which were previously deprecated in 0.21. Instead of
  `addnode`, the `connection_type` field returns manual. Instead of
  `whitelisted`, the `permissions` field indicates if the peer has special
  privileges. The `banscore` field has simply been removed. (#20755)

- The following RPCs:  `gettxout`, `getrawtransaction`, `decoderawtransaction`,
  `decodescript`, `gettransaction`, and REST endpoints: `/rest/tx`,
  `/rest/getutxos`, `/rest/block` deprecated the following fields (which are no
  longer returned in the responses by default): `addresses`, `reqSigs`.
  The `-deprecatedrpc=addresses` flag must be passed for these fields to be
  included in the RPC response. This flag/option will be available only for this major release, after which
  the deprecation will be removed entirely. Note that these fields are attributes of
  the `scriptPubKey` object returned in the RPC response. However, in the response
  of `decodescript` these fields are top-level attributes, and included again as attributes
  of the `scriptPubKey` object. (#20286)

- When creating a hex-encoded novacoin transaction using the `novacoin-tx` utility
  with the `-json` option set, the following fields: `addresses`, `reqSigs` are no longer
  returned in the tx output of the response. (#20286)

- The `listbanned` RPC now returns two new numeric fields: `ban_duration` and `time_remaining`.
  Respectively, these new fields indicate the duration of a ban and the time remaining until a ban expires,
  both in seconds. Additionally, the `ban_created` field is repositioned to come before `banned_until`. (#21602)

- The `setban` RPC can ban onion addresses again. This fixes a regression introduced in version 0.21.0. (#20852)

- The `getnodeaddresses` RPC now returns a "network" field indicating the
  network type (ipv4, ipv6, onion, or i2p) for each address.  (#21594)

- `getnodeaddresses` now also accepts a "network" argument (ipv4, ipv6, onion,
  or i2p) to return only addresses of the specified network.  (#21843)

- The `testmempoolaccept` RPC now accepts multiple transactions (still experimental at the moment,
  API may be unstable). This is intended for testing transaction packages with dependency
  relationships; it is not recommended for batch-validating independent transactions. In addition to
  mempool policy, package policies apply: the list cannot contain more than 25 transactions or have a
  total size exceeding 101K virtual bytes, and cannot conflict with (spend the same inputs as) each other or
  the mempool, even if it would be a valid BIP125 replace-by-fee. There are some known limitations to
  the accuracy of the test accept: it's possible for `testmempoolaccept` to return "allowed"=True for a
  group of transactions, but "too-long-mempool-chain" if they are actually submitted. (#20833)

- `addmultisigaddress` and `createmultisig` now support up to 20 keys for
  Segwit addresses. (#20867)

Changes to Wallet or GUI related RPCs can be found in the GUI or Wallet section below.

Build System
------------

- Release binaries are now produced using the new `guix`-based build system.
  The [/doc/release-process.md](/doc/release-process.md) document has been updated accordingly.

Files
-----

- The list of banned hosts and networks (via `setban` RPC) is now saved on disk
  in JSON format in `banlist.json` instead of `banlist.dat`. `banlist.dat` is
  only read on startup if `banlist.json` is not present. Changes are only written to the new
  `banlist.json`. A future version of Bitcoin Core may completely ignore
  `banlist.dat`. (#20966)

New settings
------------

- The `-natpmp` option has been added to use NAT-PMP to map the listening port.
  If both UPnP and NAT-PMP are enabled, a successful allocation from UPnP
  prevails over one from NAT-PMP. (#18077)

Updated settings
----------------

Changes to Wallet or GUI related settings can be found in the GUI or Wallet section below.

- Passing an invalid `-rpcauth` argument now cause novacoind to fail to start.  (#20461)

Tools and Utilities
-------------------

- A new CLI `-addrinfo` command returns the number of addresses known to the
  node per network type (including Tor v2 versus v3) and total. This can be
  useful to see if the node knows enough addresses in a network to use options
  like `-onlynet=<network>` or to upgrade to this release of Bitcoin Core 22.0
  that supports Tor v3 only.  (#21595)

- A new `-rpcwaittimeout` argument to `novacoin-cli` sets the timeout
  in seconds to use with `-rpcwait`. If the timeout expires,
  `novacoin-cli` will report a failure. (#21056)

Wallet
------

- External signers such as hardware wallets can now be used through the new RPC methods `enumeratesigners` and `displayaddress`. Support is also added to the `send` RPC call. This feature is experimental. See [external-signer.md](https://github.com/novacoin/novacoin/blob/22.x/doc/external-signer.md) for details. (#16546)

- A new `listdescriptors` RPC is available to inspect the contents of descriptor-enabled wallets.
  The RPC returns public versions of all imported descriptors, including their timestamp and flags.
  For ranged descriptors, it also returns the range boundaries and the next index to generate addresses from. (#20226)

- The `bumpfee` RPC is not available with wallets that have private keys
  disabled. `psbtbumpfee` can be used instead. (#20891)

- The `fundrawtransaction`, `send` and `walletcreatefundedpsbt` RPCs now support an `include_unsafe` option
  that when `true` allows using unsafe inputs to fund the transaction.
  Note that the resulting transaction may become invalid if one of the unsafe inputs disappears.
  If that happens, the transaction must be funded with different inputs and republished. (#21359)

- We now support up to 20 keys in `multi()` and `sortedmulti()` descriptors
  under `wsh()`. (#20867)

- Taproot descriptors can be imported into the wallet only after activation has occurred on the network (e.g. mainnet, testnet, signet) in use. See [descriptors.md](https://github.com/novacoin/novacoin/blob/22.x/doc/descriptors.md) for supported descriptors.

GUI changes
-----------

- External signers such as hardware wallets can now be used. These require an external tool such as [HWI](https://github.com/novacoin-core/HWI) to be installed and configured under Options -> Wallet. When creating a new wallet a new option "External signer" will appear in the dialog. If the device is detected, its name is suggested as the wallet name. The watch-only keys are then automatically imported. Receive addresses can be verified on the device. The send dialog will automatically use the connected device. This feature is experimental and the UI may freeze for a few seconds when performing these actions.

Low-level changes
=================

RPC
---

- The RPC server can process a limited number of simultaneous RPC requests.
  Previously, if this limit was exceeded, the RPC server would respond with
  [status code 500 (`HTTP_INTERNAL_SERVER_ERROR`)](https://en.wikipedia.org/wiki/List_of_HTTP_status_codes#5xx_server_errors).
  Now it returns status code 503 (`HTTP_SERVICE_UNAVAILABLE`). (#18335)

- Error codes have been updated to be more accurate for the following error cases (#18466):
  - `signmessage` now returns RPC_INVALID_ADDRESS_OR_KEY (-5) if the
    passed address is invalid. Previously returned RPC_TYPE_ERROR (-3).
  - `verifymessage` now returns RPC_INVALID_ADDRESS_OR_KEY (-5) if the
    passed address is invalid. Previously returned RPC_TYPE_ERROR (-3).
  - `verifymessage` now returns RPC_TYPE_ERROR (-3) if the passed signature
    is malformed. Previously returned RPC_INVALID_ADDRESS_OR_KEY (-5).

Tests
-----

22.0 change log
===============

A detailed list of changes in this version follows. To keep the list to a manageable length, small refactors and typo fixes are not included, and similar changes are sometimes condensed into one line.

### Consensus
- novacoin/novacoin#19438 Introduce deploymentstatus (ajtowns)
- novacoin/novacoin#20207 Follow-up extra comments on taproot code and tests (sipa)
- novacoin/novacoin#21330 Deal with missing data in signature hashes more consistently (sipa)

### Policy
- novacoin/novacoin#18766 Disable fee estimation in blocksonly mode (by removing the fee estimates global) (darosior)
- novacoin/novacoin#20497 Add `MAX_STANDARD_SCRIPTSIG_SIZE` to policy (sanket1729)
- novacoin/novacoin#20611 Move `TX_MAX_STANDARD_VERSION` to policy (MarcoFalke)

### Mining
- novacoin/novacoin#19937, novacoin/novacoin#20923 Signet mining utility (ajtowns)

### Block and transaction handling
- novacoin/novacoin#14501 Fix possible data race when committing block files (luke-jr)
- novacoin/novacoin#15946 Allow maintaining the blockfilterindex when using prune (jonasschnelli)
- novacoin/novacoin#18710 Add local thread pool to CCheckQueue (hebasto)
- novacoin/novacoin#19521 Coinstats Index (fjahr)
- novacoin/novacoin#19806 UTXO snapshot activation (jamesob)
- novacoin/novacoin#19905 Remove dead CheckForkWarningConditionsOnNewFork (MarcoFalke)
- novacoin/novacoin#19935 Move SaltedHashers to separate file and add some new ones (achow101)
- novacoin/novacoin#20054 Remove confusing and useless "unexpected version" warning (MarcoFalke)
- novacoin/novacoin#20519 Handle rename failure in `DumpMempool(…)` by using the `RenameOver(…)` return value (practicalswift)
- novacoin/novacoin#20749, novacoin/novacoin#20750, novacoin/novacoin#21055, novacoin/novacoin#21270, novacoin/novacoin#21525, novacoin/novacoin#21391, novacoin/novacoin#21767, novacoin/novacoin#21866 Prune `g_chainman` usage (dongcarl)
- novacoin/novacoin#20833 rpc/validation: enable packages through testmempoolaccept (glozow)
- novacoin/novacoin#20834 Locks and docs in ATMP and CheckInputsFromMempoolAndCache (glozow)
- novacoin/novacoin#20854 Remove unnecessary try-block (amitiuttarwar)
- novacoin/novacoin#20868 Remove redundant check on pindex (jarolrod)
- novacoin/novacoin#20921 Don't try to invalidate genesis block in CChainState::InvalidateBlock (theStack)
- novacoin/novacoin#20972 Locks: Annotate CTxMemPool::check to require `cs_main` (dongcarl)
- novacoin/novacoin#21009 Remove RewindBlockIndex logic (dhruv)
- novacoin/novacoin#21025 Guard chainman chainstates with `cs_main` (dongcarl)
- novacoin/novacoin#21202 Two small clang lock annotation improvements (amitiuttarwar)
- novacoin/novacoin#21523 Run VerifyDB on all chainstates (jamesob)
- novacoin/novacoin#21573 Update libsecp256k1 subtree to latest master (sipa)
- novacoin/novacoin#21582, novacoin/novacoin#21584, novacoin/novacoin#21585 Fix assumeutxo crashes (MarcoFalke)
- novacoin/novacoin#21681 Fix ActivateSnapshot to use hardcoded nChainTx (jamesob)
- novacoin/novacoin#21796 index: Avoid async shutdown on init error (MarcoFalke)
- novacoin/novacoin#21946 Document and test lack of inherited signaling in RBF policy (ariard)
- novacoin/novacoin#22084 Package testmempoolaccept followups (glozow)
- novacoin/novacoin#22102 Remove `Warning:` from warning message printed for unknown new rules (prayank23)
- novacoin/novacoin#22112 Force port 0 in I2P (vasild)
- novacoin/novacoin#22135 CRegTestParams: Use `args` instead of `gArgs` (kiminuo)
- novacoin/novacoin#22146 Reject invalid coin height and output index when loading assumeutxo (MarcoFalke)
- novacoin/novacoin#22253 Distinguish between same tx and same-nonwitness-data tx in mempool (glozow)
- novacoin/novacoin#22261 Two small fixes to node broadcast logic (jnewbery)
- novacoin/novacoin#22415 Make `m_mempool` optional in CChainState (jamesob)
- novacoin/novacoin#22499 Update assumed chain params (sriramdvt)
- novacoin/novacoin#22589 net, doc: update I2P hardcoded seeds and docs for 22.0 (jonatack)

### P2P protocol and network code
- novacoin/novacoin#18077 Add NAT-PMP port forwarding support (hebasto)
- novacoin/novacoin#18722 addrman: improve performance by using more suitable containers (vasild)
- novacoin/novacoin#18819 Replace `cs_feeFilter` with simple std::atomic (MarcoFalke)
- novacoin/novacoin#19203 Add regression fuzz harness for CVE-2017-18350. Add FuzzedSocket (practicalswift)
- novacoin/novacoin#19288 fuzz: Add fuzzing harness for TorController (practicalswift)
- novacoin/novacoin#19415 Make DNS lookup mockable, add fuzzing harness (practicalswift)
- novacoin/novacoin#19509 Per-Peer Message Capture (troygiorshev)
- novacoin/novacoin#19763 Don't try to relay to the address' originator (vasild)
- novacoin/novacoin#19771 Replace enum CConnMan::NumConnections with enum class ConnectionDirection (luke-jr)
- novacoin/novacoin#19776 net, rpc: expose high bandwidth mode state via getpeerinfo (theStack)
- novacoin/novacoin#19832 Put disconnecting logs into BCLog::NET category (hebasto)
- novacoin/novacoin#19858 Periodically make block-relay connections and sync headers (sdaftuar)
- novacoin/novacoin#19884 No delay in adding fixed seeds if -dnsseed=0 and peers.dat is empty (dhruv)
- novacoin/novacoin#20079 Treat handshake misbehavior like unknown message (MarcoFalke)
- novacoin/novacoin#20138 Assume that SetCommonVersion is called at most once per peer (MarcoFalke)
- novacoin/novacoin#20162 p2p: declare Announcement::m_state as uint8_t, add getter/setter (jonatack)
- novacoin/novacoin#20197 Protect onions in AttemptToEvictConnection(), add eviction protection test coverage (jonatack)
- novacoin/novacoin#20210 assert `CNode::m_inbound_onion` is inbound in ctor, add getter, unit tests (jonatack)
- novacoin/novacoin#20228 addrman: Make addrman a top-level component (jnewbery)
- novacoin/novacoin#20234 Don't bind on 0.0.0.0 if binds are restricted to Tor (vasild)
- novacoin/novacoin#20477 Add unit testing of node eviction logic (practicalswift)
- novacoin/novacoin#20516 Well-defined CAddress disk serialization, and addrv2 anchors.dat (sipa)
- novacoin/novacoin#20557 addrman: Fix new table bucketing during unserialization (jnewbery)
- novacoin/novacoin#20561 Periodically clear `m_addr_known` (sdaftuar)
- novacoin/novacoin#20599 net processing: Tolerate sendheaders and sendcmpct messages before verack (jnewbery)
- novacoin/novacoin#20616 Check CJDNS address is valid (lontivero)
- novacoin/novacoin#20617 Remove `m_is_manual_connection` from CNodeState (ariard)
- novacoin/novacoin#20624 net processing: Remove nStartingHeight check from block relay (jnewbery)
- novacoin/novacoin#20651 Make p2p recv buffer timeout 20 minutes for all peers (jnewbery)
- novacoin/novacoin#20661 Only select from addrv2-capable peers for torv3 address relay (sipa)
- novacoin/novacoin#20685 Add I2P support using I2P SAM (vasild)
- novacoin/novacoin#20690 Clean up logging of outbound connection type (sdaftuar)
- novacoin/novacoin#20721 Move ping data to `net_processing` (jnewbery)
- novacoin/novacoin#20724 Cleanup of -debug=net log messages (ajtowns)
- novacoin/novacoin#20747 net processing: Remove dropmessagestest (jnewbery)
- novacoin/novacoin#20764 cli -netinfo peer connections dashboard updates 🎄 ✨ (jonatack)
- novacoin/novacoin#20788 add RAII socket and use it instead of bare SOCKET (vasild)
- novacoin/novacoin#20791 remove unused legacyWhitelisted in AcceptConnection() (jonatack)
- novacoin/novacoin#20816 Move RecordBytesSent() call out of `cs_vSend` lock (jnewbery)
- novacoin/novacoin#20845 Log to net debug in MaybeDiscourageAndDisconnect except for noban and manual peers (MarcoFalke)
- novacoin/novacoin#20864 Move SocketSendData lock annotation to header (MarcoFalke)
- novacoin/novacoin#20965 net, rpc:  return `NET_UNROUTABLE` as `not_publicly_routable`, automate helps (jonatack)
- novacoin/novacoin#20966 banman: save the banlist in a JSON format on disk (vasild)
- novacoin/novacoin#21015 Make all of `net_processing` (and some of net) use std::chrono types (dhruv)
- novacoin/novacoin#21029 novacoin-cli: Correct docs (no "generatenewaddress" exists) (luke-jr)
- novacoin/novacoin#21148 Split orphan handling from `net_processing` into txorphanage (ajtowns)
- novacoin/novacoin#21162 Net Processing: Move RelayTransaction() into PeerManager (jnewbery)
- novacoin/novacoin#21167 make `CNode::m_inbound_onion` public, initialize explicitly (jonatack)
- novacoin/novacoin#21186 net/net processing: Move addr data into `net_processing` (jnewbery)
- novacoin/novacoin#21187 Net processing: Only call PushAddress() from `net_processing` (jnewbery)
- novacoin/novacoin#21198 Address outstanding review comments from PR20721 (jnewbery)
- novacoin/novacoin#21222 log: Clarify log message when file does not exist (MarcoFalke)
- novacoin/novacoin#21235 Clarify disconnect log message in ProcessGetBlockData, remove send bool (MarcoFalke)
- novacoin/novacoin#21236 Net processing: Extract `addr` send functionality into MaybeSendAddr() (jnewbery)
- novacoin/novacoin#21261 update inbound eviction protection for multiple networks, add I2P peers (jonatack)
- novacoin/novacoin#21328 net, refactor: pass uint16 CService::port as uint16 (jonatack)
- novacoin/novacoin#21387 Refactor sock to add I2P fuzz and unit tests (vasild)
- novacoin/novacoin#21395 Net processing: Remove unused CNodeState.address member (jnewbery)
- novacoin/novacoin#21407 i2p: limit the size of incoming messages (vasild)
- novacoin/novacoin#21506 p2p, refactor: make NetPermissionFlags an enum class (jonatack)
- novacoin/novacoin#21509 Don't send FEEFILTER in blocksonly mode (mzumsande)
- novacoin/novacoin#21560 Add Tor v3 hardcoded seeds (laanwj)
- novacoin/novacoin#21563 Restrict period when `cs_vNodes` mutex is locked (hebasto)
- novacoin/novacoin#21564 Avoid calling getnameinfo when formatting IPv4 addresses in CNetAddr::ToStringIP (practicalswift)
- novacoin/novacoin#21631 i2p: always check the return value of Sock::Wait() (vasild)
- novacoin/novacoin#21644 p2p, bugfix: use NetPermissions::HasFlag() in CConnman::Bind() (jonatack)
- novacoin/novacoin#21659 flag relevant Sock methods with [[nodiscard]] (vasild)
- novacoin/novacoin#21750 remove unnecessary check of `CNode::cs_vSend` (vasild)
- novacoin/novacoin#21756 Avoid calling `getnameinfo` when formatting IPv6 addresses in `CNetAddr::ToStringIP` (practicalswift)
- novacoin/novacoin#21775 Limit `m_block_inv_mutex` (MarcoFalke)
- novacoin/novacoin#21825 Add I2P hardcoded seeds (jonatack)
- novacoin/novacoin#21843 p2p, rpc: enable GetAddr, GetAddresses, and getnodeaddresses by network (jonatack)
- novacoin/novacoin#21845 net processing: Don't require locking `cs_main` before calling RelayTransactions() (jnewbery)
- novacoin/novacoin#21872 Sanitize message type for logging (laanwj)
- novacoin/novacoin#21914 Use stronger AddLocal() for our I2P address (vasild)
- novacoin/novacoin#21985 Return IPv6 scope id in `CNetAddr::ToStringIP()` (laanwj)
- novacoin/novacoin#21992 Remove -feefilter option (amadeuszpawlik)
- novacoin/novacoin#21996 Pass strings to NetPermissions::TryParse functions by const ref (jonatack)
- novacoin/novacoin#22013 ignore block-relay-only peers when skipping DNS seed (ajtowns)
- novacoin/novacoin#22050 Remove tor v2 support (jonatack)
- novacoin/novacoin#22096 AddrFetch - don't disconnect on self-announcements (mzumsande)
- novacoin/novacoin#22141 net processing: Remove hash and fValidatedHeaders from QueuedBlock (jnewbery)
- novacoin/novacoin#22144 Randomize message processing peer order (sipa)
- novacoin/novacoin#22147 Protect last outbound HB compact block peer (sdaftuar)
- novacoin/novacoin#22179 Torv2 removal followups (vasild)
- novacoin/novacoin#22211 Relay I2P addresses even if not reachable (by us) (vasild)
- novacoin/novacoin#22284 Performance improvements to ProtectEvictionCandidatesByRatio() (jonatack)
- novacoin/novacoin#22387 Rate limit the processing of rumoured addresses (sipa)
- novacoin/novacoin#22455 addrman: detect on-disk corrupted nNew and nTried during unserialization (vasild)

### Wallet
- novacoin/novacoin#15710 Catch `ios_base::failure` specifically (Bushstar)
- novacoin/novacoin#16546 External signer support - Wallet Box edition (Sjors)
- novacoin/novacoin#17331 Use effective values throughout coin selection (achow101)
- novacoin/novacoin#18418 Increase `OUTPUT_GROUP_MAX_ENTRIES` to 100 (fjahr)
- novacoin/novacoin#18842 Mark replaced tx to not be in the mempool anymore (MarcoFalke)
- novacoin/novacoin#19136 Add `parent_desc` to `getaddressinfo` (achow101)
- novacoin/novacoin#19137 wallettool: Add dump and createfromdump commands (achow101)
- novacoin/novacoin#19651 `importdescriptor`s update existing (S3RK)
- novacoin/novacoin#20040 Refactor OutputGroups to handle fees and spending eligibility on grouping (achow101)
- novacoin/novacoin#20202 Make BDB support optional (achow101)
- novacoin/novacoin#20226, novacoin/novacoin#21277, - novacoin/novacoin#21063 Add `listdescriptors` command (S3RK)
- novacoin/novacoin#20267 Disable and fix tests for when BDB is not compiled (achow101)
- novacoin/novacoin#20275 List all wallets in non-SQLite and non-BDB builds (ryanofsky)
- novacoin/novacoin#20365 wallettool: Add parameter to create descriptors wallet (S3RK)
- novacoin/novacoin#20403 `upgradewallet` fixes, improvements, test coverage (jonatack)
- novacoin/novacoin#20448 `unloadwallet`: Allow specifying `wallet_name` param matching RPC endpoint wallet (luke-jr)
- novacoin/novacoin#20536 Error with "Transaction too large" if the funded tx will end up being too large after signing (achow101)
- novacoin/novacoin#20687 Add missing check for -descriptors wallet tool option (MarcoFalke)
- novacoin/novacoin#20952 Add BerkeleyDB version sanity check at init time (laanwj)
- novacoin/novacoin#21127 Load flags before everything else (Sjors)
- novacoin/novacoin#21141 Add new format string placeholders for walletnotify (maayank)
- novacoin/novacoin#21238 A few descriptor improvements to prepare for Taproot support (sipa)
- novacoin/novacoin#21302 `createwallet` examples for descriptor wallets (S3RK)
- novacoin/novacoin#21329 descriptor wallet: Cache last hardened xpub and use in normalized descriptors (achow101)
- novacoin/novacoin#21365 Basic Taproot signing support for descriptor wallets (sipa)
- novacoin/novacoin#21417 Misc external signer improvement and HWI 2 support (Sjors)
- novacoin/novacoin#21467 Move external signer out of wallet module (Sjors)
- novacoin/novacoin#21572 Fix wrong wallet RPC context set after #21366 (ryanofsky)
- novacoin/novacoin#21574 Drop JSONRPCRequest constructors after #21366 (ryanofsky)
- novacoin/novacoin#21666 Miscellaneous external signer changes (fanquake)
- novacoin/novacoin#21759 Document coin selection code (glozow)
- novacoin/novacoin#21786 Ensure sat/vB feerates are in range (mantissa of 3) (jonatack)
- novacoin/novacoin#21944 Fix issues when `walletdir` is root directory (prayank23)
- novacoin/novacoin#22042 Replace size/weight estimate tuple with struct for named fields (instagibbs)
- novacoin/novacoin#22051 Basic Taproot derivation support for descriptors (sipa)
- novacoin/novacoin#22154 Add OutputType::BECH32M and related wallet support for fetching bech32m addresses (achow101)
- novacoin/novacoin#22156 Allow tr() import only when Taproot is active (achow101)
- novacoin/novacoin#22166 Add support for inferring tr() descriptors (sipa)
- novacoin/novacoin#22173 Do not load external signers wallets when unsupported (achow101)
- novacoin/novacoin#22308 Add missing BlockUntilSyncedToCurrentChain (MarcoFalke)
- novacoin/novacoin#22334 Do not spam about non-existent spk managers (S3RK)
- novacoin/novacoin#22379 Erase spkmans rather than setting to nullptr (achow101)
- novacoin/novacoin#22421 Make IsSegWitOutput return true for taproot outputs (sipa)
- novacoin/novacoin#22461 Change ScriptPubKeyMan::Upgrade default to True (achow101)
- novacoin/novacoin#22492 Reorder locks in dumpwallet to avoid lock order assertion (achow101)
- novacoin/novacoin#22686 Use GetSelectionAmount in ApproximateBestSubset (achow101)

### RPC and other APIs
- novacoin/novacoin#18335, novacoin/novacoin#21484 cli: Print useful error if novacoind rpc work queue exceeded (LarryRuane)
- novacoin/novacoin#18466 Fix invalid parameter error codes for `{sign,verify}message` RPCs (theStack)
- novacoin/novacoin#18772 Calculate fees in `getblock` using BlockUndo data (robot-visions)
- novacoin/novacoin#19033 http: Release work queue after event base finish (promag)
- novacoin/novacoin#19055 Add MuHash3072 implementation (fjahr)
- novacoin/novacoin#19145 Add `hash_type` MUHASH for gettxoutsetinfo (fjahr)
- novacoin/novacoin#19847 Avoid duplicate set lookup in `gettxoutproof` (promag)
- novacoin/novacoin#20286 Deprecate `addresses` and `reqSigs` from RPC outputs (mjdietzx)
- novacoin/novacoin#20459 Fail to return undocumented return values (MarcoFalke)
- novacoin/novacoin#20461 Validate `-rpcauth` arguments (promag)
- novacoin/novacoin#20556 Properly document return values (`submitblock`, `gettxout`, `getblocktemplate`, `scantxoutset`) (MarcoFalke)
- novacoin/novacoin#20755 Remove deprecated fields from `getpeerinfo` (amitiuttarwar)
- novacoin/novacoin#20832 Better error messages for invalid addresses (eilx2)
- novacoin/novacoin#20867 Support up to 20 keys for multisig under Segwit context (darosior)
- novacoin/novacoin#20877 cli: `-netinfo` user help and argument parsing improvements (jonatack)
- novacoin/novacoin#20891 Remove deprecated bumpfee behavior (achow101)
- novacoin/novacoin#20916 Return wtxid from `testmempoolaccept` (MarcoFalke)
- novacoin/novacoin#20917 Add missing signet mentions in network name lists (theStack)
- novacoin/novacoin#20941 Document `RPC_TRANSACTION_ALREADY_IN_CHAIN` exception (jarolrod)
- novacoin/novacoin#20944 Return total fee in `getmempoolinfo` (MarcoFalke)
- novacoin/novacoin#20964 Add specific error code for "wallet already loaded" (laanwj)
- novacoin/novacoin#21053 Document {previous,next}blockhash as optional (theStack)
- novacoin/novacoin#21056 Add a `-rpcwaittimeout` parameter to limit time spent waiting (cdecker)
- novacoin/novacoin#21192 cli: Treat high detail levels as maximum in `-netinfo` (laanwj)
- novacoin/novacoin#21311 Document optional fields for `getchaintxstats` result (theStack)
- novacoin/novacoin#21359 `include_unsafe` option for fundrawtransaction (t-bast)
- novacoin/novacoin#21426 Remove `scantxoutset` EXPERIMENTAL warning (jonatack)
- novacoin/novacoin#21544 Missing doc updates for bumpfee psbt update (MarcoFalke)
- novacoin/novacoin#21594 Add `network` field to `getnodeaddresses` (jonatack)
- novacoin/novacoin#21595, novacoin/novacoin#21753 cli: Create `-addrinfo` (jonatack)
- novacoin/novacoin#21602 Add additional ban time fields to `listbanned` (jarolrod)
- novacoin/novacoin#21679 Keep default argument value in correct type (promag)
- novacoin/novacoin#21718 Improve error message for `getblock` invalid datatype (klementtan)
- novacoin/novacoin#21913 RPCHelpMan fixes (kallewoof)
- novacoin/novacoin#22021 `bumpfee`/`psbtbumpfee` fixes and updates (jonatack)
- novacoin/novacoin#22043 `addpeeraddress` test coverage, code simplify/constness (jonatack)
- novacoin/novacoin#22327 cli: Avoid truncating `-rpcwaittimeout` (MarcoFalke)

### GUI
- novacoin/novacoin#18948 Call setParent() in the parent's context (hebasto)
- novacoin/novacoin#20482 Add depends qt fix for ARM macs (jonasschnelli)
- novacoin/novacoin#21836 scripted-diff: Replace three dots with ellipsis in the ui strings (hebasto)
- novacoin/novacoin#21935 Enable external signer support for GUI builds (Sjors)
- novacoin/novacoin#22133 Make QWindowsVistaStylePlugin available again (regression) (hebasto)
- novacoin-core/gui#4 UI external signer support (e.g. hardware wallet) (Sjors)
- novacoin-core/gui#13 Hide peer detail view if multiple are selected (promag)
- novacoin-core/gui#18 Add peertablesortproxy module (hebasto)
- novacoin-core/gui#21 Improve pruning tooltip (fluffypony, BitcoinErrorLog)
- novacoin-core/gui#72 Log static plugins meta data and used style (hebasto)
- novacoin-core/gui#79 Embed monospaced font (hebasto)
- novacoin-core/gui#85 Remove unused "What's This" button in dialogs on Windows OS (hebasto)
- novacoin-core/gui#115 Replace "Hide tray icon" option with positive "Show tray icon" one (hebasto)
- novacoin-core/gui#118 Remove BDB version from the Information tab (hebasto)
- novacoin-core/gui#121 Early subscribe core signals in transaction table model (promag)
- novacoin-core/gui#123 Do not accept command while executing another one (hebasto)
- novacoin-core/gui#125 Enable changing the autoprune block space size in intro dialog (luke-jr)
- novacoin-core/gui#138 Unlock encrypted wallet "OK" button bugfix (mjdietzx)
- novacoin-core/gui#139 doc: Improve gui/src/qt README.md (jarolrod)
- novacoin-core/gui#154 Support macOS Dark mode (goums, Uplab)
- novacoin-core/gui#162 Add network to peers window and peer details (jonatack)
- novacoin-core/gui#163, novacoin-core/gui#180 Peer details: replace Direction with Connection Type (jonatack)
- novacoin-core/gui#164 Handle peer addition/removal in a right way (hebasto)
- novacoin-core/gui#165 Save QSplitter state in QSettings (hebasto)
- novacoin-core/gui#173 Follow Qt docs when implementing rowCount and columnCount (hebasto)
- novacoin-core/gui#179 Add Type column to peers window, update peer details name/tooltip (jonatack)
- novacoin-core/gui#186 Add information to "Confirm fee bump" window (prayank23)
- novacoin-core/gui#189 Drop workaround for QTBUG-42503 which was fixed in Qt 5.5.0 (prusnak)
- novacoin-core/gui#194 Save/restore RPCConsole geometry only for window (hebasto)
- novacoin-core/gui#202 Fix right panel toggle in peers tab (RandyMcMillan)
- novacoin-core/gui#203 Display plain "Inbound" in peer details (jonatack)
- novacoin-core/gui#204 Drop buggy TableViewLastColumnResizingFixer class (hebasto)
- novacoin-core/gui#205, novacoin-core/gui#229 Save/restore TransactionView and recentRequestsView tables column sizes (hebasto)
- novacoin-core/gui#206 Display fRelayTxes and `bip152_highbandwidth_{to, from}` in peer details (jonatack)
- novacoin-core/gui#213 Add Copy Address Action to Payment Requests (jarolrod)
- novacoin-core/gui#214 Disable requests context menu actions when appropriate (jarolrod)
- novacoin-core/gui#217 Make warning label look clickable (jarolrod)
- novacoin-core/gui#219 Prevent the main window popup menu (hebasto)
- novacoin-core/gui#220 Do not translate file extensions (hebasto)
- novacoin-core/gui#221 RPCConsole translatable string fixes and improvements (jonatack)
- novacoin-core/gui#226 Add "Last Block" and "Last Tx" rows to peer details area (jonatack)
- novacoin-core/gui#233 qt test: Don't bind to regtest port (achow101)
- novacoin-core/gui#243 Fix issue when disabling the auto-enabled blank wallet checkbox (jarolrod)
- novacoin-core/gui#246 Revert "qt: Use "fusion" style on macOS Big Sur with old Qt" (hebasto)
- novacoin-core/gui#248 For values of "Bytes transferred" and "Bytes/s" with 1000-based prefix names use 1000-based divisor instead of 1024-based (wodry)
- novacoin-core/gui#251 Improve URI/file handling message (hebasto)
- novacoin-core/gui#256 Save/restore column sizes of the tables in the Peers tab (hebasto)
- novacoin-core/gui#260 Handle exceptions isntead of crash (hebasto)
- novacoin-core/gui#263 Revamp context menus (hebasto)
- novacoin-core/gui#271 Don't clear console prompt when font resizing (jarolrod)
- novacoin-core/gui#275 Support runtime appearance adjustment on macOS (hebasto)
- novacoin-core/gui#276 Elide long strings in their middle in the Peers tab (hebasto)
- novacoin-core/gui#281 Set shortcuts for console's resize buttons (jarolrod)
- novacoin-core/gui#293 Enable wordWrap for Services (RandyMcMillan)
- novacoin-core/gui#296 Do not use QObject::tr plural syntax for numbers with a unit symbol (hebasto)
- novacoin-core/gui#297 Avoid unnecessary translations (hebasto)
- novacoin-core/gui#298 Peertableview alternating row colors (RandyMcMillan)
- novacoin-core/gui#300 Remove progress bar on modal overlay (brunoerg)
- novacoin-core/gui#309 Add access to the Peers tab from the network icon (hebasto)
- novacoin-core/gui#311 Peers Window rename 'Peer id' to 'Peer' (jarolrod)
- novacoin-core/gui#313 Optimize string concatenation by default (hebasto)
- novacoin-core/gui#325 Align numbers in the "Peer Id" column to the right (hebasto)
- novacoin-core/gui#329 Make console buttons look clickable (jarolrod)
- novacoin-core/gui#330 Allow prompt icon to be colorized (jarolrod)
- novacoin-core/gui#331 Make RPC console welcome message translation-friendly (hebasto)
- novacoin-core/gui#332 Replace disambiguation strings with translator comments (hebasto)
- novacoin-core/gui#335 test: Use QSignalSpy instead of QEventLoop (jarolrod)
- novacoin-core/gui#343 Improve the GUI responsiveness when progress dialogs are used (hebasto)
- novacoin-core/gui#361 Fix GUI segfault caused by novacoin/novacoin#22216 (ryanofsky)
- novacoin-core/gui#362 Add keyboard shortcuts to context menus (luke-jr)
- novacoin-core/gui#366 Dark Mode fixes/portability (luke-jr)
- novacoin-core/gui#375 Emit dataChanged signal to dynamically re-sort Peers table (hebasto)
- novacoin-core/gui#393 Fix regression in "Encrypt Wallet" menu item (hebasto)
- novacoin-core/gui#396 Ensure external signer option remains disabled without signers (achow101)
- novacoin-core/gui#406 Handle new added plurals in `novacoin_en.ts` (hebasto)

### Build system
- novacoin/novacoin#17227 Add Android packaging support (icota)
- novacoin/novacoin#17920 guix: Build support for macOS (dongcarl)
- novacoin/novacoin#18298 Fix Qt processing of configure script for depends with DEBUG=1 (hebasto)
- novacoin/novacoin#19160 multiprocess: Add basic spawn and IPC support (ryanofsky)
- novacoin/novacoin#19504 Bump minimum python version to 3.6 (ajtowns)
- novacoin/novacoin#19522 fix building libconsensus with reduced exports for Darwin targets (fanquake)
- novacoin/novacoin#19683 Pin clang search paths for darwin host (dongcarl)
- novacoin/novacoin#19764 Split boost into build/host packages + bump + cleanup (dongcarl)
- novacoin/novacoin#19817 libtapi 1100.0.11 (fanquake)
- novacoin/novacoin#19846 enable unused member function diagnostic (Zero-1729)
- novacoin/novacoin#19867 Document and cleanup Qt hacks (fanquake)
- novacoin/novacoin#20046 Set `CMAKE_INSTALL_RPATH` for native packages (ryanofsky)
- novacoin/novacoin#20223 Drop the leading 0 from the version number (achow101)
- novacoin/novacoin#20333 Remove `native_biplist` dependency (fanquake)
- novacoin/novacoin#20353 configure: Support -fdebug-prefix-map and -fmacro-prefix-map (ajtowns)
- novacoin/novacoin#20359 Various config.site.in improvements and linting (dongcarl)
- novacoin/novacoin#20413 Require C++17 compiler (MarcoFalke)
- novacoin/novacoin#20419 Set minimum supported macOS to 10.14 (fanquake)
- novacoin/novacoin#20421 miniupnpc 2.2.2 (fanquake)
- novacoin/novacoin#20422 Mac deployment unification (fanquake)
- novacoin/novacoin#20424 Update univalue subtree (MarcoFalke)
- novacoin/novacoin#20449 Fix Windows installer build (achow101)
- novacoin/novacoin#20468 Warn when generating man pages for binaries built from a dirty branch (tylerchambers)
- novacoin/novacoin#20469 Avoid secp256k1.h include from system (dergoegge)
- novacoin/novacoin#20470 Replace genisoimage with xorriso (dongcarl)
- novacoin/novacoin#20471 Use C++17 in depends (fanquake)
- novacoin/novacoin#20496 Drop unneeded macOS framework dependencies (hebasto)
- novacoin/novacoin#20520 Do not force Precompiled Headers (PCH) for building Qt on Linux (hebasto)
- novacoin/novacoin#20549 Support make src/novacoin-node and src/novacoin-gui (promag)
- novacoin/novacoin#20565 Ensure PIC build for bdb on Android (BlockMechanic)
- novacoin/novacoin#20594 Fix getauxval calls in randomenv.cpp (jonasschnelli)
- novacoin/novacoin#20603 Update crc32c subtree (MarcoFalke)
- novacoin/novacoin#20609 configure: output notice that test binary is disabled by fuzzing (apoelstra)
- novacoin/novacoin#20619 guix: Quality of life improvements (dongcarl)
- novacoin/novacoin#20629 Improve id string robustness (dongcarl)
- novacoin/novacoin#20641 Use Qt top-level build facilities (hebasto)
- novacoin/novacoin#20650 Drop workaround for a fixed bug in Qt build system (hebasto)
- novacoin/novacoin#20673 Use more legible qmake commands in qt package (hebasto)
- novacoin/novacoin#20684 Define .INTERMEDIATE target once only (hebasto)
- novacoin/novacoin#20720 more robustly check for fcf-protection support (fanquake)
- novacoin/novacoin#20734 Make platform-specific targets available for proper platform builds only (hebasto)
- novacoin/novacoin#20936 build fuzz tests by default (danben)
- novacoin/novacoin#20937 guix: Make nsis reproducible by respecting SOURCE-DATE-EPOCH (dongcarl)
- novacoin/novacoin#20938 fix linking against -latomic when building for riscv (fanquake)
- novacoin/novacoin#20939 fix `RELOC_SECTION` security check for novacoin-util (fanquake)
- novacoin/novacoin#20963 gitian-linux: Build binaries for 64-bit POWER (continued) (laanwj)
- novacoin/novacoin#21036 gitian: Bump descriptors to focal for 22.0 (fanquake)
- novacoin/novacoin#21045 Adds switch to enable/disable randomized base address in MSVC builds (EthanHeilman)
- novacoin/novacoin#21065 make macOS HOST in download-osx generic (fanquake)
- novacoin/novacoin#21078 guix: only download sources for hosts being built (fanquake)
- novacoin/novacoin#21116 Disable --disable-fuzz-binary for gitian/guix builds (hebasto)
- novacoin/novacoin#21182 remove mostly pointless `BOOST_PROCESS` macro (fanquake)
- novacoin/novacoin#21205 actually fail when Boost is missing (fanquake)
- novacoin/novacoin#21209 use newer source for libnatpmp (fanquake)
- novacoin/novacoin#21226 Fix fuzz binary compilation under windows (danben)
- novacoin/novacoin#21231 Add /opt/homebrew to path to look for boost libraries (fyquah)
- novacoin/novacoin#21239 guix: Add codesignature attachment support for osx+win (dongcarl)
- novacoin/novacoin#21250 Make `HAVE_O_CLOEXEC` available outside LevelDB (bugfix) (theStack)
- novacoin/novacoin#21272 guix: Passthrough `SDK_PATH` into container (dongcarl)
- novacoin/novacoin#21274 assumptions:  Assume C++17 (fanquake)
- novacoin/novacoin#21286 Bump minimum Qt version to 5.9.5 (hebasto)
- novacoin/novacoin#21298 guix: Bump time-machine, glibc, and linux-headers (dongcarl)
- novacoin/novacoin#21304 guix: Add guix-clean script + establish gc-root for container profiles (dongcarl)
- novacoin/novacoin#21320 fix libnatpmp macos cross compile (fanquake)
- novacoin/novacoin#21321 guix: Add curl to required tool list (hebasto)
- novacoin/novacoin#21333 set Unicode true for NSIS installer (fanquake)
- novacoin/novacoin#21339 Make `AM_CONDITIONAL([ENABLE_EXTERNAL_SIGNER])` unconditional (hebasto)
- novacoin/novacoin#21349 Fix fuzz-cuckoocache cross-compiling with DEBUG=1 (hebasto)
- novacoin/novacoin#21354 build, doc: Drop no longer required packages from macOS cross-compiling dependencies (hebasto)
- novacoin/novacoin#21363 build, qt: Improve Qt static plugins/libs check code (hebasto)
- novacoin/novacoin#21375 guix: Misc feedback-based fixes + hier restructuring (dongcarl)
- novacoin/novacoin#21376 Qt 5.12.10 (fanquake)
- novacoin/novacoin#21382 Clean remnants of QTBUG-34748 fix (hebasto)
- novacoin/novacoin#21400 Fix regression introduced in #21363 (hebasto)
- novacoin/novacoin#21403 set --build when configuring packages in depends (fanquake)
- novacoin/novacoin#21421 don't try and use -fstack-clash-protection on Windows (fanquake)
- novacoin/novacoin#21423 Cleanups and follow ups after bumping Qt to 5.12.10 (hebasto)
- novacoin/novacoin#21427 Fix `id_string` invocations (dongcarl)
- novacoin/novacoin#21430 Add -Werror=implicit-fallthrough compile flag (hebasto)
- novacoin/novacoin#21457 Split libtapi and clang out of `native_cctools` (fanquake)
- novacoin/novacoin#21462 guix: Add guix-{attest,verify} scripts (dongcarl)
- novacoin/novacoin#21495 build, qt: Fix static builds on macOS Big Sur (hebasto)
- novacoin/novacoin#21497 Do not opt-in unused CoreWLAN stuff in depends for macOS (hebasto)
- novacoin/novacoin#21543 Enable safe warnings for msvc builds (hebasto)
- novacoin/novacoin#21565 Make `novacoin_qt.m4` more generic (fanquake)
- novacoin/novacoin#21610 remove -Wdeprecated-register from NOWARN flags (fanquake)
- novacoin/novacoin#21613 enable -Wdocumentation (fanquake)
- novacoin/novacoin#21629 Fix configuring when building depends with `NO_BDB=1` (fanquake)
- novacoin/novacoin#21654 build, qt: Make Qt rcc output always deterministic (hebasto)
- novacoin/novacoin#21655 build, qt: No longer need to set `QT_RCC_TEST=1` for determinism (hebasto)
- novacoin/novacoin#21658 fix make deploy for arm64-darwin (sgulls)
- novacoin/novacoin#21694 Use XLIFF file to provide more context to Transifex translators (hebasto)
- novacoin/novacoin#21708, novacoin/novacoin#21593 Drop pointless sed commands (hebasto)
- novacoin/novacoin#21731 Update msvc build to use Qt5.12.10 binaries (sipsorcery)
- novacoin/novacoin#21733 Re-add command to install vcpkg (dplusplus1024)
- novacoin/novacoin#21793 Use `-isysroot` over `--sysroot` on macOS (fanquake)
- novacoin/novacoin#21869 Add missing `-D_LIBCPP_DEBUG=1` to debug flags (MarcoFalke)
- novacoin/novacoin#21889 macho: check for control flow instrumentation (fanquake)
- novacoin/novacoin#21920 Improve macro for testing -latomic requirement (MarcoFalke)
- novacoin/novacoin#21991 libevent 2.1.12-stable (fanquake)
- novacoin/novacoin#22054 Bump Qt version to 5.12.11 (hebasto)
- novacoin/novacoin#22063 Use Qt archive of the same version as the compiled binaries (hebasto)
- novacoin/novacoin#22070 Don't use cf-protection when targeting arm-apple-darwin (fanquake)
- novacoin/novacoin#22071 Latest config.guess and config.sub (fanquake)
- novacoin/novacoin#22075 guix: Misc leftover usability improvements (dongcarl)
- novacoin/novacoin#22123 Fix qt.mk for mac arm64 (promag)
- novacoin/novacoin#22174 build, qt: Fix libraries linking order for Linux hosts (hebasto)
- novacoin/novacoin#22182 guix: Overhaul how guix-{attest,verify} works and hierarchy (dongcarl)
- novacoin/novacoin#22186 build, qt: Fix compiling qt package in depends with GCC 11 (hebasto)
- novacoin/novacoin#22199 macdeploy: minor fixups and simplifications (fanquake)
- novacoin/novacoin#22230 Fix MSVC linker /SubSystem option for novacoin-qt.exe (hebasto)
- novacoin/novacoin#22234 Mark print-% target as phony (dgoncharov)
- novacoin/novacoin#22238 improve detection of eBPF support (fanquake)
- novacoin/novacoin#22258 Disable deprecated-copy warning only when external warnings are enabled (MarcoFalke)
- novacoin/novacoin#22320 set minimum required Boost to 1.64.0 (fanquake)
- novacoin/novacoin#22348 Fix cross build for Windows with Boost Process (hebasto)
- novacoin/novacoin#22365 guix: Avoid relying on newer symbols by rebasing our cross toolchains on older glibcs (dongcarl)
- novacoin/novacoin#22381 guix: Test security-check sanity before performing them (with macOS) (fanquake)
- novacoin/novacoin#22405 Remove --enable-glibc-back-compat from Guix build (fanquake)
- novacoin/novacoin#22406 Remove --enable-determinism configure option (fanquake)
- novacoin/novacoin#22410 Avoid GCC 7.1 ABI change warning in guix build (sipa)
- novacoin/novacoin#22436 use aarch64 Clang if cross-compiling for darwin on aarch64 (fanquake)
- novacoin/novacoin#22465 guix: Pin kernel-header version, time-machine to upstream 1.3.0 commit (dongcarl)
- novacoin/novacoin#22511 guix: Silence `getent(1)` invocation, doc fixups (dongcarl)
- novacoin/novacoin#22531 guix: Fixes to guix-{attest,verify} (achow101)
- novacoin/novacoin#22642 release: Release with separate sha256sums and sig files (dongcarl)
- novacoin/novacoin#22685 clientversion: No suffix `#if CLIENT_VERSION_IS_RELEASE` (dongcarl)
- novacoin/novacoin#22713 Fix build with Boost 1.77.0 (sizeofvoid)

### Tests and QA
- novacoin/novacoin#14604 Add test and refactor `feature_block.py` (sanket1729)
- novacoin/novacoin#17556 Change `feature_config_args.py` not to rely on strange regtest=0 behavior (ryanofsky)
- novacoin/novacoin#18795 wallet issue with orphaned rewards (domob1812)
- novacoin/novacoin#18847 compressor: Use a prevector in CompressScript serialization (jb55)
- novacoin/novacoin#19259 fuzz: Add fuzzing harness for LoadMempool(…) and DumpMempool(…) (practicalswift)
- novacoin/novacoin#19315 Allow outbound & block-relay-only connections in functional tests. (amitiuttarwar)
- novacoin/novacoin#19698 Apply strict verification flags for transaction tests and assert backwards compatibility (glozow)
- novacoin/novacoin#19801 Check for all possible `OP_CLTV` fail reasons in `feature_cltv.py` (BIP 65) (theStack)
- novacoin/novacoin#19893 Remove or explain syncwithvalidationinterfacequeue (MarcoFalke)
- novacoin/novacoin#19972 fuzz: Add fuzzing harness for node eviction logic (practicalswift)
- novacoin/novacoin#19982 Fix inconsistent lock order in `wallet_tests/CreateWallet` (hebasto)
- novacoin/novacoin#20000 Fix creation of "std::string"s with \0s (vasild)
- novacoin/novacoin#20047 Use `wait_for_{block,header}` helpers in `p2p_fingerprint.py` (theStack)
- novacoin/novacoin#20171 Add functional test `test_txid_inv_delay` (ariard)
- novacoin/novacoin#20189 Switch to BIP341's suggested scheme for outputs without script (sipa)
- novacoin/novacoin#20248 Fix length of R check in `key_signature_tests` (dgpv)
- novacoin/novacoin#20276, novacoin/novacoin#20385, novacoin/novacoin#20688, novacoin/novacoin#20692 Run various mempool tests even with wallet disabled (mjdietzx)
- novacoin/novacoin#20323 Create or use existing properly initialized NodeContexts (dongcarl)
- novacoin/novacoin#20354 Add `feature_taproot.py --previous_release` (MarcoFalke)
- novacoin/novacoin#20370 fuzz: Version handshake (MarcoFalke)
- novacoin/novacoin#20377 fuzz: Fill various small fuzzing gaps (practicalswift)
- novacoin/novacoin#20425 fuzz: Make CAddrMan fuzzing harness deterministic (practicalswift)
- novacoin/novacoin#20430 Sanitizers: Add suppression for unsigned-integer-overflow in libstdc++ (jonasschnelli)
- novacoin/novacoin#20437 fuzz: Avoid time-based "non-determinism" in fuzzing harnesses by using mocked GetTime() (practicalswift)
- novacoin/novacoin#20458 Add `is_bdb_compiled` helper (Sjors)
- novacoin/novacoin#20466 Fix intermittent `p2p_fingerprint` issue (MarcoFalke)
- novacoin/novacoin#20472 Add testing of ParseInt/ParseUInt edge cases with leading +/-/0:s (practicalswift)
- novacoin/novacoin#20507 sync: print proper lock order location when double lock is detected (vasild)
- novacoin/novacoin#20522 Fix sync issue in `disconnect_p2ps` (amitiuttarwar)
- novacoin/novacoin#20524 Move `MIN_VERSION_SUPPORTED` to p2p.py (jnewbery)
- novacoin/novacoin#20540 Fix `wallet_multiwallet` issue on windows (MarcoFalke)
- novacoin/novacoin#20560 fuzz: Link all targets once (MarcoFalke)
- novacoin/novacoin#20567 Add option to git-subtree-check to do full check, add help (laanwj)
- novacoin/novacoin#20569 Fix intermittent `wallet_multiwallet` issue with `got_loading_error` (MarcoFalke)
- novacoin/novacoin#20613 Use Popen.wait instead of RPC in `assert_start_raises_init_error` (MarcoFalke)
- novacoin/novacoin#20663 fuzz: Hide `script_assets_test_minimizer` (MarcoFalke)
- novacoin/novacoin#20674 fuzz: Call SendMessages after ProcessMessage to increase coverage (MarcoFalke)
- novacoin/novacoin#20683 Fix restart node race (MarcoFalke)
- novacoin/novacoin#20686 fuzz: replace CNode code with fuzz/util.h::ConsumeNode() (jonatack)
- novacoin/novacoin#20733 Inline non-member functions with body in fuzzing headers (pstratem)
- novacoin/novacoin#20737 Add missing assignment in `mempool_resurrect.py` (MarcoFalke)
- novacoin/novacoin#20745 Correct `epoll_ctl` data race suppression (hebasto)
- novacoin/novacoin#20748 Add race:SendZmqMessage tsan suppression (MarcoFalke)
- novacoin/novacoin#20760 Set correct nValue for multi-op-return policy check (MarcoFalke)
- novacoin/novacoin#20761 fuzz: Check that `NULL_DATA` is unspendable (MarcoFalke)
- novacoin/novacoin#20765 fuzz: Check that certain script TxoutType are nonstandard (mjdietzx)
- novacoin/novacoin#20772 fuzz: Bolster ExtractDestination(s) checks (mjdietzx)
- novacoin/novacoin#20789 fuzz: Rework strong and weak net enum fuzzing (MarcoFalke)
- novacoin/novacoin#20828 fuzz: Introduce CallOneOf helper to replace switch-case (MarcoFalke)
- novacoin/novacoin#20839 fuzz: Avoid extraneous copy of input data, using Span<> (MarcoFalke)
- novacoin/novacoin#20844 Add sanitizer suppressions for AMD EPYC CPUs (MarcoFalke)
- novacoin/novacoin#20857 Update documentation in `feature_csv_activation.py` (PiRK)
- novacoin/novacoin#20876 Replace getmempoolentry with testmempoolaccept in MiniWallet (MarcoFalke)
- novacoin/novacoin#20881 fuzz: net permission flags in net processing (MarcoFalke)
- novacoin/novacoin#20882 fuzz: Add missing muhash registration (MarcoFalke)
- novacoin/novacoin#20908 fuzz: Use mocktime in `process_message*` fuzz targets (MarcoFalke)
- novacoin/novacoin#20915 fuzz: Fail if message type is not fuzzed (MarcoFalke)
- novacoin/novacoin#20946 fuzz: Consolidate fuzzing TestingSetup initialization (dongcarl)
- novacoin/novacoin#20954 Declare `nodes` type `in test_framework.py` (kiminuo)
- novacoin/novacoin#20955 Fix `get_previous_releases.py` for aarch64 (MarcoFalke)
- novacoin/novacoin#20969 check that getblockfilter RPC fails without block filter index (theStack)
- novacoin/novacoin#20971 Work around libFuzzer deadlock (MarcoFalke)
- novacoin/novacoin#20993 Store subversion (user agent) as string in `msg_version` (theStack)
- novacoin/novacoin#20995 fuzz: Avoid initializing version to less than `MIN_PEER_PROTO_VERSION` (MarcoFalke)
- novacoin/novacoin#20998 Fix BlockToJsonVerbose benchmark (martinus)
- novacoin/novacoin#21003 Move MakeNoLogFileContext to `libtest_util`, and use it in bench (MarcoFalke)
- novacoin/novacoin#21008 Fix zmq test flakiness, improve speed (theStack)
- novacoin/novacoin#21023 fuzz: Disable shuffle when merge=1 (MarcoFalke)
- novacoin/novacoin#21037 fuzz: Avoid designated initialization (C++20) in fuzz tests (practicalswift)
- novacoin/novacoin#21042 doc, test: Improve `setup_clean_chain` documentation (fjahr)
- novacoin/novacoin#21080 fuzz: Configure check for main function (take 2) (MarcoFalke)
- novacoin/novacoin#21084 Fix timeout decrease in `feature_assumevalid` (brunoerg)
- novacoin/novacoin#21096 Re-add dead code detection (flack)
- novacoin/novacoin#21100 Remove unused function `xor_bytes` (theStack)
- novacoin/novacoin#21115 Fix Windows cross build (hebasto)
- novacoin/novacoin#21117 Remove `assert_blockchain_height` (MarcoFalke)
- novacoin/novacoin#21121 Small unit test improvements, including helper to make mempool transaction (amitiuttarwar)
- novacoin/novacoin#21124 Remove unnecessary assignment in bdb (brunoerg)
- novacoin/novacoin#21125 Change `BOOST_CHECK` to `BOOST_CHECK_EQUAL` for paths (kiminuo)
- novacoin/novacoin#21142, novacoin/novacoin#21512 fuzz: Add `tx_pool` fuzz target (MarcoFalke)
- novacoin/novacoin#21165 Use mocktime in `test_seed_peers` (dhruv)
- novacoin/novacoin#21169 fuzz: Add RPC interface fuzzing. Increase fuzzing coverage from 65% to 70% (practicalswift)
- novacoin/novacoin#21170 bench: Add benchmark to write json into a string (martinus)
- novacoin/novacoin#21178 Run `mempool_reorg.py` even with wallet disabled (DariusParvin)
- novacoin/novacoin#21185 fuzz: Remove expensive and redundant muhash from crypto fuzz target (MarcoFalke)
- novacoin/novacoin#21200 Speed up `rpc_blockchain.py` by removing miniwallet.generate() (MarcoFalke)
- novacoin/novacoin#21211 Move `P2WSH_OP_TRUE` to shared test library (MarcoFalke)
- novacoin/novacoin#21228 Avoid comparision of integers with different signs (jonasschnelli)
- novacoin/novacoin#21230 Fix `NODE_NETWORK_LIMITED_MIN_BLOCKS` disconnection (MarcoFalke)
- novacoin/novacoin#21252 Add missing wait for sync to `feature_blockfilterindex_prune` (MarcoFalke)
- novacoin/novacoin#21254 Avoid connecting to real network when running tests (MarcoFalke)
- novacoin/novacoin#21264 fuzz: Two scripted diff renames (MarcoFalke)
- novacoin/novacoin#21280 Bug fix in `transaction_tests` (glozow)
- novacoin/novacoin#21293 Replace accidentally placed bit-OR with logical-OR (hebasto)
- novacoin/novacoin#21297 `feature_blockfilterindex_prune.py` improvements (jonatack)
- novacoin/novacoin#21310 zmq test: fix sync-up by matching notification to generated block (theStack)
- novacoin/novacoin#21334 Additional BIP9 tests (Sjors)
- novacoin/novacoin#21338 Add functional test for anchors.dat (brunoerg)
- novacoin/novacoin#21345 Bring `p2p_leak.py` up to date (mzumsande)
- novacoin/novacoin#21357 Unconditionally check for fRelay field in test framework (jarolrod)
- novacoin/novacoin#21358 fuzz: Add missing include (`test/util/setup_common.h`) (MarcoFalke)
- novacoin/novacoin#21371 fuzz: fix gcc Woverloaded-virtual build warnings (jonatack)
- novacoin/novacoin#21373 Generate fewer blocks in `feature_nulldummy` to fix timeouts, speed up (jonatack)
- novacoin/novacoin#21390 Test improvements for UTXO set hash tests (fjahr)
- novacoin/novacoin#21410 increase `rpc_timeout` for fundrawtx `test_transaction_too_large` (jonatack)
- novacoin/novacoin#21411 add logging, reduce blocks, move `sync_all` in `wallet_` groups (jonatack)
- novacoin/novacoin#21438 Add ParseUInt8() test coverage (jonatack)
- novacoin/novacoin#21443 fuzz: Implement `fuzzed_dns_lookup_function` as a lambda (practicalswift)
- novacoin/novacoin#21445 cirrus: Use SSD cluster for speedup (MarcoFalke)
- novacoin/novacoin#21477 Add test for CNetAddr::ToString IPv6 address formatting (RFC 5952) (practicalswift)
- novacoin/novacoin#21487 fuzz: Use ConsumeWeakEnum in addrman for service flags (MarcoFalke)
- novacoin/novacoin#21488 Add ParseUInt16() unit test and fuzz coverage (jonatack)
- novacoin/novacoin#21491 test: remove duplicate assertions in util_tests (jonatack)
- novacoin/novacoin#21522 fuzz: Use PickValue where possible (MarcoFalke)
- novacoin/novacoin#21531 remove qt byteswap compattests (fanquake)
- novacoin/novacoin#21557 small cleanup in RPCNestedTests tests (fanquake)
- novacoin/novacoin#21586 Add missing suppression for signed-integer-overflow:txmempool.cpp (MarcoFalke)
- novacoin/novacoin#21592 Remove option to make TestChain100Setup non-deterministic (MarcoFalke)
- novacoin/novacoin#21597 Document `race:validation_chainstatemanager_tests` suppression (MarcoFalke)
- novacoin/novacoin#21599 Replace file level integer overflow suppression with function level suppression (practicalswift)
- novacoin/novacoin#21604 Document why no symbol names can be used for suppressions (MarcoFalke)
- novacoin/novacoin#21606 fuzz: Extend psbt fuzz target a bit (MarcoFalke)
- novacoin/novacoin#21617 fuzz: Fix uninitialized read in i2p test (MarcoFalke)
- novacoin/novacoin#21630 fuzz: split FuzzedSock interface and implementation (vasild)
- novacoin/novacoin#21634 Skip SQLite fsyncs while testing (achow101)
- novacoin/novacoin#21669 Remove spurious double lock tsan suppressions by bumping to clang-12 (MarcoFalke)
- novacoin/novacoin#21676 Use mocktime to avoid intermittent failure in `rpc_tests` (MarcoFalke)
- novacoin/novacoin#21677 fuzz: Avoid use of low file descriptor ids (which may be in use) in FuzzedSock (practicalswift)
- novacoin/novacoin#21678 Fix TestPotentialDeadLockDetected suppression (hebasto)
- novacoin/novacoin#21689 Remove intermittently failing and not very meaningful `BOOST_CHECK` in `cnetaddr_basic` (practicalswift)
- novacoin/novacoin#21691 Check that no versionbits are re-used (MarcoFalke)
- novacoin/novacoin#21707 Extend functional tests for addr relay (mzumsande)
- novacoin/novacoin#21712 Test default `include_mempool` value of gettxout (promag)
- novacoin/novacoin#21738 Use clang-12 for ASAN, Add missing suppression (MarcoFalke)
- novacoin/novacoin#21740 add new python linter to check file names and permissions (windsok)
- novacoin/novacoin#21749 Bump shellcheck version (hebasto)
- novacoin/novacoin#21754 Run `feature_cltv` with MiniWallet (MarcoFalke)
- novacoin/novacoin#21762 Speed up `mempool_spend_coinbase.py` (MarcoFalke)
- novacoin/novacoin#21773 fuzz: Ensure prevout is consensus-valid (MarcoFalke)
- novacoin/novacoin#21777 Fix `feature_notifications.py` intermittent issue (MarcoFalke)
- novacoin/novacoin#21785 Fix intermittent issue in `p2p_addr_relay.py` (MarcoFalke)
- novacoin/novacoin#21787 Fix off-by-ones in `rpc_fundrawtransaction` assertions (jonatack)
- novacoin/novacoin#21792 Fix intermittent issue in `p2p_segwit.py` (MarcoFalke)
- novacoin/novacoin#21795 fuzz: Terminate immediately if a fuzzing harness tries to perform a DNS lookup (belt and suspenders) (practicalswift)
- novacoin/novacoin#21798 fuzz: Create a block template in `tx_pool` targets (MarcoFalke)
- novacoin/novacoin#21804 Speed up `p2p_segwit.py` (jnewbery)
- novacoin/novacoin#21810 fuzz: Various RPC fuzzer follow-ups (practicalswift)
- novacoin/novacoin#21814 Fix `feature_config_args.py` intermittent issue (MarcoFalke)
- novacoin/novacoin#21821 Add missing test for empty P2WSH redeem (MarcoFalke)
- novacoin/novacoin#21822 Resolve bug in `interface_novacoin_cli.py` (klementtan)
- novacoin/novacoin#21846 fuzz: Add `-fsanitize=integer` suppression needed for RPC fuzzer (`generateblock`) (practicalswift)
- novacoin/novacoin#21849 fuzz: Limit toxic test globals to their respective scope (MarcoFalke)
- novacoin/novacoin#21867 use MiniWallet for `p2p_blocksonly.py` (theStack)
- novacoin/novacoin#21873 minor fixes & improvements for files linter test (windsok)
- novacoin/novacoin#21874 fuzz: Add `WRITE_ALL_FUZZ_TARGETS_AND_ABORT` (MarcoFalke)
- novacoin/novacoin#21884 fuzz: Remove unused --enable-danger-fuzz-link-all option (MarcoFalke)
- novacoin/novacoin#21890 fuzz: Limit ParseISO8601DateTime fuzzing to 32-bit (MarcoFalke)
- novacoin/novacoin#21891 fuzz: Remove strprintf test cases that are known to fail (MarcoFalke)
- novacoin/novacoin#21892 fuzz: Avoid excessively large min fee rate in `tx_pool` (MarcoFalke)
- novacoin/novacoin#21895 Add TSA annotations to the WorkQueue class members (hebasto)
- novacoin/novacoin#21900 use MiniWallet for `feature_csv_activation.py` (theStack)
- novacoin/novacoin#21909 fuzz: Limit max insertions in timedata fuzz test (MarcoFalke)
- novacoin/novacoin#21922 fuzz: Avoid timeout in EncodeBase58 (MarcoFalke)
- novacoin/novacoin#21927 fuzz: Run const CScript member functions only once (MarcoFalke)
- novacoin/novacoin#21929 fuzz: Remove incorrect float round-trip serialization test (MarcoFalke)
- novacoin/novacoin#21936 fuzz: Terminate immediately if a fuzzing harness tries to create a TCP socket (belt and suspenders) (practicalswift)
- novacoin/novacoin#21941 fuzz: Call const member functions in addrman fuzz test only once (MarcoFalke)
- novacoin/novacoin#21945 add P2PK support to MiniWallet (theStack)
- novacoin/novacoin#21948 Fix off-by-one in mockscheduler test RPC (MarcoFalke)
- novacoin/novacoin#21953 fuzz: Add `utxo_snapshot` target (MarcoFalke)
- novacoin/novacoin#21970 fuzz: Add missing CheckTransaction before CheckTxInputs (MarcoFalke)
- novacoin/novacoin#21989 Use `COINBASE_MATURITY` in functional tests (kiminuo)
- novacoin/novacoin#22003 Add thread safety annotations (ajtowns)
- novacoin/novacoin#22004 fuzz: Speed up transaction fuzz target (MarcoFalke)
- novacoin/novacoin#22005 fuzz: Speed up banman fuzz target (MarcoFalke)
- novacoin/novacoin#22029 [fuzz] Improve transport deserialization fuzz test coverage (dhruv)
- novacoin/novacoin#22048 MiniWallet: introduce enum type for output mode (theStack)
- novacoin/novacoin#22057 use MiniWallet (P2PK mode) for `feature_dersig.py` (theStack)
- novacoin/novacoin#22065 Mark `CheckTxInputs` `[[nodiscard]]`. Avoid UUM in fuzzing harness `coins_view` (practicalswift)
- novacoin/novacoin#22069 fuzz: don't try and use fopencookie() when building for Android (fanquake)
- novacoin/novacoin#22082 update nanobench from release 4.0.0 to 4.3.4 (martinus)
- novacoin/novacoin#22086 remove BasicTestingSetup from unit tests that don't need it (fanquake)
- novacoin/novacoin#22089 MiniWallet: fix fee calculation for P2PK and check tx vsize (theStack)
- novacoin/novacoin#21107, novacoin/novacoin#22092 Convert documentation into type annotations (fanquake)
- novacoin/novacoin#22095 Additional BIP32 test vector for hardened derivation with leading zeros (kristapsk)
- novacoin/novacoin#22103 Fix IPv6 check on BSD systems (n-thumann)
- novacoin/novacoin#22118 check anchors.dat when node starts for the first time (brunoerg)
- novacoin/novacoin#22120 `p2p_invalid_block`: Check that a block rejected due to too-new tim… (willcl-ark)
- novacoin/novacoin#22153 Fix `p2p_leak.py` intermittent failure (mzumsande)
- novacoin/novacoin#22169 p2p, rpc, fuzz: various tiny follow-ups (jonatack)
- novacoin/novacoin#22176 Correct outstanding -Werror=sign-compare errors (Empact)
- novacoin/novacoin#22180 fuzz: Increase branch coverage of the float fuzz target (MarcoFalke)
- novacoin/novacoin#22187 Add `sync_blocks` in `wallet_orphanedreward.py` (domob1812)
- novacoin/novacoin#22201 Fix TestShell to allow running in Jupyter Notebook (josibake)
- novacoin/novacoin#22202 Add temporary coinstats suppressions (MarcoFalke)
- novacoin/novacoin#22203 Use ConnmanTestMsg from test lib in `denialofservice_tests` (MarcoFalke)
- novacoin/novacoin#22210 Use MiniWallet in `test_no_inherited_signaling` RBF test (MarcoFalke)
- novacoin/novacoin#22224 Update msvc and appveyor builds to use Qt5.12.11 binaries (sipsorcery)
- novacoin/novacoin#22249 Kill process group to avoid dangling processes when using `--failfast` (S3RK)
- novacoin/novacoin#22267 fuzz: Speed up crypto fuzz target (MarcoFalke)
- novacoin/novacoin#22270 Add novacoin-util tests (+refactors) (MarcoFalke)
- novacoin/novacoin#22271 fuzz: Assert roundtrip equality for `CPubKey` (theStack)
- novacoin/novacoin#22279 fuzz: add missing ECCVerifyHandle to `base_encode_decode` (apoelstra)
- novacoin/novacoin#22292 bench, doc: benchmarking updates and fixups (jonatack)
- novacoin/novacoin#22306 Improvements to `p2p_addr_relay.py` (amitiuttarwar)
- novacoin/novacoin#22310 Add functional test for replacement relay fee check (ariard)
- novacoin/novacoin#22311 Add missing syncwithvalidationinterfacequeue in `p2p_blockfilters` (MarcoFalke)
- novacoin/novacoin#22313 Add missing `sync_all` to `feature_coinstatsindex` (MarcoFalke)
- novacoin/novacoin#22322 fuzz: Check banman roundtrip (MarcoFalke)
- novacoin/novacoin#22363 Use `script_util` helpers for creating P2{PKH,SH,WPKH,WSH} scripts (theStack)
- novacoin/novacoin#22399 fuzz: Rework CTxDestination fuzzing (MarcoFalke)
- novacoin/novacoin#22408 add tests for `bad-txns-prevout-null` reject reason (theStack)
- novacoin/novacoin#22445 fuzz: Move implementations of non-template fuzz helpers from util.h to util.cpp (sriramdvt)
- novacoin/novacoin#22446 Fix `wallet_listdescriptors.py` if bdb is not compiled (hebasto)
- novacoin/novacoin#22447 Whitelist `rpc_rawtransaction` peers to speed up tests (jonatack)
- novacoin/novacoin#22742 Use proper target in `do_fund_send` (S3RK)

### Miscellaneous
- novacoin/novacoin#19337 sync: Detect double lock from the same thread (vasild)
- novacoin/novacoin#19809 log: Prefix log messages with function name and source code location if -logsourcelocations is set (practicalswift)
- novacoin/novacoin#19866 eBPF Linux tracepoints (jb55)
- novacoin/novacoin#20024 init: Fix incorrect warning "Reducing -maxconnections from N to N-1, because of system limitations" (practicalswift)
- novacoin/novacoin#20145 contrib: Add getcoins.py script to get coins from (signet) faucet (kallewoof)
- novacoin/novacoin#20255 util: Add assume() identity function (MarcoFalke)
- novacoin/novacoin#20288 script, doc: Contrib/seeds updates (jonatack)
- novacoin/novacoin#20358 src/randomenv.cpp: Fix build on uclibc (ffontaine)
- novacoin/novacoin#20406 util: Avoid invalid integer negation in formatmoney and valuefromamount (practicalswift)
- novacoin/novacoin#20434 contrib: Parse elf directly for symbol and security checks (laanwj)
- novacoin/novacoin#20451 lint: Run mypy over contrib/devtools (fanquake)
- novacoin/novacoin#20476 contrib: Add test for elf symbol-check (laanwj)
- novacoin/novacoin#20530 lint: Update cppcheck linter to c++17 and improve explicit usage (fjahr)
- novacoin/novacoin#20589 log: Clarify that failure to read/write `fee_estimates.dat` is non-fatal (MarcoFalke)
- novacoin/novacoin#20602 util: Allow use of c++14 chrono literals (MarcoFalke)
- novacoin/novacoin#20605 init: Signal-safe instant shutdown (laanwj)
- novacoin/novacoin#20608 contrib: Add symbol check test for PE binaries (fanquake)
- novacoin/novacoin#20689 contrib: Replace binary verification script verify.sh with python rewrite (theStack)
- novacoin/novacoin#20715 util: Add argsmanager::getcommand() and use it in novacoin-wallet (MarcoFalke)
- novacoin/novacoin#20735 script: Remove outdated extract-osx-sdk.sh (hebasto)
- novacoin/novacoin#20817 lint: Update list of spelling linter false positives, bump to codespell 2.0.0 (theStack)
- novacoin/novacoin#20884 script: Improve robustness of novacoind.service on startup (hebasto)
- novacoin/novacoin#20906 contrib: Embed c++11 patch in `install_db4.sh` (gruve-p)
- novacoin/novacoin#21004 contrib: Fix docker args conditional in gitian-build (setpill)
- novacoin/novacoin#21007 novacoind: Add -daemonwait option to wait for initialization (laanwj)
- novacoin/novacoin#21041 log: Move "Pre-allocating up to position 0x[…] in […].dat" log message to debug category (practicalswift)
- novacoin/novacoin#21059 Drop boost/preprocessor dependencies (hebasto)
- novacoin/novacoin#21087 guix: Passthrough `BASE_CACHE` into container (dongcarl)
- novacoin/novacoin#21088 guix: Jump forwards in time-machine and adapt (dongcarl)
- novacoin/novacoin#21089 guix: Add support for powerpc64{,le} (dongcarl)
- novacoin/novacoin#21110 util: Remove boost `posix_time` usage from `gettime*` (fanquake)
- novacoin/novacoin#21111 Improve OpenRC initscript (parazyd)
- novacoin/novacoin#21123 code style: Add EditorConfig file (kiminuo)
- novacoin/novacoin#21173 util: Faster hexstr => 13% faster blocktojson (martinus)
- novacoin/novacoin#21221 tools: Allow argument/parameter bin packing in clang-format (jnewbery)
- novacoin/novacoin#21244 Move GetDataDir to ArgsManager (kiminuo)
- novacoin/novacoin#21255 contrib: Run test-symbol-check for risc-v (fanquake)
- novacoin/novacoin#21271 guix: Explicitly set umask in build container (dongcarl)
- novacoin/novacoin#21300 script: Add explanatory comment to tc.sh (dscotese)
- novacoin/novacoin#21317 util: Make assume() usable as unary expression (MarcoFalke)
- novacoin/novacoin#21336 Make .gitignore ignore src/test/fuzz/fuzz.exe (hebasto)
- novacoin/novacoin#21337 guix: Update darwin native packages dependencies (hebasto)
- novacoin/novacoin#21405 compat: remove memcpy -> memmove backwards compatibility alias (fanquake)
- novacoin/novacoin#21418 contrib: Make systemd invoke dependencies only when ready (laanwj)
- novacoin/novacoin#21447 Always add -daemonwait to known command line arguments (hebasto)
- novacoin/novacoin#21471 bugfix: Fix `bech32_encode` calls in `gen_key_io_test_vectors.py` (sipa)
- novacoin/novacoin#21615 script: Add trusted key for hebasto (hebasto)
- novacoin/novacoin#21664 contrib: Use lief for macos and windows symbol & security checks (fanquake)
- novacoin/novacoin#21695 contrib: Remove no longer used contrib/novacoin-qt.pro (hebasto)
- novacoin/novacoin#21711 guix: Add full installation and usage documentation (dongcarl)
- novacoin/novacoin#21799 guix: Use `gcc-8` across the board (dongcarl)
- novacoin/novacoin#21802 Avoid UB in util/asmap (advance a dereferenceable iterator outside its valid range) (MarcoFalke)
- novacoin/novacoin#21823 script: Update reviewers (jonatack)
- novacoin/novacoin#21850 Remove `GetDataDir(net_specific)` function (kiminuo)
- novacoin/novacoin#21871 scripts: Add checks for minimum required os versions (fanquake)
- novacoin/novacoin#21966 Remove double serialization; use software encoder for fee estimation (sipa)
- novacoin/novacoin#22060 contrib: Add torv3 seed nodes for testnet, drop v2 ones (laanwj)
- novacoin/novacoin#22244 devtools: Correctly extract symbol versions in symbol-check (laanwj)
- novacoin/novacoin#22533 guix/build: Remove vestigial SKIPATTEST.TAG (dongcarl)
- novacoin/novacoin#22643 guix-verify: Non-zero exit code when anything fails (dongcarl)
- novacoin/novacoin#22654 guix: Don't include directory name in SHA256SUMS (achow101)

### Documentation
- novacoin/novacoin#15451 clarify getdata limit after #14897 (HashUnlimited)
- novacoin/novacoin#15545 Explain why CheckBlock() is called before AcceptBlock (Sjors)
- novacoin/novacoin#17350 Add developer documentation to isminetype (HAOYUatHZ)
- novacoin/novacoin#17934 Use `CONFIG_SITE` variable instead of --prefix option (hebasto)
- novacoin/novacoin#18030 Coin::IsSpent() can also mean never existed (Sjors)
- novacoin/novacoin#18096 IsFinalTx comment about nSequence & `OP_CLTV` (nothingmuch)
- novacoin/novacoin#18568 Clarify developer notes about constant naming (ryanofsky)
- novacoin/novacoin#19961 doc: tor.md updates (jonatack)
- novacoin/novacoin#19968 Clarify CRollingBloomFilter size estimate (robot-dreams)
- novacoin/novacoin#20200 Rename CODEOWNERS to REVIEWERS (adamjonas)
- novacoin/novacoin#20329 docs/descriptors.md: Remove hardened marker in the path after xpub (dgpv)
- novacoin/novacoin#20380 Add instructions on how to fuzz the P2P layer using Honggfuzz NetDriver (practicalswift)
- novacoin/novacoin#20414 Remove generated manual pages from master branch (laanwj)
- novacoin/novacoin#20473 Document current boost dependency as 1.71.0 (laanwj)
- novacoin/novacoin#20512 Add bash as an OpenBSD dependency (emilengler)
- novacoin/novacoin#20568 Use FeeModes doc helper in estimatesmartfee (MarcoFalke)
- novacoin/novacoin#20577 libconsensus: add missing error code description, fix NBitcoin link (theStack)
- novacoin/novacoin#20587 Tidy up Tor doc (more stringent) (wodry)
- novacoin/novacoin#20592 Update wtxidrelay documentation per BIP339 (jonatack)
- novacoin/novacoin#20601 Update for FreeBSD 12.2, add GUI Build Instructions (jarolrod)
- novacoin/novacoin#20635 fix misleading comment about call to non-existing function (pox)
- novacoin/novacoin#20646 Refer to BIPs 339/155 in feature negotiation (jonatack)
- novacoin/novacoin#20653 Move addr relay comment in net to correct place (MarcoFalke)
- novacoin/novacoin#20677 Remove shouty enums in `net_processing` comments (sdaftuar)
- novacoin/novacoin#20741 Update 'Secure string handling' (prayank23)
- novacoin/novacoin#20757 tor.md and -onlynet help updates (jonatack)
- novacoin/novacoin#20829 Add -netinfo help (jonatack)
- novacoin/novacoin#20830 Update developer notes with signet (jonatack)
- novacoin/novacoin#20890 Add explicit macdeployqtplus dependencies install step (hebasto)
- novacoin/novacoin#20913 Add manual page generation for novacoin-util (laanwj)
- novacoin/novacoin#20985 Add xorriso to macOS depends packages (fanquake)
- novacoin/novacoin#20986 Update developer notes to discourage very long lines (jnewbery)
- novacoin/novacoin#20987 Add instructions for generating RPC docs (ben-kaufman)
- novacoin/novacoin#21026 Document use of make-tag script to make tags (laanwj)
- novacoin/novacoin#21028 doc/bips: Add BIPs 43, 44, 49, and 84 (luke-jr)
- novacoin/novacoin#21049 Add release notes for listdescriptors RPC (S3RK)
- novacoin/novacoin#21060 More precise -debug and -debugexclude doc (wodry)
- novacoin/novacoin#21077 Clarify -timeout and -peertimeout config options (glozow)
- novacoin/novacoin#21105 Correctly identify script type (niftynei)
- novacoin/novacoin#21163 Guix is shipped in Debian and Ubuntu (MarcoFalke)
- novacoin/novacoin#21210 Rework internal and external links (MarcoFalke)
- novacoin/novacoin#21246 Correction for VerifyTaprootCommitment comments (roconnor-blockstream)
- novacoin/novacoin#21263 Clarify that squashing should happen before review (MarcoFalke)
- novacoin/novacoin#21323 guix, doc: Update default HOSTS value (hebasto)
- novacoin/novacoin#21324 Update build instructions for Fedora (hebasto)
- novacoin/novacoin#21343 Revamp macOS build doc (jarolrod)
- novacoin/novacoin#21346 install qt5 when building on macOS (fanquake)
- novacoin/novacoin#21384 doc: add signet to novacoin.conf documentation (jonatack)
- novacoin/novacoin#21394 Improve comment about protected peers (amitiuttarwar)
- novacoin/novacoin#21398 Update fuzzing docs for afl-clang-lto (MarcoFalke)
- novacoin/novacoin#21444 net, doc: Doxygen updates and fixes in netbase.{h,cpp} (jonatack)
- novacoin/novacoin#21481 Tell howto install clang-format on Debian/Ubuntu (wodry)
- novacoin/novacoin#21567 Fix various misleading comments (glozow)
- novacoin/novacoin#21661 Fix name of script guix-build (Emzy)
- novacoin/novacoin#21672 Remove boostrap info from `GUIX_COMMON_FLAGS` doc (fanquake)
- novacoin/novacoin#21688 Note on SDK for macOS depends cross-compile (jarolrod)
- novacoin/novacoin#21709 Update reduce-memory.md and novacoin.conf -maxconnections info (jonatack)
- novacoin/novacoin#21710 update helps for addnode rpc and -addnode/-maxconnections config options (jonatack)
- novacoin/novacoin#21752 Clarify that feerates are per virtual size (MarcoFalke)
- novacoin/novacoin#21811 Remove Visual Studio 2017 reference from readme (sipsorcery)
- novacoin/novacoin#21818 Fixup -coinstatsindex help, update novacoin.conf and files.md (jonatack)
- novacoin/novacoin#21856 add OSS-Fuzz section to fuzzing.md doc (adamjonas)
- novacoin/novacoin#21912 Remove mention of priority estimation (MarcoFalke)
- novacoin/novacoin#21925 Update bips.md for 0.21.1 (MarcoFalke)
- novacoin/novacoin#21942 improve make with parallel jobs description (klementtan)
- novacoin/novacoin#21947 Fix OSS-Fuzz links (MarcoFalke)
- novacoin/novacoin#21988 note that brew installed qt is not supported (jarolrod)
- novacoin/novacoin#22056 describe in fuzzing.md how to reproduce a CI crash (jonatack)
- novacoin/novacoin#22080 add maxuploadtarget to novacoin.conf example (jarolrod)
- novacoin/novacoin#22088 Improve note on choosing posix mingw32 (jarolrod)
- novacoin/novacoin#22109 Fix external links (IRC, …) (MarcoFalke)
- novacoin/novacoin#22121 Various validation doc fixups (MarcoFalke)
- novacoin/novacoin#22172 Update tor.md, release notes with removal of tor v2 support (jonatack)
- novacoin/novacoin#22204 Remove obsolete `okSafeMode` RPC guideline from developer notes (theStack)
- novacoin/novacoin#22208 Update `REVIEWERS` (practicalswift)
- novacoin/novacoin#22250 add basic I2P documentation (vasild)
- novacoin/novacoin#22296 Final merge of release notes snippets, mv to wiki (MarcoFalke)
- novacoin/novacoin#22335 recommend `--disable-external-signer` in OpenBSD build guide (theStack)
- novacoin/novacoin#22339 Document minimum required libc++ version (hebasto)
- novacoin/novacoin#22349 Repository IRC updates (jonatack)
- novacoin/novacoin#22360 Remove unused section from release process (MarcoFalke)
- novacoin/novacoin#22369 Add steps for Transifex to release process (jonatack)
- novacoin/novacoin#22393 Added info to novacoin.conf doc (bliotti)
- novacoin/novacoin#22402 Install Rosetta on M1-macOS for qt in depends (hebasto)
- novacoin/novacoin#22432 Fix incorrect `testmempoolaccept` doc (glozow)
- novacoin/novacoin#22648 doc, test: improve i2p/tor docs and i2p reachable unit tests (jonatack)

Credits
=======

Thanks to everyone who directly contributed to this release:

- Aaron Clauson
- Adam Jonas
- amadeuszpawlik
- Amiti Uttarwar
- Andrew Chow
- Andrew Poelstra
- Anthony Towns
- Antoine Poinsot
- Antoine Riard
- apawlik
- apitko
- Ben Carman
- Ben Woosley
- benk10
- Bezdrighin
- Block Mechanic
- Brian Liotti
- Bruno Garcia
- Carl Dong
- Christian Decker
- coinforensics
- Cory Fields
- Dan Benjamin
- Daniel Kraft
- Darius Parvin
- Dhruv Mehta
- Dmitry Goncharov
- Dmitry Petukhov
- dplusplus1024
- dscotese
- Duncan Dean
- Elle Mouton
- Elliott Jin
- Emil Engler
- Ethan Heilman
- eugene
- Evan Klitzke
- Fabian Jahr
- Fabrice Fontaine
- fanquake
- fdov
- flack
- Fotis Koutoupas
- Fu Yong Quah
- fyquah
- glozow
- Gregory Sanders
- Guido Vranken
- Gunar C. Gessner
- h
- HAOYUatHZ
- Hennadii Stepanov
- Igor Cota
- Ikko Ashimine
- Ivan Metlushko
- jackielove4u
- James O'Beirne
- Jarol Rodriguez
- Joel Klabo
- John Newbery
- Jon Atack
- Jonas Schnelli
- João Barbosa
- Josiah Baker
- Karl-Johan Alm
- Kiminuo
- Klement Tan
- Kristaps Kaupe
- Larry Ruane
- lisa neigut
- Lucas Ontivero
- Luke Dashjr
- Maayan Keshet
- MarcoFalke
- Martin Ankerl
- Martin Zumsande
- Michael Dietz
- Michael Polzer
- Michael Tidwell
- Niklas Gögge
- nthumann
- Oliver Gugger
- parazyd
- Patrick Strateman
- Pavol Rusnak
- Peter Bushnell
- Pierre K
- Pieter Wuille
- PiRK
- pox
- practicalswift
- Prayank
- R E Broadley
- Rafael Sadowski
- randymcmillan
- Raul Siles
- Riccardo Spagni
- Russell O'Connor
- Russell Yanofsky
- S3RK
- saibato
- Samuel Dobson
- sanket1729
- Sawyer Billings
- Sebastian Falbesoner
- setpill
- sgulls
- sinetek
- Sjors Provoost
- Sriram
- Stephan Oeste
- Suhas Daftuar
- Sylvain Goumy
- t-bast
- Troy Giorshev
- Tushar Singla
- Tyler Chambers
- Uplab
- Vasil Dimov
- W. J. van der Laan
- willcl-ark
- William Bright
- William Casarin
- windsok
- wodry
- Yerzhan Mazhkenov
- Yuval Kogman
- Zero

As well as to everyone that helped with translations on
[Transifex](https://www.transifex.com/novacoin/novacoin/).
