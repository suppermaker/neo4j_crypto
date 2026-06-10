WITH 1 AS _
UNWIND [
  {name: "SM2", algorithm_type: "非对称密码算法", standard: "商用密码算法"},
  {name: "SM3", algorithm_type: "杂凑算法", standard: "商用密码算法"},
  {name: "SM4", algorithm_type: "对称密码算法", standard: "商用密码算法"},
  {name: "国密SSL", algorithm_type: "密码协议", standard: "国密 SSL/TLS 相关协议"},
  {name: "TLS 1.3", algorithm_type: "安全传输协议", standard: "TLS 1.3"},
  {name: "MAC", algorithm_type: "消息鉴别码", standard: "用于数据完整性和真实性校验"}
] AS item
MERGE (n:CryptoAlgorithm {name: item.name})
SET
  n.algorithm_type = item.algorithm_type,
  n.standard = item.standard;

WITH 1 AS _
UNWIND [
  {name: "身份鉴别", description: "确认用户、设备、应用或通信实体身份"},
  {name: "传输加密", description: "保护数据传输过程中的机密性"},
  {name: "存储加密", description: "保护数据存储过程中的机密性"},
  {name: "完整性保护", description: "发现数据、日志、配置或程序被篡改的情况"},
  {name: "数字签名", description: "保护数据真实性、完整性和不可否认性"},
  {name: "访问控制保护", description: "保护访问控制策略、权限表和授权关系"},
  {name: "安全标记保护", description: "保护数据敏感等级和安全标记不被篡改"},
  {name: "日志完整性保护", description: "保护审计日志和操作记录完整性"},
  {name: "程序完整性保护", description: "保护重要程序和文件来源可信、未被篡改"},
  {name: "密钥管理", description: "管理密钥生成、存储、分发、使用、备份、销毁等过程"},
  {name: "电子印章", description: "为电子文件提供签章能力"},
  {name: "时间戳", description: "为签名、印章或业务操作提供可信时间证明"},
  {name: "不可否认", description: "防止数据发送方、接收方或操作方否认相关行为"}
] AS item
MERGE (n:CryptoUsage {name: item.name})
SET n.description = item.description;

WITH 1 AS _
UNWIND [
  {name: "机密性", description: "防止信息被未授权获取"},
  {name: "完整性", description: "防止信息被未授权篡改，并能发现篡改"},
  {name: "真实性", description: "确认实体、数据来源或操作行为真实可信"},
  {name: "不可否认性", description: "防止相关方否认已发生的发送、接收、签署或操作行为"},
  {name: "抗抵赖性", description: "防止相关方抵赖其行为，与不可否认性语义接近"},
  {name: "访问控制", description: "限制主体对客体资源的访问权限"},
  {name: "身份鉴别", description: "确认访问主体或通信实体身份"},
  {name: "安全审计", description: "记录、检查和追溯安全相关事件"}
] AS item
MERGE (n:SecurityRequirement {name: item.name})
SET n.description = item.description;

WITH 1 AS _
UNWIND [
  {code: "VPN", name: "VPN", description: "用于建立加密通信隧道的密码产品"},
  {code: "SIGNATURE_SERVER", name: "签名验签服务器", description: "提供数字签名和签名验证能力的密码产品"},
  {code: "TIMESTAMP_SERVER", name: "时间戳服务器", description: "提供可信时间戳服务的密码产品"},
  {code: "CRYPTO_MACHINE", name: "密码机", description: "提供密码运算和密钥保护能力的专用密码设备"},
  {code: "KEY_MANAGEMENT_SYSTEM", name: "密钥管理系统", description: "管理密钥全生命周期的系统或产品"},
  {code: "CA_SYSTEM", name: "CA 系统", description: "提供数字证书签发和管理能力的系统"},
  {code: "UKEY", name: "UKey", description: "用于身份鉴别、签名或密钥存储的便携式密码设备"},
  {code: "CRYPTO_GATEWAY", name: "密码网关", description: "提供网络边界加密、认证等能力的密码产品"}
] AS item
MERGE (n:ProductType {code: item.code})
SET
  n.name = item.name,
  n.description = item.description;

WITH 1 AS _
UNWIND [
  {code: "AUTHENTICATION_DATA", name: "身份鉴别数据", description: "用于确认用户、设备或应用身份的数据"},
  {code: "BUSINESS_DATA", name: "业务数据", description: "业务处理过程中产生和使用的数据"},
  {code: "LOG_DATA", name: "日志数据", description: "用于安全审计、运行监控和问题追溯的日志"},
  {code: "PERSONAL_SENSITIVE_DATA", name: "个人敏感信息", description: "一旦泄露或滥用可能危害自然人权益的信息"},
  {code: "KEY_DATA", name: "密钥数据", description: "密码密钥及其相关管理数据"},
  {code: "CONFIGURATION_DATA", name: "配置数据", description: "系统、设备、应用和安全策略配置数据"}
] AS item
MERGE (n:DataCategory {code: item.code})
SET
  n.name = item.name,
  n.description = item.description;

