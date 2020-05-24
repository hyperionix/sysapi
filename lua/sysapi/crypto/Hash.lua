--- Class describes CryptoHash object
--
-- The object could be created directly, use @{Crypto:Hash} instead
-- @classmod CryptoHash
-- @pragma nostrip
setfenv(1, require "sysapi-ns")
local stringify = require "utils.stringify"

local CryptoHash = SysapiMod("CryptoHash")
local CryptoHash_MT = {__index = CryptoHash, __call = CryptoHash.new}
local advapi32 = ffi.load("advapi32")

local HASH_NAME_TO_ID = {
  md5 = CALG_MD5,
  sha1 = CALG_SHA1,
  sha256 = CALG_SHA_256
}

local function destroyHash(hashHandle)
  advapi32.CryptDestroyHash(hashHandle[0])
end

function CryptoHash.new(providerHandle, hashName)
  if not HASH_NAME_TO_ID[hashName] then
    error("invalid name of the hash: " .. hashName)
  end

  local hashHandlePtr = ffi.new("HCRYPTHASH[1]")
  if advapi32.CryptCreateHash(providerHandle, HASH_NAME_TO_ID[hashName], 0, 0, hashHandlePtr) then
    return setmetatable({handle = ffi.gc(hashHandlePtr, destroyHash)[0]}, CryptoHash_MT)
  end
end

function CryptoHash.isSupported(name)
  return HASH_NAME_TO_ID[name] ~= nil
end

--- Update CryptoHash object hash value with data
function CryptoHash:update(data, size)
  if type(data) == "string" then
    size = #data
  else
    assert(size, "missing `size` parameter")
  end

  advapi32.CryptHashData(self.handle, data, size, 0)
  return self
end

--- Return the digest of the hash
-- @return byte buffer of hash value
-- @return size of the buffer
function CryptoHash:digest()
  if not self.hashLen then
    local hashLen = ffi.new("ULONG[1]", 0)
    local hashLenSize = ffi.new("ULONG[1]", ffi.sizeof("ULONG"))
    if advapi32.CryptGetHashParam(self.handle, HP_HASHSIZE, ffi.cast("BYTE*", hashLen), hashLenSize, 0) then
      self.hashLen = hashLen[0]
    end
  end

  if self.hashData then
    return self.hashData, self.hashLen
  end

  local hashLen = ffi.new("ULONG[1]", self.hashLen)
  local hashData = ffi.new("BYTE[?]", self.hashLen)
  if advapi32.CryptGetHashParam(self.handle, HP_HASHVAL, hashData, hashLen, 0) then
    self.hashData = hashData
    return hashData, hashLen
  end
end

--- Return hex string representation
-- @return hex string of the hash value
function CryptoHash:hexdigest()
  if not self.hashData then
    self:digest()
  end

  return stringify.byteBuffer(self.hashData or nil, self.hashLen)
end

return CryptoHash
