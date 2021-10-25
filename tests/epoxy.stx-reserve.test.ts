import { Clarinet, Tx, Chain, Account, Contract, types } from 'https://deno.land/x/clarinet@v0.13.0/index.ts';
import { assertEquals } from "https://deno.land/std@0.90.0/testing/asserts.ts";

Clarinet.test({
    name: "xxx",
    async fn(chain: Chain, accounts: Map<string, Account>, contracts: Map<string, Contract>) {
        let deployer = accounts.get("deployer")!.address;
        let wallet_1 = accounts.get("wallet_1")!.address;
        let wallet_2 = accounts.get("wallet_2")!.address;

        let block = chain.mineBlock([
            Tx.contractCall(
                "epoxy-stx-reserve",
                "mint-epoxy-on-stacks",
                [types.uint(1), types.principal(`${deployer}.epoxy-token`)],
                wallet_1),
            Tx.contractCall(
                "epoxy-stx-reserve",
                "mint-epoxy-on-stacks",
                [types.uint(4), types.principal(`${deployer}.epoxy-token`)],
                wallet_2),
        ]);
        console.log(block);
    }
})