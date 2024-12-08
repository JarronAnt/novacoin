# Copyright (c) 2023-present The Bitcoin Core developers
# Distributed under the MIT software license, see the accompanying
# file COPYING or https://opensource.org/license/mit/.

if(TARGET novacoin-util AND TARGET novacoin-tx AND PYTHON_COMMAND)
  add_test(NAME util_test_runner
    COMMAND ${CMAKE_COMMAND} -E env BITCOINUTIL=$<TARGET_FILE:novacoin-util> BITCOINTX=$<TARGET_FILE:novacoin-tx> ${PYTHON_COMMAND} ${PROJECT_BINARY_DIR}/test/util/test_runner.py
  )
endif()

if(PYTHON_COMMAND)
  add_test(NAME util_rpcauth_test
    COMMAND ${PYTHON_COMMAND} ${PROJECT_BINARY_DIR}/test/util/rpcauth-test.py
  )
endif()
