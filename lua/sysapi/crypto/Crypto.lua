--- Class describes Crypto object
--
-- @classmod Crypto
-- @pragma nostrip
setfenv(1, require "sysapi-ns")
require "crypto.crypto-windef"
local Hash = require "crypto.Hash"
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

--- Create new @{CryptoHash} object
-- @param hashName name of the hash, could be `"md5"`, `"sha1"`or `"sha256"`
-- @return new @{CryptoHash} object
function Crypto:Hash(hashName)
  return Hash.new(self.handle, hashName)
end

function Crypto:genKeyPair(algo)
  local key = ffi.new("HCRYPTKEY[1]")
  if advapi32.CryptGenKey(self.handle, algo, bor(0x08000000, CRYPT_EXPORTABLE), key) ~= 0 then
    return ffi.gc(key, advapi32.CryptDestroyKey)[0]
  end
end

function Crypto:exportKey(key, keyType)
  local size = ffi.new("DWORD[1]", 0)
  if advapi32.CryptExportKey(key, 0, keyType, 0, nil, size) ~= 0 then
    local blob = ffi.new("BYTE[?]", size[0])
    if advapi32.CryptExportKey(key, 0, keyType, 0, blob, size) ~= 0 then
      return ffi.string(blob, size[0])
    end
  end
end

function Crypto.isSupportedHash(name)
  return Hash.isSupported(name)
end

return Crypto
