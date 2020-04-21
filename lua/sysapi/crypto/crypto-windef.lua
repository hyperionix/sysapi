setfenv(1, require "sysapi-ns")

DECLARE_HANDLE("HWND")

-- Crypto algorithms identifiers
-- https://docs.microsoft.com/ru-ru/windows/desktop/SecCrypto/alg-id

CALG_MD2 = 0x00008001
CALG_MD4 = 0x00008002
CALG_MD5 = 0x00008003
CALG_SHA = 0x00008004
CALG_SHA1 = 0x00008004
CALG_RSA_SIGN = 0x00002400
CALG_DSS_SIGN = 0x00002200
CALG_NO_SIGN = 0x00002000
CALG_RSA_KEYX = 0x0000a400
CALG_DES = 0x00006601
CALG_3DES_112 = 0x00006609
CALG_3DES = 0x00006603
CALG_DESX = 0x00006604
CALG_RC2 = 0x00006602
CALG_RC4 = 0x00006801
CALG_SEAL = 0x00006802 -- Not supported
CALG_DH_SF = 0x0000aa01
CALG_DH_EPHEM = 0x0000aa02
CALG_AGREEDKEY_ANY = 0x0000aa03
CALG_MAC = 0x00008005
CALG_HUGHES_MD5 = 0x0000a003
CALG_SKIPJACK = 0x0000660a -- Not supported
CALG_TEK = 0x0000660b -- Not supported
CALG_RC5 = 0x0000660d
CALG_HMAC = 0x00008009
CALG_HASH_REPLACE_OWF = 0x0000800b
CALG_AES_128 = 0x0000660e
CALG_AES_192 = 0x0000660f
CALG_AES_256 = 0x00006610
CALG_AES = 0x00006611
CALG_SHA_256 = 0x0000800c
CALG_SHA_384 = 0x0000800d
CALG_SHA_512 = 0x0000800e
CALG_ECDH = 0x0000aa05
CALG_ECDH_EPHEM = 0x0000ae06
CALG_ECMQV = 0x0000a001 -- Not supported
CALG_KEA_KEYX = 0x0000aa04 -- Not supported
CALG_ECDSA = 0x00002203

-- Cryptographic Provider Types
-- https://docs.microsoft.com/ru-ru/windows/desktop/SecCrypto/cryptographic-provider-types

PROV_RSA_FULL = 1
PROV_RSA_SIG = 2
PROV_DSS = 3
PROV_FORTEZZA = 4
PROV_MS_EXCHANGE = 5
PROV_SSL = 6
PROV_RSA_SCHANNEL = 12
PROV_DSS_DH = 13
PROV_DH_SCHANNEL = 18
PROV_RSA_AES = 24

-- Flags for CryptAcquireContext
-- https://docs.microsoft.com/en-us/windows/desktop/api/wincrypt/nf-wincrypt-cryptacquirecontexta

CRYPT_VERIFYCONTEXT = 0xF0000000
CRYPT_NEWKEYSET = 0x00000008
CRYPT_DELETEKEYSET = 0x00000010
CRYPT_MACHINE_KEYSET = 0x00000020
CRYPT_SILENT = 0x00000040
CRYPT_DEFAULT_CONTAINER_OPTIONAL = 0x00000080

-- Parameters for CryptGetHashParam
-- https://docs.microsoft.com/en-us/windows/desktop/api/wincrypt/nf-wincrypt-cryptgethashparam

HP_ALGID = 0x0001
HP_HASHVAL = 0x0002
HP_HASHSIZE = 0x0004
HP_HMAC_INFO = 0x0005
HP_TLS1PRF_LABEL = 0x0006
HP_TLS1PRF_SEED = 0x0007

-- The following RIDs are used to specify mandatory integrity level
StringifyTableStart("SECURITY_MANDATORY", "SECURITY_MANDATORY_", "_RID")
SECURITY_MANDATORY_UNTRUSTED_RID = 0x00000000
SECURITY_MANDATORY_LOW_RID = 0x00001000
SECURITY_MANDATORY_MEDIUM_RID = 0x00002000
SECURITY_MANDATORY_MEDIUM_PLUS_RID = SECURITY_MANDATORY_MEDIUM_RID + 0x100
SECURITY_MANDATORY_HIGH_RID = 0x00003000
SECURITY_MANDATORY_SYSTEM_RID = 0x00004000
SECURITY_MANDATORY_PROTECTED_PROCESS_RID = 0x00005000
StringifyTableEnd()