// EvaluationCriterion has no generic seed values. Import criteria from the
// actual standards used by an evaluation and preserve source_standard/clause_no.

WITH 1 AS _
UNWIND [
  {
    code: "TP1",
    domain: "物理和环境",
    category: "非法进入物理环境",
    description: "非法人员进入物理环境，对软硬件设备和数据进行直接破坏"
  },
  {
    code: "TP2",
    domain: "物理和环境",
    category: "物理记录被篡改",
    description: "物理进出记录和视频记录遭到篡改，以掩盖非法人员进出情况"
  },
  {
    code: "TN1",
    domain: "网络和通信",
    category: "非法通信实体接入",
    description: "非法通信实体接入网络"
  },
  {
    code: "TN2",
    domain: "网络和通信",
    category: "通信数据被截取或篡改",
    description: "通信数据在信息系统外部被非授权的截取、篡改"
  },
  {
    code: "TN3",
    domain: "网络和通信",
    category: "非法设备接入或边界破坏",
    description: "非法设备从外部接入内部网络，或网络边界被破坏"
  },
  {
    code: "TD1",
    domain: "设备和计算",
    category: "设备被非法登录",
    description: "设备被非法人员登录"
  },
  {
    code: "TD2",
    domain: "设备和计算",
    category: "远程管理通道被非法使用",
    description: "搭建的远程管理通道被非法使用，或传输的管理数据被非授权获取和篡改"
  },
  {
    code: "TD3",
    domain: "设备和计算",
    category: "设备资源被越权获取",
    description: "设备资源被登录设备的其他用户获取"
  },
  {
    code: "TD4",
    domain: "设备和计算",
    category: "设备安全标记被篡改",
    description: "重要信息资源安全标记被非授权获取和篡改"
  },
  {
    code: "TD5",
    domain: "设备和计算",
    category: "设备日志被篡改",
    description: "设备日志记录被非法篡改，以掩盖非法操作"
  },
  {
    code: "TD6",
    domain: "设备和计算",
    category: "重要程序和文件来源不可信",
    description: "设备内重要程序和文件的来源不可信"
  },
  {
    code: "TA1",
    domain: "应用和数据",
    category: "应用被非法登录",
    description: "应用被非法人员登录"
  },
  {
    code: "TA2",
    domain: "应用和数据",
    category: "应用资源被越权获取",
    description: "应用资源被登录应用的其他用户获取"
  },
  {
    code: "TA3",
    domain: "应用和数据",
    category: "应用安全标记被篡改",
    description: "重要信息资源安全标记被非授权获取和篡改"
  },
  {
    code: "TA4",
    domain: "应用和数据",
    category: "传输或存储数据被非法获取或篡改",
    description: "传输或存储的数据被外部攻击者非法获取和/或篡改"
  },
  {
    code: "TA5",
    domain: "应用和数据",
    category: "数据被其他应用获取",
    description: "某个应用传输或存储的数据被其他应用获取"
  },
  {
    code: "TA6",
    domain: "应用和数据",
    category: "发送或接收行为被否认",
    description: "数据发送者或接收者不承认发送或接受到数据，或者否认所做的操作和交易"
  },
  {
    code: "TK1",
    domain: "密钥管理和安全管理",
    category: "密钥随机性不足",
    description: "生成的密钥缺少随机性，被攻击者猜测"
  },
  {
    code: "TK2",
    domain: "密钥管理和安全管理",
    category: "密钥被非法获取",
    description: "密钥被非法获取"
  },
  {
    code: "TK3",
    domain: "密钥管理和安全管理",
    category: "密钥或密钥绑定关系被篡改",
    description: "密钥被非法篡改，或密钥与实体之间的关联关系被非法篡改"
  },
  {
    code: "TK4",
    domain: "密钥管理和安全管理",
    category: "密钥被非法使用",
    description: "密钥被非法使用"
  },
  {
    code: "TK5",
    domain: "密钥管理和安全管理",
    category: "密钥备份和归档机制不健全",
    description: "密钥备份和归档机制不健全，导致密钥泄露，或密钥被恢复到非法的设备中"
  },
  {
    code: "TK6",
    domain: "密钥管理和安全管理",
    category: "密钥销毁不及时或可恢复",
    description: "密钥销毁不及时导致密钥泄露，或销毁的密钥被恶意恢复"
  },
  {
    code: "TK7",
    domain: "密钥管理和安全管理",
    category: "安全管理制度和密钥管理策略不完善",
    description: "安全管理制度和密钥管理策略等不完善，管理流程不健全，执行不到位，职责不明确，导致密钥泄露、数据泄露等风险"
  }
] AS item
MERGE (n:Threat {code: item.code})
SET
  n.domain = item.domain,
  n.category = item.category,
  n.description = item.description;
