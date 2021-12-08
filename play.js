const ethers = require('ethers');
const fs = require('fs');
const path = require('path');

const provider = new ethers.providers.JsonRpcProvider('http://localhost:7545');

const admin = new ethers.Wallet(
  //'0xb0057716d5917badaf911b193b12b910811c1497b5bada8d7711f758981c3773',
  '0xa1fb6acde5de47991035abc3d7059decb335da4346e90a1781225e4bb0af4b93',
  provider
);

const readABI = name => {
  const json = JSON.parse(
    fs.readFileSync(path.join(__dirname, '/build/contracts/', `${name}.json`))
  );
  return json.abi;
};

//const ContractAddr = '0xBe0B0f08A599F07699E98A9D001084e97b9a900A';
const ContractAddr = '0xd855d15cdA2DC5866c681876434710De246011F8';

const contract = new ethers.Contract(ContractAddr, readABI('XAccreditationRegistry'), admin);

async function printTx(txhash) {
  console.log(
    await provider.getTransaction(txhash)
  );
}

async function mintToken(accreditationId, to) {
  const tx = await contract.functions.mintToken(accreditationId, to, {
    gasLimit: 6521975,
  });
  // console.log(tx);
  await tx.wait();
}

async function mintTokenBatch(accreditationId, to) {
  const tx = await contract.functions.mintAccreditationToManyUsers(accreditationId, to, {
    gasLimit: 6521975,
  });
  // console.log(tx);
  const txreceipt = await tx.wait();

  console.log('nroAddr:', to.length, 'gasCost:', txreceipt.gasUsed.toNumber());
}

async function printTokens(address) {
  const tokensAmount = (await contract.functions.balanceOf(address)).toNumber();

  let accreditations = [];
  for (let i = 0; i < tokensAmount; i++) {
    let tokenId = await contract.functions.tokenOfOwnerByIndex(address, i);
    let uri = await contract.functions.tokenURI(tokenId);
    accreditations.push({
      uri: uri,
      tokenId: tokenId,
    });
  }
  console.log(JSON.stringify(accreditations));
  return accreditations;
}

async function main() {
  console.log('Paused:', await contract.functions.paused());
  console.log('Functions:', await contract.functions);
  console.log(`${admin.address} is isAdmin:`, await contract.functions.isAdmin(admin.address));
  console.log(
    `${admin.address} is isAccreditationMinter:`,
    await contract.functions.isAccreditationMinter(100, admin.address)
  );

  await mintToken(100, '0x1df62f291b2e969fb0849d99d9ce41e2f137006e');

  // await mintTokenBatch(50, [
  //   '0x90f8bf6a479f320ead074411a4b0e7944ea8c9c1',
  //   '0xffcf8fdee72ac11b5c542428b35eef5769c409f0',
  //   '0x22d491bde2303f2f43325b2108d26f1eaba1e32b',
  //   '0xe11ba2b4d45eaed5996cd0823791e0c93114882d',
  //   '0xd03ea8624c8c5987235048901fb614fdca89b117',
  //   '0x95ced938f7991cd0dfcb48f0a06a40fa1af46ebc',
  //   '0x3e5e9111ae8eb78fe1cc3bb8915d5d461f3ef9a9',
  //   '0x28a8746e75304c0780e011bed21c72cd78cd535e',
  //   '0xaca94ef8bd5ffee41947b4585a84bda5a3d3da6e',
  //   '0x1df62f291b2e969fb0849d99d9ce41e2f137006e',
  // ]);

  // await mintTokenBatch(33, [
  //   '0x90f8bf6a479f320ead074411a4b0e7944ea8c9c1',
  //   '0xffcf8fdee72ac11b5c542428b35eef5769c409f0',
  //   '0x22d491bde2303f2f43325b2108d26f1eaba1e32b',
  //   '0xe11ba2b4d45eaed5996cd0823791e0c93114882d',
  //   '0xd03ea8624c8c5987235048901fb614fdca89b117',
  //   '0x95ced938f7991cd0dfcb48f0a06a40fa1af46ebc',
  //   '0x3e5e9111ae8eb78fe1cc3bb8915d5d461f3ef9a9',
  //   '0x28a8746e75304c0780e011bed21c72cd78cd535e',
  //   '0xaca94ef8bd5ffee41947b4585a84bda5a3d3da6e',
  //   '0x1df62f291b2e969fb0849d99d9ce41e2f137006e',
  // ]);

  // await mintTokenBatch(33, [
  //   '0x90f8bf6a479f320ead074411a4b0e7944ea8c9c1',
  //   '0xffcf8fdee72ac11b5c542428b35eef5769c409f0',
  //   '0x22d491bde2303f2f43325b2108d26f1eaba1e32b',
  //   '0xe11ba2b4d45eaed5996cd0823791e0c93114882d',
  //   '0xd03ea8624c8c5987235048901fb614fdca89b117',
  // ]);
  // await mintTokenBatch('14', ['0xea5ce2f9a33d36534ee3409d81322feb3f91ed8a']);
  // await mintTokenBatch('14', [
  //   '0xea5ce2f9a33d36534ee3409d81322feb3f91ed8a',
  //   '0xf6b6f07862a02c85628b3a9688beae07fea9c863',
  // ]);
  // await mintTokenBatch('14', [
  //   '0xea5ce2f9a33d36534ee3409d81322feb3f91ed8a',
  //   '0xf6b6f07862a02c85628b3a9688beae07fea9c863',
  //   '0x9c9c51e479a531e714594ab04db4b79a39662991',
  // ]);

  await printTokens('0x1df62f291b2e969fb0849d99d9ce41e2f137006e');
}

main().catch(err => {
  console.log('Error', err.msg);
  console.log(err);
});
