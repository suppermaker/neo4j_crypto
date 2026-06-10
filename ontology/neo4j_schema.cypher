CREATE CONSTRAINT evaluation_project_id IF NOT EXISTS
FOR (n:EvaluationProject)
REQUIRE n.id IS UNIQUE;

CREATE CONSTRAINT report_id IF NOT EXISTS
FOR (n:Report)
REQUIRE n.id IS UNIQUE;

CREATE CONSTRAINT system_id IF NOT EXISTS
FOR (n:System)
REQUIRE n.id IS UNIQUE;

CREATE CONSTRAINT entity_id IF NOT EXISTS
FOR (n:Entity)
REQUIRE n.id IS UNIQUE;

CREATE CONSTRAINT algorithm_name IF NOT EXISTS
FOR (n:CryptoAlgorithm)
REQUIRE n.name IS UNIQUE;

CREATE CONSTRAINT usage_name IF NOT EXISTS
FOR (n:CryptoUsage)
REQUIRE n.name IS UNIQUE;

CREATE CONSTRAINT requirement_name IF NOT EXISTS
FOR (n:SecurityRequirement)
REQUIRE n.name IS UNIQUE;

CREATE CONSTRAINT threat_code IF NOT EXISTS
FOR (n:Threat)
REQUIRE n.code IS UNIQUE;

CREATE CONSTRAINT product_type_code IF NOT EXISTS
FOR (n:ProductType)
REQUIRE n.code IS UNIQUE;

CREATE CONSTRAINT data_category_code IF NOT EXISTS
FOR (n:DataCategory)
REQUIRE n.code IS UNIQUE;

CREATE CONSTRAINT evaluation_criterion_code IF NOT EXISTS
FOR (n:EvaluationCriterion)
REQUIRE n.code IS UNIQUE;

CREATE CONSTRAINT report_section_id IF NOT EXISTS
FOR (n:ReportSection)
REQUIRE n.id IS UNIQUE;

CREATE CONSTRAINT report_field_id IF NOT EXISTS
FOR (n:ReportField)
REQUIRE n.id IS UNIQUE;

CREATE INDEX entity_system_id IF NOT EXISTS
FOR (n:Entity)
ON (n.system_id);

CREATE INDEX entity_report_id IF NOT EXISTS
FOR (n:Entity)
ON (n.report_id);

CREATE INDEX report_project_id IF NOT EXISTS
FOR (n:Report)
ON (n.project_id);

CREATE INDEX system_project_id IF NOT EXISTS
FOR (n:System)
ON (n.project_id);

CREATE INDEX system_report_id IF NOT EXISTS
FOR (n:System)
ON (n.report_id);

CREATE INDEX report_section_report_id IF NOT EXISTS
FOR (n:ReportSection)
ON (n.report_id);

CREATE INDEX report_field_section_id IF NOT EXISTS
FOR (n:ReportField)
ON (n.section_id);

CREATE INDEX crypto_application_domain IF NOT EXISTS
FOR (n:CryptoApplication)
ON (n.domain);

CREATE INDEX threat_domain IF NOT EXISTS
FOR (n:Threat)
ON (n.domain);

CREATE INDEX evaluation_criterion_domain IF NOT EXISTS
FOR (n:EvaluationCriterion)
ON (n.domain);

CREATE FULLTEXT INDEX entity_text IF NOT EXISTS
FOR (n:Entity)
ON EACH [n.name, n.source_text, n.remark];

CREATE FULLTEXT INDEX report_field_text IF NOT EXISTS
FOR (n:ReportField)
ON EACH [n.key, n.name, n.value];

CREATE FULLTEXT INDEX threat_text IF NOT EXISTS
FOR (n:Threat)
ON EACH [n.code, n.category, n.description];
