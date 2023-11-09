// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

import {IR1Validator, IERC165} from './interfaces/IValidator.sol';
import {Errors} from './libraries/Errors.sol';
import {Transaction} from '@matterlabs/zksync-contracts/l2/system-contracts/libraries/TransactionHelper.sol';
import {SystemContractsCaller} from '@matterlabs/zksync-contracts/l2/system-contracts/libraries/SystemContractsCaller.sol';

/**
 * @title secp256r1 ec keys' signature validator contract implementing its interface
 * @author https://getclave.io
 */
contract Validator {
    //dummy value
    address constant P256_VERIFIER = 0x4213c20482E08877D6Fe7c8a2362599765a3F11F;
    // address constant P256_VERIFIER = 0x0000000000000000000000000000000000000019;
    // address constant P256_VERIFIER = 0x18c994fD76764aE2229b85978361D23bCFc2aE5a;

    //event Test(bool success);

    function log(uint256 val) public view {
        assembly {
            // CONSOLE.LOG Caller
            // It prints 'val' in the node console and it works using the 'mem'+0x40 memory sector
            let log_address := 0x000000000000000000636F6e736F6c652e6c6f67
            // load the free memory pointer
            let freeMemPointer := 0x1000
            // store the function selector of log(uint256) in memory
            mstore(freeMemPointer, 0xf82c50f1)
            // store the first argument of log(uint256) in the next memory slot
            mstore(add(freeMemPointer, 0x20), val)
            // call the console.log contract
            if iszero(staticcall(gas(),log_address,add(freeMemPointer, 28),add(freeMemPointer, 0x40),0x00,0x00)) {
                revert(0,0)
            }
        }
    }

    function validateSignature(
        bytes32 signedHash,
        bytes calldata signature,
        bytes32[2] calldata pubKey
    ) external returns (bool valid) {
        // log(0xaca);
        bytes32[2] memory rs = abi.decode(signature, (bytes32[2]));

        bool success = callVerifier(sha256(abi.encodePacked(signedHash)), rs, pubKey);

        //emit Test(success);

        if (success) valid = true;
    }

    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
        return
            interfaceId == type(IR1Validator).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
    }

    /**
     * @notice Calls the verifier function with given params
     * @param hash bytes32         - Signed data hash
     * @param rs bytes32[2]        - Signature array for the r and s values
     * @param pubKey bytes32[2]    - Public key coordinates array for the x and y values
     * @return - bool - Return the success of the verification
     */
    function callVerifier(
        bytes32 hash,
        bytes32[2] memory rs,
        bytes32[2] memory pubKey
    ) private returns (bool) {
        /**
         * Prepare the input format
         * input[  0: 32] = signed data hash
         * input[ 32: 64] = signature r
         * input[ 64: 96] = signature s
         * input[ 96:128] = public key x
         * input[128:160] = public key y
         */
        bytes memory input = abi.encodePacked(hash, rs[0], rs[1], pubKey[0], pubKey[1]);

        // Make a call to verify the signature
        (bool success, bytes memory data) = SystemContractsCaller.systemCallWithReturndata(
            uint32(gasleft()),
            P256_VERIFIER,
            0,
            input
        );

        uint256 returnValue;
        // Return true if the call was successful and the return value is 1
        if (success && data.length > 0) {
            assembly {
                returnValue := mload(add(data, 0x20))
            }
            if (returnValue == 1) return true;
        }
        // Otherwise return false for the unsucessful calls and invalid signatures
        return false;
    }
}
