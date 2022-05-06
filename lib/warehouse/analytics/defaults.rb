module Warehouse
  class Analytics
    module Defaults
      module Request
        HOST = 'api.warehouse.io'
        PORT = 443
        PATH = '/v1/import'
        SSL = true
        HEADERS = { 'Accept' => 'application/json',
                    'Content-Type' => 'application/json',
                    'User-Agent' => "warehouse-analytics/#{Analytics::VERSION}" }
        RETRIES = 10
      end

      module Queue
        MAX_SIZE = 10000
      end

      module Message
        MAX_BYTES = 32768 # 32Kb
      end

      module MessageBatch
        MAX_BYTES = 512_000 # 500Kb
        MAX_SIZE = 100
      end

      module BackoffPolicy
        MIN_TIMEOUT_MS = 100
        MAX_TIMEOUT_MS = 10000
        MULTIPLIER = 1.5
        RANDOMIZATION_FACTOR = 0.5
      end

      module Redshift
        # https://docs.aws.amazon.com/redshift/latest/dg/r_pg_keywords.html
        RESERVED_WORDS = [
          "AES128",
          "AES256",
          "ALL",
          "ALLOWOVERWRITE",
          "ANALYSE",
          "ANALYZE",
          "AND",
          "ANY",
          "ARRAY",
          "AS",
          "ASC",
          "AUTHORIZATION",
          "AZ64",
          "BACKUP",
          "BETWEEN",
          "BINARY",
          "BLANKSASNULL",
          "BOTH",
          "BYTEDICT",
          "BZIP2",
          "CASE",
          "CAST",
          "CHECK",
          "COLLATE",
          "COLUMN",
          "CONSTRAINT",
          "CREATE",
          "CREDENTIALS",
          "CROSS",
          "CURRENT_DATE",
          "CURRENT_TIME",
          "CURRENT_TIMESTAMP",
          "CURRENT_USER",
          "CURRENT_USER_ID",
          "DEFAULT",
          "DEFERRABLE",
          "DEFLATE",
          "DEFRAG",
          "DELTA",
          "DELTA32K",
          "DESC",
          "DISABLE",
          "DISTINCT",
          "DO",
          "ELSE",
          "EMPTYASNULL",
          "ENABLE",
          "ENCODE",
          "ENCRYPT",
          "ENCRYPTION",
          "END",
          "EXCEPT",
          "EXPLICIT",
          "FALSE",
          "FOR",
          "FOREIGN",
          "FREEZE",
          "FROM",
          "FULL",
          "GLOBALDICT256",
          "GLOBALDICT64K",
          "GRANT",
          "GROUP",
          "GZIP",
          "HAVING",
          "IDENTITY",
          "IGNORE",
          "ILIKE",
          "IN",
          "INITIALLY",
          "INNER",
          "INTERSECT",
          "INTO",
          "IS",
          "ISNULL",
          "JOIN",
          "LANGUAGE",
          "LEADING",
          "LEFT",
          "LIKE",
          "LIMIT",
          "LOCALTIME",
          "LOCALTIMESTAMP",
          "LUN",
          "LUNS",
          "LZO",
          "LZOP",
          "MINUS",
          "MOSTLY16",
          "MOSTLY32",
          "MOSTLY8",
          "NATURAL",
          "NEW",
          "NOT",
          "NOTNULL",
          "NULL",
          "NULLS",
          "OFF",
          "OFFLINE",
          "OFFSET",
          "OID",
          "OLD",
          "ON",
          "ONLY",
          "OPEN",
          "OR",
          "ORDER",
          "OUTER",
          "OVERLAPS",
          "PARALLEL",
          "PARTITION",
          "PERCENT",
          "PERMISSIONS",
          "PIVOT",
          "PLACING",
          "PRIMARY",
          "RAW",
          "READRATIO",
          "RECOVER",
          "REFERENCES",
          "RESPECT",
          "REJECTLOG",
          "RESORT",
          "RESTORE",
          "RIGHT",
          "SELECT",
          "SESSION_USER",
          "SIMILAR",
          "SNAPSHOT",
          "SOME",
          "SYSDATE",
          "SYSTEM",
          "TABLE",
          "TAG",
          "TDES",
          "TEXT255",
          "TEXT32K",
          "THEN",
          "TIMESTAMP",
          "TO",
          "TOP",
          "TRAILING",
          "TRUE",
          "TRUNCATECOLUMNS",
          "UNION",
          "UNIQUE",
          "UNNEST",
          "UNPIVOT",
          "USER",
          "USING",
          "VERBOSE",
          "WALLET",
          "WHEN",
          "WHERE",
          "WITH",
          "WITHOUT"
        ]
      end
    end
  end
end
