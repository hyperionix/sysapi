setfenv(1, require "sysapi-ns")

ffi.cdef [[
  typedef struct _CRYPTOAPI_BLOB {
    DWORD   cbData;
    BYTE    *pbData;
  } CRYPT_INTEGER_BLOB, *PCRYPT_INTEGER_BLOB, CRYPT_OBJID_BLOB, *PCRYPT_OBJID_BLOB,
  CRYPT_DATA_BLOB, *PCRYPT_DATA_BLOB, CERT_NAME_BLOB, *PCERT_NAME_BLOB,
  CRYPT_ATTR_BLOB, *PCRYPT_ATTR_BLOB;

  typedef struct _CRYPT_BIT_BLOB {
      DWORD cbData;
      BYTE  *pbData;
      DWORD cUnusedBits;
  } CRYPT_BIT_BLOB, *PCRYPT_BIT_BLOB;

  typedef struct _CERT_STRONG_SIGN_SERIALIZED_INFO {
      DWORD  dwFlags;
      LPWSTR pwszCNGSignHashAlgids;
      LPWSTR pwszCNGPubKeyMinBitLengths;
  } CERT_STRONG_SIGN_SERIALIZED_INFO, *PCERT_STRONG_SIGN_SERIALIZED_INFO;

  typedef struct _CERT_STRONG_SIGN_PARA {
      DWORD cbSize;
      DWORD dwInfoChoice;
      union {
        void                              *pvInfo;
        PCERT_STRONG_SIGN_SERIALIZED_INFO pSerializedInfo;
        LPSTR                             pszOID;
      } DUMMYUNIONNAME;
  } CERT_STRONG_SIGN_PARA, *PCERT_STRONG_SIGN_PARA;

  typedef struct WINTRUST_SIGNATURE_SETTINGS_ {
      DWORD                  cbStruct;
      DWORD                  dwIndex;
      DWORD                  dwFlags;
      DWORD                  cSecondarySigs;
      DWORD                  dwVerifiedSigIndex;
      PCERT_STRONG_SIGN_PARA pCryptoPolicy;
  } WINTRUST_SIGNATURE_SETTINGS, *PWINTRUST_SIGNATURE_SETTINGS;

  typedef struct _WINTRUST_DATA {
      DWORD                       cbStruct;
      PVOID                       pPolicyCallbackData;
      PVOID                       pSIPClientData;
      DWORD                       dwUIChoice;
      DWORD                       fdwRevocationChecks;
      DWORD                       dwUnionChoice;
      union {
        struct WINTRUST_FILE_INFO_  *pFile;
        struct WINTRUST_CATALOG_INFO_  *pCatalog;
        struct WINTRUST_BLOB_INFO_  *pBlob;
        struct WINTRUST_SGNR_INFO_  *pSgnr;
        struct WINTRUST_CERT_INFO_  *pCert;
      };
      DWORD                       dwStateAction;
      HANDLE                      hWVTStateData;
      WCHAR                       *pwszURLReference;
      DWORD                       dwProvFlags;
      DWORD                       dwUIContext;
      WINTRUST_SIGNATURE_SETTINGS *pSignatureSettings;
  } WINTRUST_DATA, *PWINTRUST_DATA;

  typedef struct _CRYPT_PROVUI_DATA {
      DWORD cbStruct;
      DWORD dwFinalError;
      WCHAR *pYesButtonText;
      WCHAR *pNoButtonText;
      WCHAR *pMoreInfoButtonText;
      WCHAR *pAdvancedLinkText;
      WCHAR *pCopyActionText;
      WCHAR *pCopyActionTextNoTS;
      WCHAR *pCopyActionTextNotSigned;
  } CRYPT_PROVUI_DATA, *PCRYPT_PROVUI_DATA;

  typedef struct _CRYPT_PROVUI_FUNCS {
      DWORD             cbStruct;
      CRYPT_PROVUI_DATA *psUIData;
      PVOID              pfnOnMoreInfoClick;
      PVOID              pfnOnMoreInfoClickDefault;
      PVOID              pfnOnAdvancedClick;
      PVOID              pfnOnAdvancedClickDefault;
  } CRYPT_PROVUI_FUNCS, *PCRYPT_PROVUI_FUNCS;

  typedef struct {
    DWORD                        cbStruct;
    PVOID                        pfnAlloc;
    PVOID                        pfnFree;
    PVOID                        pfnAddStore2Chain;
    PVOID                        pfnAddSgnr2Chain;
    PVOID                        pfnAddCert2Chain;
    PVOID                        pfnAddPrivData2Chain;
    PVOID                        pfnInitialize;
    PVOID                        pfnObjectTrust;
    PVOID                        pfnSignatureTrust;
    PVOID                        pfnCertificateTrust;
    PVOID                        pfnFinalPolicy;
    PVOID                        pfnCertCheckPolicy;
    PVOID                        pfnTestFinalPolicy;
    struct _CRYPT_PROVUI_FUNCS  *psUIpfns;
    PVOID                        pfnCleanupPolicy;
  } CRYPT_PROVIDER_FUNCTIONS, *PCRYPT_PROVIDER_FUNCTIONS;

  typedef void *HCERTSTORE;
  typedef void *HCRYPTMSG;

  typedef struct _CTL_CONTEXT {
    DWORD      dwMsgAndCertEncodingType;
    BYTE       *pbCtlEncoded;
    DWORD      cbCtlEncoded;
    PVOID      pCtlInfo;
    HCERTSTORE hCertStore;
    HCRYPTMSG  hCryptMsg;
    BYTE       *pbCtlContent;
    DWORD      cbCtlContent;
  } CTL_CONTEXT, *PCTL_CONTEXT; typedef const CTL_CONTEXT *PCCTL_CONTEXT;

  typedef struct _CERT_TRUST_STATUS {
      DWORD dwErrorStatus;
      DWORD dwInfoStatus;
  } CERT_TRUST_STATUS, *PCERT_TRUST_STATUS;

  typedef struct _CRYPT_ALGORITHM_IDENTIFIER {
      LPSTR            pszObjId;
      CRYPT_OBJID_BLOB Parameters;
  } CRYPT_ALGORITHM_IDENTIFIER, *PCRYPT_ALGORITHM_IDENTIFIER;

  typedef struct _CERT_PUBLIC_KEY_INFO {
      CRYPT_ALGORITHM_IDENTIFIER Algorithm;
      CRYPT_BIT_BLOB             PublicKey;
  } CERT_PUBLIC_KEY_INFO, *PCERT_PUBLIC_KEY_INFO;

  typedef struct _CERT_EXTENSION {
      LPSTR            pszObjId;
      BOOL             fCritical;
      CRYPT_OBJID_BLOB Value;
  } CERT_EXTENSION, *PCERT_EXTENSION;

  typedef struct _CERT_INFO {
      DWORD                      dwVersion;
      CRYPT_INTEGER_BLOB         SerialNumber;
      CRYPT_ALGORITHM_IDENTIFIER SignatureAlgorithm;
      CERT_NAME_BLOB             Issuer;
      FILETIME                   NotBefore;
      FILETIME                   NotAfter;
      CERT_NAME_BLOB             Subject;
      CERT_PUBLIC_KEY_INFO       SubjectPublicKeyInfo;
      CRYPT_BIT_BLOB             IssuerUniqueId;
      CRYPT_BIT_BLOB             SubjectUniqueId;
      DWORD                      cExtension;
      PCERT_EXTENSION            rgExtension;
  } CERT_INFO, *PCERT_INFO;

  typedef struct _CERT_CONTEXT {
      DWORD      dwCertEncodingType;
      BYTE       *pbCertEncoded;
      DWORD      cbCertEncoded;
      PCERT_INFO pCertInfo;
      HCERTSTORE hCertStore;
  } CERT_CONTEXT, *PCERT_CONTEXT;

  typedef struct _CERT_CHAIN_ELEMENT {
      DWORD                 cbSize;
      PCERT_CONTEXT     pCertContext;
      CERT_TRUST_STATUS TrustStatus;
      PVOID             pRevocationInfo;
      PVOID             pIssuanceUsage;
      PVOID             pApplicationUsage;
      LPCWSTR           pwszExtendedErrorInfo;
  } CERT_CHAIN_ELEMENT, *PCERT_CHAIN_ELEMENT;

  typedef struct {
      DWORD               cbStruct;
      PCERT_CONTEXT       pCert;
      BOOL                fCommercial;
      BOOL                fTrustedRoot;
      BOOL                fSelfSigned;
      BOOL                fTestCert;
      DWORD               dwRevokedReason;
      DWORD               dwConfidence;
      DWORD               dwError;
      CTL_CONTEXT         *pTrustListContext;
      BOOL                fTrustListSignerCert;
      PCCTL_CONTEXT       pCtlContext;
      DWORD               dwCtlError;
      BOOL                fIsCyclic;
      PCERT_CHAIN_ELEMENT pChainElement;
  } CRYPT_PROVIDER_CERT, *PCRYPT_PROVIDER_CERT;

  typedef struct _CRYPT_ATTRIBUTE {
      LPSTR            pszObjId;
      DWORD            cValue;
      PCRYPT_ATTR_BLOB rgValue;
  } CRYPT_ATTRIBUTE, *PCRYPT_ATTRIBUTE;

  typedef struct _CRYPT_ATTRIBUTES {
      DWORD            cAttr;
      PCRYPT_ATTRIBUTE rgAttr;
  } CRYPT_ATTRIBUTES, *PCRYPT_ATTRIBUTES;

  typedef struct _CMSG_SIGNER_INFO {
      DWORD                      dwVersion;
      CERT_NAME_BLOB             Issuer;
      CRYPT_INTEGER_BLOB         SerialNumber;
      CRYPT_ALGORITHM_IDENTIFIER HashAlgorithm;
      CRYPT_ALGORITHM_IDENTIFIER HashEncryptionAlgorithm;
      CRYPT_DATA_BLOB            EncryptedHash;
      CRYPT_ATTRIBUTES           AuthAttrs;
      CRYPT_ATTRIBUTES           UnauthAttrs;
  } CMSG_SIGNER_INFO, *PCMSG_SIGNER_INFO;

  typedef struct _CTL_ENTRY {
      CRYPT_DATA_BLOB  SubjectIdentifier;
      DWORD            cAttribute;
      PCRYPT_ATTRIBUTE rgAttribute;
  } CTL_ENTRY, *PCTL_ENTRY;

  typedef struct _CERT_TRUST_LIST_INFO {
      DWORD         cbSize;
      PCTL_ENTRY    pCtlEntry;
      PCCTL_CONTEXT pCtlContext;
  } CERT_TRUST_LIST_INFO, *PCERT_TRUST_LIST_INFO;

  typedef struct _CERT_SIMPLE_CHAIN {
      DWORD                 cbSize;
      CERT_TRUST_STATUS     TrustStatus;
      DWORD                 cElement;
      PCERT_CHAIN_ELEMENT   *rgpElement;
      PCERT_TRUST_LIST_INFO pTrustListInfo;
      BOOL                  fHasRevocationFreshnessTime;
      DWORD                 dwRevocationFreshnessTime;
  } CERT_SIMPLE_CHAIN, *PCERT_SIMPLE_CHAIN;

  typedef struct _CERT_CHAIN_CONTEXT CERT_CHAIN_CONTEXT, *PCERT_CHAIN_CONTEXT;
  typedef const CERT_CHAIN_CONTEXT *PCCERT_CHAIN_CONTEXT;

  typedef struct _CERT_CHAIN_CONTEXT {
      DWORD                cbSize;
      CERT_TRUST_STATUS    TrustStatus;
      DWORD                cChain;
      PCERT_SIMPLE_CHAIN   *rgpChain;
      DWORD                cLowerQualityChainContext;
      PCERT_CHAIN_CONTEXT *rgpLowerQualityChainContext;
      BOOL                 fHasRevocationFreshnessTime;
      DWORD                dwRevocationFreshnessTime;
      DWORD                dwCreateFlags;
      GUID                 ChainId;
  };

  typedef struct _CRYPT_PROVIDER_SGNR {
      DWORD                        cbStruct;
      FILETIME                     sftVerifyAsOf;
      DWORD                        csCertChain;
      CRYPT_PROVIDER_CERT          *pasCertChain;
      DWORD                        dwSignerType;
      CMSG_SIGNER_INFO             *psSigner;
      DWORD                        dwError;
      DWORD                        csCounterSigners;
      struct CRYPT_PROVIDER_SGNR_ *pasCounterSigners;
      PCERT_CHAIN_CONTEXT         pChainContext;
  } CRYPT_PROVIDER_SGNR, *PCRYPT_PROVIDER_SGNR;

  typedef struct _CRYPT_PROVIDER_PRIVDATA {
      DWORD cbStruct;
      GUID  gProviderID;
      DWORD cbProvData;
      void  *pvProvData;
  } CRYPT_PROVIDER_PRIVDATA, *PCRYPT_PROVIDER_PRIVDATA;

  typedef struct _CTL_USAGE {
      DWORD cUsageIdentifier;
      LPSTR *rgpszUsageIdentifier;
  } CTL_USAGE, *PCTL_USAGE, CERT_ENHKEY_USAGE, *PCERT_ENHKEY_USAGE;

  typedef struct _CERT_USAGE_MATCH {
      DWORD             dwType;
      CERT_ENHKEY_USAGE Usage;
  } CERT_USAGE_MATCH, *PCERT_USAGE_MATCH;

  typedef struct _CRYPT_PROVIDER_DATA {
      DWORD                    cbStruct;
      WINTRUST_DATA            *pWintrustData;
      BOOL                     fOpenedFile;
      HWND                     hWndParent;
      GUID                     *pgActionID;
      HCRYPTPROV               hProv;
      DWORD                    dwError;
      DWORD                    dwRegSecuritySettings;
      DWORD                    dwRegPolicySettings;
      CRYPT_PROVIDER_FUNCTIONS *psPfns;
      DWORD                    cdwTrustStepErrors;
      DWORD                    *padwTrustStepErrors;
      DWORD                    chStores;
      HCERTSTORE               *pahStores;
      DWORD                    dwEncoding;
      HCRYPTMSG                hMsg;
      DWORD                    csSigners;
      CRYPT_PROVIDER_SGNR      *pasSigners;
      DWORD                    csProvPrivData;
      CRYPT_PROVIDER_PRIVDATA  pasProvPrivData;
      DWORD                    dwSubjectChoice;
      union {
        struct PROVDATA_SIP *pPDSip;
      };
      char                     *pszUsageOID;
      BOOL                     fRecallWithState;
      FILETIME                 sftSystemTime;
      char                     *pszCTLSignerUsageOID;
      DWORD                    dwProvFlags;
      DWORD                    dwFinalError;
      PCERT_USAGE_MATCH        pRequestUsage;
      DWORD                    dwTrustPubSettings;
      DWORD                    dwUIStateFlags;
  } CRYPT_PROVIDER_DATA, *PCRYPT_PROVIDER_DATA;

  typedef struct WINTRUST_FILE_INFO_ {
      DWORD   cbStruct;
      LPCWSTR pcwszFilePath;
      HANDLE  hFile;
      GUID    *pgKnownSubject;
  } WINTRUST_FILE_INFO, *PWINTRUST_FILE_INFO;
]]

ffi.cdef [[
  LONG WinVerifyTrust(
    HWND   hwnd,
    GUID   *pgActionID,
    PVOID pWVTData
  );

  CRYPT_PROVIDER_SGNR *WTHelperGetProvSignerFromChain(
    PVOID pProvData,  // CRYPT_PROVIDER_DATA *
    DWORD idxSigner,
    BOOL  fCounterSigner,
    DWORD idxCounterSigner
  );

  // CRYPT_PROVIDER_DATA *
  PVOID WTHelperProvDataFromStateData(
    HANDLE hStateData
  );

  BOOL CertFreeCertificateContext(
    PCERT_CONTEXT pCertContext
  );

  PCERT_CONTEXT CertDuplicateCertificateContext(
      PCERT_CONTEXT pCertContext
  );

  DWORD CertNameToStrA(
    DWORD           dwCertEncodingType,
    PCERT_NAME_BLOB pName,
    DWORD           dwStrType,
    LPSTR           psz,
    DWORD           csz
  );
]]
