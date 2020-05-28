setfenv(1, require "sysapi-ns")
local Crypto = require "crypto.crypto"
local cert = require "crypto.cert"
local stringify = require "utils.stringify"
local crypto = Crypto.new()

local hash = crypto:Hash("md5")
hash:update("foo")
print(hash:hexdigest())

local hash = crypto:Hash("sha1")
hash:update("foo")
print(hash:hexdigest())

local hash = crypto:Hash("sha256")
hash:update("foo")
print(hash:hexdigest())

local status, signers = cert.getCertInfo([[C:\windows\system32\drivers\acpi.sys]])
print(status)
for i = 1, #signers do
  print(signers[i])
end

local function testKey(algo, blobType, blobCheck)
  local key = crypto:Key(algo, CRYPT_EXPORTABLE)
  assert(key)
  local blob = key:export(blobType)
  assert(blob)
  blobCheck(blob)
end

testKey(
  CALG_RC4,
  PLAINTEXTKEYBLOB,
  function(blob)
    assert(blob.hdr.bType == PLAINTEXTKEYBLOB)
    assert(blob.hdr.aiKeyAlg == CALG_RC4)
    assert(blob.dwKeySize == 16)
  end
)

testKey(
  CALG_AES_256,
  PLAINTEXTKEYBLOB,
  function(blob)
    assert(blob.hdr.bType == PLAINTEXTKEYBLOB)
    assert(blob.hdr.aiKeyAlg == CALG_AES_256)
    assert(blob.dwKeySize, 256 / 8)
  end
)

testKey(
  CALG_RSA_KEYX,
  PRIVATEKEYBLOB,
  function(blob)
    assert(blob.hdr.bType == PRIVATEKEYBLOB)
    assert(blob.hdr.aiKeyAlg == CALG_RSA_KEYX)
    assert(blob.pubkey.bitlen == 1024)
  end
)