LANG_ENGLISH = 0x09
SUBLANG_ENGLISH_US = 0x01

-- Certificate encoding types
X509_ASN_ENCODING = 0x00000001
X509_NDR_ENCODING = 0x00000002

-- Certificate name string types
CERT_SIMPLE_NAME_STR = 1
CERT_OID_NAME_STR = 2
CERT_X500_NAME_STR = 3
CERT_XML_NAME_STR = 4

-- Type of object for which trust will be verified
WTD_CHOICE_FILE = 1
WTD_CHOICE_CATALOG = 2
WTD_CHOICE_BLOB = 3
WTD_CHOICE_SIGNER = 4
WTD_CHOICE_CERT = 5

WTD_UI_ALL = 1
WTD_UI_NONE = 2
WTD_UI_NOBAD = 3
WTD_UI_NOGOOD = 4

WTD_REVOKE_NONE = 0x00000000
WTD_REVOKE_WHOLECHAIN = 0x00000001

WTD_STATEACTION_IGNORE = 0x00000000
WTD_STATEACTION_VERIFY = 0x00000001
WTD_STATEACTION_CLOSE = 0x00000002
WTD_STATEACTION_AUTO_CACHE = 0x00000003
WTD_STATEACTION_AUTO_CACHE_FLUSH = 0x00000004

WTD_PROV_FLAGS_MASK = 0x0000FFFF
WTD_USE_IE4_TRUST_FLAG = 0x00000001
WTD_NO_IE4_CHAIN_FLAG = 0x00000002
WTD_NO_POLICY_USAGE_FLAG = 0x00000004
WTD_REVOCATION_CHECK_NONE = 0x00000010
WTD_REVOCATION_CHECK_END_CERT = 0x00000020
WTD_REVOCATION_CHECK_CHAIN = 0x00000040
WTD_REVOCATION_CHECK_CHAIN_EXCLUDE_ROOT = 0x00000080
WTD_SAFER_FLAG = 0x00000100
WTD_HASH_ONLY_FLAG = 0x00000200
WTD_USE_DEFAULT_OSVER_CHECK = 0x00000400
WTD_LIFETIME_SIGNING_FLAG = 0x00000800
WTD_CACHE_ONLY_URL_RETRIEVAL = 0x00001000
WTD_DISABLE_MD2_MD4 = 0x00002000
WTD_MOTW = 0x00004000
WTD_CODE_INTEGRITY_DRIVER_MODE = 0x00008000

WINTRUST_ACTION_GENERIC_VERIFY_V2 = {
  0xaac56b,
  0xcd44,
  0x11d0,
  {0x8c, 0xc2, 0x0, 0xc0, 0x4f, 0xc2, 0x95, 0xee}
}

ffi.cdef [[
  typedef ULONG_PTR HCRYPTPROV;
  typedef ULONG_PTR HCRYPTHASH;
  typedef UINT ALG_ID;
]]

ffi.cdef [[
  BOOL CryptAcquireContextA(
    HCRYPTPROV *phProv,
    LPCSTR     szContainer,
    LPCSTR     szProvider,
    DWORD      dwProvType,
    DWORD      dwFlags
  );

  BOOL CryptReleaseContext(
      HCRYPTPROV hProv,
      DWORD      dwFlags
  );

  BOOL CryptCreateHash(
    HCRYPTPROV hProv,
    ALG_ID     Algid,
    ULONG_PTR  hKey,
    DWORD      dwFlags,
    HCRYPTHASH *phHash
  );

  BOOL CryptDestroyHash(
    HCRYPTHASH hHash
  );

  BOOL CryptHashData(
    HCRYPTHASH hHash,
    const BYTE *pbData,
    DWORD      dwDataLen,
    DWORD      dwFlags
  );

  BOOL CryptGetHashParam(
    HCRYPTHASH hHash,
    DWORD      dwParam,
    BYTE       *pbData,
    DWORD      *pdwDataLen,
    DWORD      dwFlags
  );

]]
