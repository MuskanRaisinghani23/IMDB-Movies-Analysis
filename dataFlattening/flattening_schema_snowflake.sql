
-- flatten table for title_crew directors attribute
CREATE TABLE title_crew_directors (
    tconst VARCHAR(15),
    director VARCHAR
);

-- flatten table for title_crew writers attribute
CREATE TABLE title_crew_writers (
    tconst VARCHAR(15),
    writer VARCHAR
);

-- flatten table for name_basics primaryProfession attribute
CREATE TABLE name_basics_primary_profession (
    nconst VARCHAR(15),
    primaryProfession VARCHAR
);

-- flatten table for name_basics knownForTitles attribute
CREATE TABLE name_basics_known_titles (
    nconst VARCHAR(15),
    knownForTitles VARCHAR
);

-- flatten table for title_basic genres attribute
CREATE TABLE title_basics_genres (
    TCONST VARCHAR(15),
    GENRE VARCHAR
);

-- flatten query for title_crew directors attribute
INSERT INTO MID_TERM_DADABI.FLATTEN_SCHEMA.TITLE_CREW_DIRECTORS (TCONST, DIRECTOR)
SELECT 
    TCONST, 
    value
FROM MID_TERM_DADABI.RAW_STAGE_SCHEMA.TITLE_CREW
JOIN LATERAL FLATTEN(input => SPLIT(DIRECTORS, ','));

-- flatten query for title_crew writers attribute
INSERT INTO MID_TERM_DADABI.FLATTEN_SCHEMA.TITLE_CREW_WRITERS (TCONST, WRITER)
SELECT 
    TCONST, 
    value
FROM MID_TERM_DADABI.RAW_STAGE_SCHEMA.TITLE_CREW
JOIN LATERAL FLATTEN(input => SPLIT(WRITERS, ','));

-- flatten query for name_basics primaryProfession  attribute
INSERT INTO MID_TERM_DADABI.FLATTEN_SCHEMA.NAME_BASICS_PRIMARY_PROFESSION (NCONST, primaryProfession)
SELECT 
    NCONST, 
    value
FROM MID_TERM_DADABI.RAW_STAGE_SCHEMA.NAME_BASICS
JOIN LATERAL FLATTEN(input => SPLIT(primaryProfession, ','));

-- flatten query for name_basics knownForTitles attribute
INSERT INTO MID_TERM_DADABI.FLATTEN_SCHEMA.NAME_BASICS_KNOWN_TITLES (NCONST, knownForTitles)
SELECT 
    NCONST, 
    value
FROM MID_TERM_DADABI.RAW_STAGE_SCHEMA.NAME_BASICS
JOIN LATERAL FLATTEN(input => SPLIT(knownForTitles, ','));

-- flatten query for title_basics genres attribute
INSERT INTO MID_TERM_DADABI.FLATTEN_SCHEMA.TITLE_BASICS_GENRES (TCONST, GENRE)
SELECT 
    TCONST, 
    value
FROM MID_TERM_DADABI.RAW_STAGE_SCHEMA.TITLE_BASICS
JOIN LATERAL FLATTEN(input => SPLIT(GENRES, ','));
