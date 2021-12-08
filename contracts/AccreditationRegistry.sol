pragma solidity ^0.5.0;

import "zos-lib/contracts/Initializable.sol";
import "openzeppelin-eth/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-eth/contracts/token/ERC721/ERC721Enumerable.sol";
import "openzeppelin-eth/contracts/token/ERC721/IERC721Metadata.sol";
import "./AccreditationRoles.sol";
import "./AccreditationPausable.sol";


// Desired Features
// - Add Accreditation
// - Add Accreditator
// - Mint token for an accreditation
// - Batch Mint
// - Burn Tokens (only admin?)
// - Pause contract (only admin)
// - ERC721 full interface (base, metadata, enumerable)

contract Accreditation is Initializable, ERC721, ERC721Enumerable, AccreditationRoles, AccreditationPausable {
    event AccreditationToken(uint256 accreditationId, uint256 tokenId);

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Base token URI
    string private _baseURI;

    // Last Used id (used to generate new ids)
    uint256 private lastId;

    // AccreditationId for each token
    mapping(uint256 => uint256) private _tokenAccreditationId;


    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    /**
     * @dev Gets the token name
     * @return string representing the token name
     */
    function name() external view returns (string memory) {
        return _name;
    }

    /**
     * @dev Gets the token symbol
     * @return string representing the token symbol
     */
    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function tokenAccreditation(uint256 tokenId) public view returns (uint256) {
        return _tokenAccreditationId[tokenId];
    }

    /**
     * @dev Gets the token ID at a given index of the tokens list of the requested owner
     * @param owner address owning the tokens list to be accessed
     * @param index uint256 representing the index to be accessed of the requested tokens list
     * @return uint256 token ID at the given index of the tokens list owned by the requested address
     */
    function tokenDetailsOfOwnerByIndex(address owner, uint256 index) public view returns (uint256 tokenId, uint256 accreditationId) {
        tokenId = tokenOfOwnerByIndex(owner, index);
        accreditationId = tokenAccreditation(tokenId);
    }

    /**
     * @dev Gets the token uri
     * @return string representing the token uri
     */
    function tokenURI(uint256 tokenId) external view returns (string memory) {
        uint accreditationId = _tokenAccreditationId[tokenId];
        return _strConcat(_baseURI, _uint2str(accreditationId), "/", _uint2str(tokenId), "");
    }

    function setBaseURI(string memory baseURI) public onlyAdmin whenNotPaused {
        _baseURI = baseURI;
    }

    function approve(address to, uint256 tokenId) public whenNotPaused {
        super.approve(to, tokenId);
    }

    function setApprovalForAll(address to, bool approved) public whenNotPaused {
        super.setApprovalForAll(to, approved);
    }

    function transferFrom(address from, address to, uint256 tokenId) public whenNotPaused {
        super.transferFrom(from, to, tokenId);
    }

    /**
     * @dev Function to mint tokens
     * @param accreditationId AccreditationId for the new token
     * @param to The address that will receive the minted tokens.
     * @return A boolean that indicates if the operation was successful.
     */
    function mintToken(uint256 accreditationId, address to)
    public whenNotPaused onlyAccreditationMinter(accreditationId) returns (bool)
    {
        lastId += 1;
        return _mintToken(accreditationId, lastId, to);
    }

    /**
     * @dev Function to mint tokens with a specific id
     * @param accreditationId AccreditationId for the new token
     * @param tokenId TokenId for the new token
     * @param to The address that will receive the minted tokens.
     * @return A boolean that indicates if the operation was successful.
     */
    function mintToken(uint256 accreditationId, uint256 tokenId, address to)
    public whenNotPaused onlyAccreditationMinter(accreditationId) returns (bool)
    {
        return _mintToken(accreditationId, tokenId, to);
    }


    /**
     * @dev Function to mint tokens
     * @param accreditationId AccreditationId for the new token
     * @param to The address that will receive the minted tokens.
     * @return A boolean that indicates if the operation was successful.
     */
    function mintAccreditationToManyUsers(uint256 accreditationId, address[] memory to)
    public whenNotPaused onlyAccreditationMinter(accreditationId) returns (bool)
    {
        for (uint256 i = 0; i < to.length; ++i) {
            _mintToken(accreditationId, lastId + 1 + i, to[i]);
        }
        lastId += to.length;
        return true;
    }

    /**
     * @dev Function to mint tokens
     * @param accreditationIds AccreditationIds to assing to user
     * @param to The address that will receive the minted tokens.
     * @return A boolean that indicates if the operation was successful.
     */
    function mintUserToManyAccreditations(uint256[] memory accreditationIds, address to)
    public whenNotPaused onlyAdmin() returns (bool)
    {
        for (uint256 i = 0; i < accreditationIds.length; ++i) {
            _mintToken(accreditationIds[i], lastId + 1 + i, to);
        }
        lastId += accreditationIds.length;
        return true;
    }

    /**
     * @dev Burns a specific ERC721 token.
     * @param tokenId uint256 id of the ERC721 token to be burned.
     */
    function burn(uint256 tokenId) public {
        require(_isApprovedOrOwner(msg.sender, tokenId) || isAdmin(msg.sender));
        _burn(tokenId);
    }

    function initialize(string memory __name, string memory __symbol, string memory __baseURI, address[] memory admins)
    public initializer
    {
        ERC721.initialize();
        ERC721Enumerable.initialize();
        AccreditationRoles.initialize(msg.sender);
        AccreditationPausable.initialize();

        // Add the requested admins
        for (uint256 i = 0; i < admins.length; ++i) {
            _addAdmin(admins[i]);
        }

        _name = __name;
        _symbol = __symbol;
        _baseURI = __baseURI;

        // register the supported interfaces to conform to ERC721 via ERC165
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
    }

    /**
     * @dev Internal function to burn a specific token
     * Reverts if the token does not exist
     *
     * @param owner owner of the token to burn
     * @param tokenId uint256 ID of the token being burned by the msg.sender
     */
    function _burn(address owner, uint256 tokenId) internal {
        super._burn(owner, tokenId);

        delete _tokenAccreditationId[tokenId];
    }

    /**
     * @dev Function to mint tokens
     * @param accreditationId AccreditationId for the new token
     * @param tokenId The token id to mint.
     * @param to The address that will receive the minted tokens.
     * @return A boolean that indicates if the operation was successful.
     */
    function _mintToken(uint256 accreditationId, uint256 tokenId, address to) internal returns (bool) {
        // TODO Verify that the token receiver ('to') do not have already a token for the event ('accreditationId')
        _mint(to, tokenId);
        _tokenAccreditationId[tokenId] = accreditationId;
        emit AccreditationToken(accreditationId, tokenId);
        return true;
    }

    /**
     * @dev Function to convert uint to string
     * Taken from https://github.com/oraclize/ethereum-api/blob/master/oraclizeAPI_0.5.sol
     */
    function _uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }

    /**
     * @dev Function to concat strings
     * Taken from https://github.com/oraclize/ethereum-api/blob/master/oraclizeAPI_0.5.sol
     */
    function _strConcat(string memory _a, string memory _b, string memory _c, string memory _d, string memory _e)
    internal pure returns (string memory _concatenatedString)
    {
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        bytes memory _bc = bytes(_c);
        bytes memory _bd = bytes(_d);
        bytes memory _be = bytes(_e);
        string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
        bytes memory babcde = bytes(abcde);
        uint k = 0;
        uint i = 0;
        for (i = 0; i < _ba.length; i++) {
            babcde[k++] = _ba[i];
        }
        for (i = 0; i < _bb.length; i++) {
            babcde[k++] = _bb[i];
        }
        for (i = 0; i < _bc.length; i++) {
            babcde[k++] = _bc[i];
        }
        for (i = 0; i < _bd.length; i++) {
            babcde[k++] = _bd[i];
        }
        for (i = 0; i < _be.length; i++) {
            babcde[k++] = _be[i];
        }
        return string(babcde);
    }

    function removeAdmin(address account) public onlyAdmin {
        _removeAdmin(account);
    }

}
