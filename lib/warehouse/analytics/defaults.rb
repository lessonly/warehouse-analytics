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
        RESERVED_WORDS = {
          "AES128" => true,
          "AES256" => true,
          "ALL" => true,
          "ALLOWOVERWRITE" => true,
          "ANALYSE" => true,
          "ANALYZE" => true,
          "AND" => true,
          "ANY" => true,
          "ARRAY" => true,
          "AS" => true,
          "ASC" => true,
          "AUTHORIZATION" => true,
          "AZ64" => true,
          "BACKUP" => true,
          "BETWEEN" => true,
          "BINARY" => true,
          "BLANKSASNULL" => true,
          "BOTH" => true,
          "BYTEDICT" => true,
          "BZIP2" => true,
          "CASE" => true,
          "CAST" => true,
          "CHECK" => true,
          "COLLATE" => true,
          "COLUMN" => true,
          "CONSTRAINT" => true,
          "CREATE" => true,
          "CREDENTIALS" => true,
          "CROSS" => true,
          "CURRENT_DATE" => true,
          "CURRENT_TIME" => true,
          "CURRENT_TIMESTAMP" => true,
          "CURRENT_USER" => true,
          "CURRENT_USER_ID" => true,
          "DEFAULT" => true,
          "DEFERRABLE" => true,
          "DEFLATE" => true,
          "DEFRAG" => true,
          "DELTA" => true,
          "DELTA32K" => true,
          "DESC" => true,
          "DISABLE" => true,
          "DISTINCT" => true,
          "DO" => true,
          "ELSE" => true,
          "EMPTYASNULL" => true,
          "ENABLE" => true,
          "ENCODE" => true,
          "ENCRYPT" => true,
          "ENCRYPTION" => true,
          "END" => true,
          "EXCEPT" => true,
          "EXPLICIT" => true,
          "FALSE" => true,
          "FOR" => true,
          "FOREIGN" => true,
          "FREEZE" => true,
          "FROM" => true,
          "FULL" => true,
          "GLOBALDICT256" => true,
          "GLOBALDICT64K" => true,
          "GRANT" => true,
          "GROUP" => true,
          "GZIP" => true,
          "HAVING" => true,
          "IDENTITY" => true,
          "IGNORE" => true,
          "ILIKE" => true,
          "IN" => true,
          "INITIALLY" => true,
          "INNER" => true,
          "INTERSECT" => true,
          "INTO" => true,
          "IS" => true,
          "ISNULL" => true,
          "JOIN" => true,
          "LANGUAGE" => true,
          "LEADING" => true,
          "LEFT" => true,
          "LIKE" => true,
          "LIMIT" => true,
          "LOCALTIME" => true,
          "LOCALTIMESTAMP" => true,
          "LUN" => true,
          "LUNS" => true,
          "LZO" => true,
          "LZOP" => true,
          "MINUS" => true,
          "MOSTLY16" => true,
          "MOSTLY32" => true,
          "MOSTLY8" => true,
          "NATURAL" => true,
          "NEW" => true,
          "NOT" => true,
          "NOTNULL" => true,
          "NULL" => true,
          "NULLS" => true,
          "OFF" => true,
          "OFFLINE" => true,
          "OFFSET" => true,
          "OID" => true,
          "OLD" => true,
          "ON" => true,
          "ONLY" => true,
          "OPEN" => true,
          "OR" => true,
          "ORDER" => true,
          "OUTER" => true,
          "OVERLAPS" => true,
          "PARALLEL" => true,
          "PARTITION" => true,
          "PERCENT" => true,
          "PERMISSIONS" => true,
          "PIVOT" => true,
          "PLACING" => true,
          "PRIMARY" => true,
          "RAW" => true,
          "READRATIO" => true,
          "RECOVER" => true,
          "REFERENCES" => true,
          "RESPECT" => true,
          "REJECTLOG" => true,
          "RESORT" => true,
          "RESTORE" => true,
          "RIGHT" => true,
          "SELECT" => true,
          "SESSION_USER" => true,
          "SIMILAR" => true,
          "SNAPSHOT" => true,
          "SOME" => true,
          "SYSDATE" => true,
          "SYSTEM" => true,
          "TABLE" => true,
          "TAG" => true,
          "TDES" => true,
          "TEXT255" => true,
          "TEXT32K" => true,
          "THEN" => true,
          "TIMESTAMP" => true,
          "TO" => true,
          "TOP" => true,
          "TRAILING" => true,
          "TRUE" => true,
          "TRUNCATECOLUMNS" => true,
          "UNION" => true,
          "UNIQUE" => true,
          "UNNEST" => true,
          "UNPIVOT" => true,
          "USER" => true,
          "USING" => true,
          "VERBOSE" => true,
          "WALLET" => true,
          "WHEN" => true,
          "WHERE" => true,
          "WITH" => true,
          "WITHOUT" => true
        }
      end
    end
  end
end
