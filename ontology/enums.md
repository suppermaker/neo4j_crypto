# 枚举和字典设计

## 重要程度

```text
关键
非常重要
重要
一般
未明确
```

## 密码应用域

```text
物理和环境安全
网络和通信安全
设备和计算安全
应用和数据安全
密钥管理
安全管理
```

## 威胁层面

```text
物理和环境
网络和通信
设备和计算
应用和数据
密钥管理和安全管理
```

## 简单枚举与可复用字典的边界

简单状态、分类提示等只作为属性枚举；需要跨报告复用并与其他知识建立关系的概念建成全局字典节点。

| 概念 | 建模方式 |
|---|---|
| `AssetType` | 简单枚举，存入资产节点的 `asset_type` |
| `NetworkZoneType` | 简单枚举，存入 `SecurityArea.zone_type` |
| `ComplianceResult` | 简单枚举，存入 `ComplianceItem.result` |
| `ProductType` | 全局字典节点 |
| `DataCategory` | 全局字典节点 |
| `EvaluationCriterion` | 全局字典节点 |

## 资产类型

`AssetType` 枚举建议：

```text
服务器
数据库
网络设备
中间件
业务应用
密码产品
物理安防设施
重要数据
```

## 网络区域类型

`NetworkZoneType` 枚举建议：

```text
互联网区
接入区
DMZ
业务区
数据库区
管理区
办公区
灾备区
```

## 合规结果

`ComplianceResult` 枚举：

```text
符合
部分符合
不符合
不适用
未判定
```

## 密码算法

建议作为全局 `CryptoAlgorithm` 字典节点：

| 名称 | 类型 |
|---|---|
| `SM2` | 非对称密码算法 |
| `SM3` | 杂凑算法 |
| `SM4` | 对称密码算法 |
| `国密SSL` | 密码协议 |
| `TLS 1.3` | 安全传输协议 |
| `MAC` | 消息鉴别码 |

## 密码用途

建议作为全局 `CryptoUsage` 字典节点：

```text
身份鉴别
传输加密
存储加密
完整性保护
数字签名
访问控制保护
安全标记保护
日志完整性保护
程序完整性保护
密钥管理
电子印章
时间戳
不可否认
```

## 安全需求

建议作为全局 `SecurityRequirement` 字典节点：

```text
机密性
完整性
真实性
不可否认性
抗抵赖性
访问控制
身份鉴别
安全审计
```

## 密码产品类型

建议作为全局 `ProductType` 字典节点：

```text
VPN
签名验签服务器
时间戳服务器
密码机
密钥管理系统
CA 系统
UKey
密码网关
```

## 数据类别

建议作为全局 `DataCategory` 字典节点：

```text
身份鉴别数据
业务数据
日志数据
个人敏感信息
密钥数据
配置数据
```

## 测评指标

`EvaluationCriterion` 是全局字典节点，但不预置通用种子值。测评指标必须从实际采用的标准及条款导入，并保留 `source_standard` 和 `clause_no`。

## 数据质量标记

```text
MISSING_VENDOR          厂商缺失
MISSING_MODEL           型号缺失
MISSING_VERSION         版本缺失
MISSING_CERTIFICATE     证书编号缺失
AMBIGUOUS_TEXT          原文存在歧义
CONFLICTING_TEXT        原文存在矛盾
DUPLICATE_NAME          名称重复
PLACEHOLDER_VALUE       占位值，如 XX、未提供
CONTROL_CHAR_FOUND      存在异常控制字符
LOW_CONFIDENCE          抽取置信度低
```
