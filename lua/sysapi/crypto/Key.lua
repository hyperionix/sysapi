--- Class describes CryptoKey object
--
-- The object could be created directly, use @{Crypto:Key} instead
-- @classmod CryptoKey
-- @pragma nostrip
setfenv(1, require "sysapi-ns")

local CryptoKey = SysapiMod("CryptoKey")
local CryptoKey_MT = {__index = CryptoKey, __call = CryptoKey.new}
local advapi32 = ffi.load("advapi32")

function CryptoKey.new(providerHandle, algo, flags)
  local key = ffi.new("HCRYPTKEY[1]")
  if advapi32.CryptGenKey(providerHandle, algo, flags or 0, key) ~= 0 then
    return setmetatable({handle = ffi.gc(key, advapi32.CryptDestroyKey)[0]}, CryptoKey_MT)
  end
end

function CryptoKey.newFromHandle(keyHandle)
  return setmetatable({handle = keyHandle}, CryptoKey_MT)
end

function CryptoKey.import(providerHandle, blob)
  local keyHandle = ffi.new("HCRYPTKEY[1]", 0)
  if
    advapi32.CryptImportKey(
      providerHandle,
      ffi.cast("char*", blob),
      ffi.sizeof(blob[0]),
      0,
      CRYPT_EXPORTABLE,
      keyHandle
    ) ~= 0
   then
    return setmetatable({handle = ffi.gc(keyHandle, advapi32.CryptDestroyKey)[0]}, CryptoKey_MT)
  end
end

function interp(s, tab)
  return (s:gsub(
    "%%%((%a%w*)%)([-0-9%.]*[cdeEfgGiouxXsq])",
    function(k, fmt)
      return tab[k] and ("%" .. fmt):format(tab[k]) or "%(" .. k .. ")" .. fmt
    end
  ))
end

local function createType(bitlen)
  local privTypeName = ("PPRIVATEKEYBLOB_${bitlen}"):interpolate({bitlen = bitlen})
  pcall(
    ffi.cdef,
    ([[
    typedef struct {
      BYTE modulus[${bitlen8}];
      BYTE prime1[${bitlen16}];
      BYTE prime2[${bitlen16}];
      BYTE exponent1[${bitlen16}];
      BYTE exponent2[${bitlen16}];
      BYTE coefficient[${bitlen16}];
      BYTE privateExponent[${bitlen8}];
    } ${privTypeName}, *P${privTypeName};
  ]]):interpolate(
      {privTypeName = privTypeName, bitlen = bitlen, bitlen8 = bitlen / 8, bitlen16 = bitlen / 16}
    )
  )

  local typeName = ("PRIVATEKEYBLOB_${bitlen}"):interpolate({bitlen = bitlen})
  pcall(
    ffi.cdef,
    ([[
    typedef struct {
      PUBLICKEYSTRUC hdr;
      RSAPUBKEY pubkey;
      ${privTypeName} priv;
    } ${typeName}, *P${typeName};
    ]]):interpolate(
      {privTypeName = privTypeName, typeName = typeName}
    )
  )
  return typeName
end

--- Export key to a binary blob
-- @param blobType key blob type - `CryptExportKey` `dwBlobType` parameter
-- @return typed pointer or string depending on `blobType`
function CryptoKey:export(blobType)
  local size = ffi.new("DWORD[1]", 0)
  if advapi32.CryptExportKey(self.handle, 0, blobType, 0, nil, size) ~= 0 then
    size[0] = size[0] * 2
    local blob = ffi.new("BYTE[?]", size[0])
    if advapi32.CryptExportKey(self.handle, 0, blobType, 0, blob, size) ~= 0 then
      if blobType == PLAINTEXTKEYBLOB then
        return ffi.cast("PPLAINTEXTKEYBLOB", blob)
      elseif blobType == PRIVATEKEYBLOB then
        local b = ffi.cast("PPRIVATEKEYBLOB", blob)
        local typeName = createType(b.pubkey.bitlen)
        return ffi.cast(typeName .. "*", blob)
      else
        return ffi.string(blob, size[0])
      end
    end
  end
end

return CryptoKey
