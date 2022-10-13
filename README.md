 NFT means non-fungible token
 what this means is..it cant be replaced ie 
 an nft cant be replaced with an nft..like how a dollar can be replaced with a dollar
 it uses ERC721 token
 ERC20 contains a simple mapping of an address..and how much an address holds
 ERC721 has unique ids called token ids , each token id represents a uniques asset
 each token id has a unique owner
 and in addition they have whats called a token uri
 A uri(uniform resource identifier) its a unique indicator of what an asset or token
 looks like and what the attributes are

 PROJECT OVERVIEW
 there will be 3 contracts
 1)basic nft: using erc721 standard

 2)Random ipfs hosted nft:random nft at creation hosted on ipfs

 3) dynamic svg nft:will be 100percent onchain and the nft changes depending on the parameters



 BASIC NFT
 basically we just want to be able to mint an nft on opensea..with ipfs to store 
 metadata , token uris..blah blah blah just basics

 RANDOM IPFS NFT
 so this nft will consist of the following processes
 1)when we mint an nft, we will trigger a chainlink vrf call(yh sounds familiar rii)
 to get us a random number
 2)using that number we will select an nft from the dogs (pug,shiba,st.bernard)
 in order words we will get us a random nft
 3)we will make the dogs have a different popularity eg
 pug will be super rare
 shiba will be sorta rare
 and st bernard will be common
 4)also users will have to pay a certain amount of eth to mint an nft
 5)the owner of the contract can withdraw the eth