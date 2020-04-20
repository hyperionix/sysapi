--- Signing Certificates operations
--
-- @module cert
-- @pragma nostrip
setfenv(1, require "sysapi-ns")
require "crypto.crypto-windef"
require "crypto.wintrust-windef"
local wintrust = ffi.load("wintrust")
local crypt = ffi.load("crypt32")
local tinsert = table.insert

local M = SysapiMod("Cert")

TRUST_E_NOSIGNATURE = -2146762496
CERT_E_EXPIRED = -2146762495
CERT_E_REVOKED = -2146762484
TRUST_E_EXPLICIT_DISTRUST = -2146762479
TRUST_E_BAD_DIGEST = -2146869232

local VERIFY_STATUS_TO_STRING = {
  [0] = "Trusted",
  [TRUST_E_NOSIGNATURE] = "NoSignature",
  [CERT_E_EXPIRED] = "Expired",
  [CERT_E_REVOKED] = "Revoked",
  [TRUST_E_EXPLICIT_DISTRUST] = "ExplicitDistrust"
}

local function getSignaturesFromStateData(state)
  local provData = wintrust.WTHelperProvDataFromStateData(state)
  if provData then
  end

  local countSignature = 0
  local signer
  local i = 0
  while true do
    signer = wintrust.WTHelperGetProvSignerFromChain(provData, i, false, 0)
    if signer == nil then
      break
    end

    if signer.csCertChain ~= 0 then
      countSignature = countSignature + 1
    end
    i = i + 1
  end
  if countSignature == 0 then
    return
  end

  local signatures = ffi.new("PCERT_CONTEXT[?]", countSignature)
  local signInd = 0
  i = 0
  while signInd < countSignature do
    signer = wintrust.WTHelperGetProvSignerFromChain(provData, i, false, 0)
    if signer == nil then
      break
    end

    if signer.csCertChain ~= 0 then
      local ctx = crypt.CertDuplicateCertificateContext(signer.pasCertChain[0].pCert)
      if ctx then
        signatures[signInd] = ffi.gc(ctx, crypt.CertFreeCertificateContext)
        signInd = signInd + 1
      end
    end
    i = i + 1
  end

  return signatures, countSignature
end

local function getCertSigner(certCtx)
  local blob = ffi.new("CERT_NAME_BLOB[1]", certCtx.pCertInfo.Subject)
  local size = crypt.CertNameToStrA(X509_ASN_ENCODING, blob, CERT_X500_NAME_STR, nil, 0)

  local certName = ffi.new("char[?]", size)
  crypt.CertNameToStrA(X509_ASN_ENCODING, blob, CERT_X500_NAME_STR, certName, size)
  return ffi.string(certName, size - 1)
end

--- Get information about file signing certificate
-- @param filePath path to the file
-- @return verification status string: `"Trusted"`, `"NoSignature"`, `"Expired"`, `"Revoked"` or `"ExplicitDistrust"`
-- @return array of the string with signers information
-- @function cert.getCertInfo
function M.getCertInfo(filePath)
  -- TODO: maybe we need to consider Crypt* api for doing the same things as it looks like easier
  local fileInfo = ffi.new("WINTRUST_FILE_INFO[1]")
  fileInfo[0].cbStruct = ffi.sizeof("WINTRUST_FILE_INFO")
  fileInfo[0].pcwszFilePath = filePath:toWC()

  local trustData = ffi.new("WINTRUST_DATA[1]")
  trustData[0].cbStruct = ffi.sizeof("WINTRUST_DATA")
  trustData[0].dwUIChoice = WTD_UI_NONE
  trustData[0].fdwRevocationChecks = WTD_REVOKE_WHOLECHAIN
  trustData[0].dwUnionChoice = WTD_CHOICE_FILE
  trustData[0].dwStateAction = WTD_STATEACTION_VERIFY
  trustData[0].dwProvFlags = WTD_SAFER_FLAG
  trustData[0].pFile = fileInfo
  local guid = ffi.new("GUID", WINTRUST_ACTION_GENERIC_VERIFY_V2)
  local status = wintrust.WinVerifyTrust(nil, guid, trustData)
  if status == TRUST_E_NOSIGNATURE then
    return VERIFY_STATUS_TO_STRING[status]
  end

  ffi.gc(
    trustData[0].hWVTStateData,
    function()
      trustData[0].dwStateAction = WTD_STATEACTION_CLOSE
      wintrust.WinVerifyTrust(nil, guid, trustData)
    end
  )

  local signers = {}
  local signatures, cnt = getSignaturesFromStateData(trustData[0].hWVTStateData)
  if signatures then
    for i = 0, cnt - 1 do
      local signerInfo = getCertSigner(signatures[i])
      if signerInfo then
        tinsert(signers, signerInfo)
      end
    end
  end

  return VERIFY_STATUS_TO_STRING[status], signers
end

return M
