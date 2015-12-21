-- -----------------------------------------------------------------------------
-- Barcelona Graduate School of Economics
-- Master's Degree in Data Science
-- -----------------------------------------------------------------------------
-- Project  : Computing Lab
-- Script   : data_structure.sql
-- -----------------------------------------------------------------------------
-- Author   : Miquel Torrens, 2015.11.08
-- Modified : Miquel Torrens, 2015.12.21
-- -----------------------------------------------------------------------------

-- Create the database
DROP DATABASE IF EXISTS omsong;
CREATE DATABASE omsong;
USE omsong;

-- Create table with song metadata
DROP TABLE IF EXISTS song_metadata;
CREATE TABLE song_metadata (
  analysis_sample_rate INT(5),
  audio_md5 VARCHAR(32),
  danceability TINYINT(1),
  duration DECIMAL(8, 4),
  end_of_fade_in DECIMAL(4, 4),
  energy TINYINT(1),
  idx_bars_confidence TINYINT(1),
  idx_bars_start TINYINT(1),
  idx_beats_confidence TINYINT(1),
  idx_beats_start TINYINT(1),
  idx_sections_confidence TINYINT(1),
  idx_sections_start TINYINT(1),
  idx_segments_confidence TINYINT(1),
  idx_segments_loudness_max TINYINT(1),
  idx_segments_loudness_max_time TINYINT(1),
  idx_segments_loudness_start TINYINT(1),
  idx_segments_pitches TINYINT(1),
  idx_segments_start TINYINT(1),
  idx_segments_timbre TINYINT(1),
  idx_tatums_confidence TINYINT(1),
  idx_tatums_start TINYINT(1),
  song_key INT(2),
  key_confidence DECIMAL(5, 4),
  loudness DECIMAL(7, 4),
  song_mode TINYINT(1),
  mode_confidence DECIMAL(5, 4),
  start_of_fade_out DECIMAL(8, 4),
  tempo DECIMAL(7, 4),
  time_signature TINYINT(1),
  time_signature_confidence DECIMAL(5, 4),
  track_id VARCHAR(18),
  mean_bars_confidence DECIMAL(8, 8),
  mean_bars_start DECIMAL(8, 8),
  mean_beats_confidence DECIMAL(8, 8),
  mean_beats_start DECIMAL(8, 8),
  mean_sections_confidence DECIMAL(8, 8),
  mean_sections_start DECIMAL(8, 8),
  mean_segments_confidence DECIMAL(8, 8),
  mean_segments_loudness_max DECIMAL(8, 8),
  mean_segments_loudness_max_time DECIMAL(8, 8),
  mean_segments_loudness_start DECIMAL(8, 8),
  mean_segments_pitches DECIMAL(8, 8),
  mean_segments_start DECIMAL(8, 8),
  mean_segments_timbre DECIMAL(8, 8),
  mean_tatums_confidence DECIMAL(8, 8),
  mean_tatums_start DECIMAL(8, 8),
  sd_bars_confidence DECIMAL(8, 8),
  sd_bars_start DECIMAL(8, 8),
  sd_beats_confidence DECIMAL(8, 8),
  sd_beats_start DECIMAL(8, 8),
  sd_sections_confidence DECIMAL(8, 8),
  sd_sections_start DECIMAL(8, 8),
  sd_segments_confidence DECIMAL(8, 8),
  sd_segments_loudness_max DECIMAL(8, 8),
  sd_segments_loudness_max_time DECIMAL(8, 8),
  sd_segments_loudness_start DECIMAL(8, 8),
  sd_segments_pitches DECIMAL(8, 8),
  sd_segments_start DECIMAL(8, 8),
  sd_segments_timbre DECIMAL(8, 8),
  sd_tatums_confidence DECIMAL(8, 8),
  sd_tatums_start DECIMAL(8, 8),
  analyzer_version TINYINT(1),
  artist_7digitalid INT(6),
  artist_familiarity DECIMAL(8, 8),
  artist_hotttnesss DECIMAL(8, 8),
  artist_id VARCHAR(18),
  artist_latitude DECIMAL(8, 8),
  artist_location VARCHAR(65),
  artist_longitude DECIMAL(8, 8),
  artist_mbid VARCHAR(36),
  artist_name VARCHAR(255),
  artist_playmeid INT(6),
  genre VARCHAR(30),
  idx_artist_terms TINYINT(1),
  idx_similar_artists TINYINT(1),
  release_name VARCHAR(132),
  release_7digitalid VARCHAR(18),
  song_hotttnesss VARCHAR(9),
  song_id VARCHAR(18),
  title VARCHAR(174),
  track_7digitalid VARCHAR(7),
  songs_year INT(4),
  play_count INT(5),
  unique_users INT(5),
  artist_title TEXT,
  PRIMARY KEY (song_id)
);

-- Create table with artist relations
DROP TABLE IF EXISTS artist_relations;
CREATE TABLE artist_relations (
  relation_id VARCHAR(37),
  song_id VARCHAR(18),
  artist_id VARCHAR(18),
  related_artist VARCHAR(18),
  relation_rank INT(3),
  PRIMARY KEY (relation_id),
  FOREIGN KEY (song_id) REFERENCES song_metadata (song_id)
  -- FOREIGN KEY (artist_id) REFERENCES song_metadata (artist_id)
);

-- Create table with artist terms
DROP TABLE IF EXISTS artist_terms;
CREATE TABLE artist_terms (
  term_artist_id VARCHAR(56),
  song_id VARCHAR(18),
  artist_id VARCHAR(18),
  artist_term VARCHAR(36),
  term_freq DECIMAL(6, 6),
  term_weight DECIMAL(6, 6),
  PRIMARY KEY (term_artist_id),
  FOREIGN KEY (song_id) REFERENCES song_metadata (song_id)
);

-- Create table with song tags
DROP TABLE IF EXISTS song_tags;
CREATE TABLE song_tags (
  song_tag_id VARCHAR(120),
  song_id VARCHAR(18),
  artist_id VARCHAR(18),
  song_tag VARCHAR(90),
  tag_freq INT(3),
  PRIMARY KEY (song_tag_id),
  FOREIGN KEY (song_id) REFERENCES song_metadata (song_id)
);

-- Create indexes
-- Song ID
CREATE INDEX idx1_song_id ON song_metadata (song_id);
CREATE INDEX idx2_song_id ON artist_relations (song_id);
CREATE INDEX idx3_song_id ON artist_terms (song_id);
CREATE INDEX idx4_song_id ON song_tags (song_id);
CREATE INDEX idx3_word_id ON word_count (song_id);

-- Artist ID
CREATE INDEX idx1_artist_id ON song_metadata (artist_id);
CREATE INDEX idx2_artist_id ON artist_relations (artist_id);
CREATE INDEX idx3_artist_id ON artist_terms (artist_id);
CREATE INDEX idx4_artist_id ON song_tags (artist_id);

-- Rest of IDs
CREATE INDEX idx_relation_id ON artist_relations (relation_id);
CREATE INDEX idx_term_artist_id ON artist_terms (term_artist_id);
CREATE INDEX idx_song_tag_id ON song_tags (song_tag_id);
CREATE INDEX idx1_word_id ON words (word_id);
CREATE INDEX idx2_word_id ON word_count (word_id);
-- END OF SCRIPT