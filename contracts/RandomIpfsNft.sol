//SPDX-License-Identifier: MIT

pragma solidity 0.8.8;
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

error RandomIpfsNft__RangeOutOfBounds();
error RandomIpfsNft__NeedMoreEthSent();
error RandomIpfsNft__TransferFailed();


contract RandomIpfsNft is VRFConsumerBaseV2 , ERC721URIStorage , Ownable{
    //Type Declarations
    enum Breed{
        PUG,
        SHIBA_INU,
        ST_BERNARD
    }

    //chainlink VRF variables
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator; 
    uint64 private immutable i_subscriptionId;
    bytes32 private immutable i_gasLane;
    uint32 private immutable i_callbackGasLimit;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;  
    
    //vrf helpers
    mapping(uint256 => address)public s_requestIdToSender;

    //NFT variables
    uint256 public s_tokenCounter;
    uint256 internal constant MAX_CHANCE_VALUE = 100;'
    string[] internal s_dogTokenUris;
    uint256 internal i_mintFee;

    //events
    event NftRequested(uint256 indexed requestId , address requester);
    event NftMinted(Breed dogBreed , address minter);

    constructor(
        address vrfCoordinatorV2,
        uint64 subscriptionId,
        bytes32 gasLane,
        uint32 callbackGasLimit,
        string[3] memory dogTokenUris,
        uint256 mintFee
    ) VRFConsumerBaseV2(vrfCoordinatorV2) ERC721("RandomIpfsNft", "RIN"){
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
        i_subscriptionId =subscriptionId;
        i_gasLane = gasLane;
        i_callbackGasLimit = callbackGasLimit;
        s_dogTokenUris = dogTokenUris;
        i_mintFee = mintFee;
    }
    function requestNft() public payable returns (uint256 requestId){
        if (msg.value < i_mintFee){
            revert RandomIpfsNft__NeedMoreEthSent();
        }
        requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQUEST_CONFIRMATIONS,
            i_callbackGasLimit,
            NUM_WORDS
        );
        //the code below is saying that the person who called the requestId
        //will automatically become the msg.sender
        s_requestIdToSender[requestId] = msg.sender;
        emit NftRequested(requestId , msg.sender);
    }

    function fulfillRandomWords(
        uint256 requestId , 
        uint256[] memory randomWords
    )
        internal,
        override{
            address dogOwner = s_requestIdToSender[requestId];
            uint256 newTokenId = s_tokenCounter;
            uint256 moddedRng = randomWords[0] % MAX_CHANCE_VALUE;
            //so in this case..modded rng is the random word from chainlink % maxchancevalue which is 100
            //that means modded rng is goin to be from 0-99
            //so rn what we are goin to do is set the value so if the number is
            //0-10 = pug
            //11-30 = shiba inu
            // 31 - 99 = st bernard
            //this shows rarity

            Breed dogBreed = getBreedfromModdedRng(moddedRng);
            s_tokenCounter += s_tokenCounter;
            _safeMint(dogOwner , newTokenId);
            _setTokenURI(newTokenId , s_dogTokenUris[uint256(dogBreed)]);
            emit NftMinted(dogBreed , dogOwner);

        }

    function withdraw() public onlyOwner(){
        uint256 amount = address(this).balance;
        (bool success , ) = payable(msg.sender).call{value: amount}("");
        if(!success){ 
            revert error RandomIpfsNft__TransferFailed();
        }
    }
    
    function getBreedfromModdedRng(uint256 moddedRng) public pure returns (Breed){
        uint256 cumulativeSum = 0;
        uint256[3] memory chanceArray = getChanceArray();
        
        for (uint256 i =0; i < chanceArray.length; i++){
            if(moddedRng >= cumulativeSum && moddedRng < cumulativeSum + chanceArray[i]){
                return Breed(i);
            }
            cumulativeSum += chanceArray[i]; 
        }
        revert RandomIpfsNft__RangeOutOfBounds();
    }

    function getChanceArray()public pure returns (uint256[3] memory) {
        return [10 , 30 ,MAX_CHANCE_VALUE];
    }

    function getMintFee() public view returns(uint256){
        return i_mintFee;
    }
    
    function getDogTokenUris(uint256 index) public view returns (string memory) {
        return s_dogTokenUris[index];
    }

    function getTokenCounter() public view returns (uint256){
        return s_tokenCounter;
    }
}