--- Class describes Crypto object
--
-- @classmod Crypto
-- @pragma nostrip
setfenv(1, require "sysapi-ns")
require "crypto.crypto-windef"
local Hash = require "crypto.Hash"
local Key = require "crypto.Key"
local bor = bit.bor

local advapi32 = ffi.load("advapi32")

local Crypto = SysapiMod("Crypto")
local Crypto_MT = {__index = Crypto}

local function releaseContext(handle)
  advapi32.CryptReleaseContext(handle[0], 0)
end

--- Create new Crypto object
-- @param[opt=PROV_RSA_AES] providerType ***[Provider Type](https://docs.microsoft.com/ru-ru/windows/win32/seccrypto/cryptographic-provider-types)***
-- @return New Crypto object
function Crypto.new(providerType)
  local prov = ffi.new("HCRYPTPROV[1]")
  if advapi32.CryptAcquireContextA(prov, nil, nil, providerType or PROV_RSA_AES, CRYPT_VERIFYCONTEXT) then
    return setmetatable({handle = ffi.gc(prov, releaseContext)[0]}, Crypto_MT)
  end
end

--- Create new Crypto object from valid provider handle
-- @param handle HCRYPTPROV object
-- @return New Crypto object
function Crypto.fromHandle(handle)
  return setmetatable({handle = handle}, Crypto_MT)
end

--- Create new @{CryptoHash} object
-- @param hashName name of the hash, could be `"md5"`, `"sha1"`or `"sha256"`
-- @return new @{CryptoHash} object
function Crypto:Hash(hashName)
  return Hash.new(self.handle, hashName)
end

function Crypto.isSupportedHash(name)
  return Hash.isSupported(name)
end

--- Generate new {@CryptoKey} object
-- @param algo CryptGenKey algId parameter
-- @param flags default 0 or dwFlags of CryptGenKey
-- @return new @{CryptoKey} object
function Crypto:Key(algo, flags)
  return Key.new(self.handle, algo, flags)
end

--- Initialize new {@CryptoKey} object from existing key handle
-- @param handle key handle
-- @return new @{CryptoKey} object
function Crypto:KeyFromHandle(handle)
  return Key.newFromHandle(handle)
end

--- Import key blob
-- @param blob key blob data
-- @return new @{CryptoKey} object
function Crypto:KeyImport(blob)
  return Key.import(self.handle, blob)
end

return Crypto
