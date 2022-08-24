// Create a simple partitioned table

file -inlinebatch END_OF_BATCH

CREATE TABLE stuff1 (
    col1 INTEGER UNIQUE NOT NULL,
    col2 INTEGER,
    tcreate TIMESTAMP DEFAULT NOW NOT NULL,
    tupdate TIMESTAMP DEFAULT NOW NOT NULL,
    PRIMARY KEY (col1)
);
PARTITION TABLE stuff1 ON COLUMN col1;
DR TABLE stuff1;

END_OF_BATCH
