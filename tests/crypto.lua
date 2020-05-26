setfenv(1, require "sysapi-ns")
local Crypto = require "crypto.crypto"
local cert = require "crypto.cert"
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

local key = crypto:genKeyPair(CALG_RSA_KEYX)
local k = crypto:exportKey(key, PRIVATEKEYBLOB)
print(#k)
