PGDMP                          z            byte-le-royale-2021     14.1 (Ubuntu 14.1-2.pgdg20.04+1)     14.1 (Ubuntu 14.1-2.pgdg20.04+1) M    d           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            e           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            f           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            g           1262    16650    byte-le-royale-2021    DATABASE     ~   CREATE DATABASE "byte-le-royale-2021" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'en_US.UTF-8' TABLESPACE = fourtb;
 %   DROP DATABASE "byte-le-royale-2021";
                byte_api    false                        3079    16651 	   uuid-ossp 	   EXTENSION     ?   CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;
    DROP EXTENSION "uuid-ossp";
                   false            h           0    0    EXTENSION "uuid-ossp"    COMMENT     W   COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';
                        false    2                       1255    16916 2   delete_group_run_and_foriegn_keys_cascade(integer)    FUNCTION     a  CREATE FUNCTION public.delete_group_run_and_foriegn_keys_cascade(grouprunid integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE rtnid integer;
BEGIN
-- Created by: Sean Hagen
-- Written on: 12/15/2021
-- Deletes a group run, and FKs delete in the cascade
	DELETE FROM group_run WHERE group_run.group_run_id = grouprunid;
	return 1;
end;
$$;
 T   DROP FUNCTION public.delete_group_run_and_foriegn_keys_cascade(grouprunid integer);
       public          postgres    false            �            1255    16662    fetch_latest_clients()    FUNCTION     �  CREATE FUNCTION public.fetch_latest_clients() RETURNS TABLE(team_id uuid, submission_id integer, file_text character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
-- Select latest code files. Because of the serial nature of submissionID, we can use max(subid) to 
-- find the latest submission.
RETURN QUERY
SELECT
    sub.team_id,
    sub.submission_id,
    code_file.file_text
from
    code_file
    JOIN (
        SELECT
            submission.team_id,
            MAX(submission.submission_id) as submission_id
        FROM
            submission
        GROUP BY
            submission.team_id
    ) as sub ON sub.submission_id = code_file.submission_id;
end;
$$;
 -   DROP FUNCTION public.fetch_latest_clients();
       public          postgres    false            �            1255    16663 '   get_file_from_submission(uuid, integer)    FUNCTION     �  CREATE FUNCTION public.get_file_from_submission(teamid uuid, submissionid integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
BEGIN
-- Created by: Sean Hagen
-- Written on: 11/1/2021
-- Returns the code file for a given submission
RETURN file_text FROM code_file JOIN submission ON code_file.submission_id = submission.submission_id
WHERE team_id = teamid AND submission.submission_id = submissionid;
--SELECT * FROM team
end;
$$;
 R   DROP FUNCTION public.get_file_from_submission(teamid uuid, submissionid integer);
       public          postgres    false                       1255    17209    get_latest_group_id()    FUNCTION       CREATE FUNCTION public.get_latest_group_id() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
-- Created by: Sean Hagen
-- Written on: 12/2/2021
-- Returns the latest group run id 
RETURN group_run.group_run_id FROM group_run ORDER BY group_run_id desc LIMIT 1;
end;
$$;
 ,   DROP FUNCTION public.get_latest_group_id();
       public          postgres    false                       1255    16827    get_latest_submission(uuid)    FUNCTION     Q  CREATE FUNCTION public.get_latest_submission(teamid uuid) RETURNS TABLE(submission_id integer, group_run_id integer, runs_per_client integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
-- Created by: Sean Hagen
-- Written on: 11/1/2021
-- Select the latest submission_id, group_run_id for a team as well as the runs_per_team for that group run
RETURN QUERY
SELECT
    latest_submission.subid,
    latest_submission.group_run_id,
	group_run.runs_per_client
FROM
    group_run
    JOIN (
        SELECT
            MAX(submission.submission_id) as subid,
            MAX(run.group_run_id) as group_run_id
        FROM
            run
            JOIN submission ON run.submission_id = submission.submission_id
        WHERE
            submission.team_id = teamid

) as latest_submission ON group_run.group_run_id = latest_submission.group_run_id;
end;
$$;
 9   DROP FUNCTION public.get_latest_submission(teamid uuid);
       public          postgres    false            	           1255    17014 !   get_leaderboard(boolean, integer)    FUNCTION     ;  CREATE FUNCTION public.get_leaderboard(include_inelligible boolean, grouprun integer) RETURNS TABLE(group_run_id integer, team_name character varying, uni_name character varying, submit_time timestamp without time zone, average_score numeric, standard_deviation numeric, launcher_version character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
-- Created by: Sean Hagen
-- Written on: 11/1/2021
-- include_inelligible: if true, return inelligible teams in the results
-- group_run: if -1 then return most recent group_run, else return results for the specified group run
RETURN QUERY
SELECT
	run.group_run_id,
    team.team_name,
    university.uni_name,
    submission.submit_time,
    ROUND(AVG(run.score), 3) as Average_Score,
    ROUND(stddev_pop(run.score), 3) as Standard_Deviation, 
	group_run.launcher_version
FROM
    run
    JOIN submission ON run.submission_id = submission.submission_id
    JOIN team on submission.team_id = team.team_id
    JOIN team_type on team.team_type_id = team_type.team_type_id
    JOIN university on team.uni_id = university.uni_id
	JOIN group_run on run.group_run_id = group_run.group_run_id
WHERE
    (
        team_type.eligible
        OR include_inelligible
    )
    AND (
        -- If grouprun is negative, select most recent grouprun
        run.group_run_id in (
            SELECT
                MAX(group_run.group_run_id)
            FROM
                group_run
        )
        AND grouprun < 0
    )
    OR (
        -- Otherwise, select the specified grouprunF
        run.group_run_id = grouprun
        AND grouprun > 0
    ) -- If include_inelligible is true, all teams are included. Else, the team must be elligible
GROUP BY
    team.team_name,
    university.uni_name,
    submission.submit_time,
	run.group_run_id,
	group_run.launcher_version
ORDER BY
    Average_Score DESC;

end;
$$;
 U   DROP FUNCTION public.get_leaderboard(include_inelligible boolean, grouprun integer);
       public          postgres    false                       1255    17174    get_logs_for_group_run(integer)    FUNCTION     �  CREATE FUNCTION public.get_logs_for_group_run(grouprun integer) RETURNS TABLE(run_id integer, group_run_id integer, submission_id integer, team_name character varying, log_text character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN--SELECT * FROM team
-- Created by: Sean Hagen
-- Written on: 1/1/2021
-- returns the logs for a given group run
RETURN QUERY
SELECT
    run.run_id,
    run.group_run_id,
    run.submission_id,
    team.team_name,
	logs.log_text
FROM
	logs JOIN run ON logs.run_id = run.run_id
    JOIN submission ON run.submission_id = submission.submission_id
    JOIN team ON submission.team_id = team.team_id
WHERE
    run.group_run_id = grouprun;
end;
$$;
 ?   DROP FUNCTION public.get_logs_for_group_run(grouprun integer);
       public          postgres    false                       1255    16813 )   get_runs_for_submission(integer, integer)    FUNCTION     4  CREATE FUNCTION public.get_runs_for_submission(submissionid integer, groupid integer) RETURNS TABLE(group_run_id integer, run_id integer, run_time timestamp without time zone, score integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
-- Created by: Sean Hagen
-- Written on: 12/30/2021
-- returns the runs for a given submission and group_run
RETURN QUERY
SELECT run.group_run_id, run.run_id, run.run_time, run.score FROM run JOIN submission ON run.submission_id = submission.submission_id
WHERE run.submission_id = submissionid AND run.group_run_id = groupid;
end;
$$;
 U   DROP FUNCTION public.get_runs_for_submission(submissionid integer, groupid integer);
       public          postgres    false            �            1255    16808 &   get_runs_for_submission(uuid, integer)    FUNCTION     L  CREATE FUNCTION public.get_runs_for_submission(teamid uuid, submissionid integer) RETURNS TABLE(run_id integer, score integer, group_run_id integer, run_time timestamp without time zone, seed_id integer, launcher_version character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
-- Created by: Sean Hagen
-- Written on: 12/30/2021
-- teamid: uuid to get runs for
-- submiddionid: submission id to get runs for
-- Returns the runs for a given team and submission
RETURN QUERY
SELECT run.run_id, run.score, run.group_run_id, run.run_time, run.seed_id, group_run.launcher_version
FROM submission JOIN run ON submission.submission_id = run.submission_id JOIN group_run on run.group_run_id = group_run.group_run_id
WHERE submission.team_id = teamid AND submission.submission_id = submissionid
ORDER BY run.run_time DESC;
--SELECT * FROM team
end;
$$;
 Q   DROP FUNCTION public.get_runs_for_submission(teamid uuid, submissionid integer);
       public          postgres    false                       1255    16805    get_seed_for_run(uuid, integer)    FUNCTION     �  CREATE FUNCTION public.get_seed_for_run(teamid uuid, runid integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
BEGIN
-- Created by: Sean Hagen
-- Written on: 12/15/2021
-- teamid : uuid to get seed for
-- runid: run id to get seed for
-- returns the seed for a given team and run
RETURN seed
FROM
    run
    JOIN seed ON run.seed_id = seed.seed_id
    JOIN submission ON run.submission_id = submission.submission_id
WHERE
    team_id = teamid
    AND run_id = runid;
end;
$$;
 C   DROP FUNCTION public.get_seed_for_run(teamid uuid, runid integer);
       public          postgres    false                        1255    16668    get_submissions_for_team(uuid)    FUNCTION     �  CREATE FUNCTION public.get_submissions_for_team(teamid uuid) RETURNS TABLE(submission_id integer, submit_time timestamp without time zone)
    LANGUAGE plpgsql
    AS $$
BEGIN--SELECT * FROM team
-- Created by: Sean Hagen
-- Written on: 12/15/2021
-- returns all submission ids a team has
RETURN QUERY
SELECT submission.submission_id, submission.submit_time FROM SUBMISSION 
WHERE team_id = teamid
ORDER BY submit_time DESC;
end;
$$;
 <   DROP FUNCTION public.get_submissions_for_team(teamid uuid);
       public          postgres    false                       1255    16809 *   get_team_runs_for_group_run(uuid, integer)    FUNCTION     �  CREATE FUNCTION public.get_team_runs_for_group_run(teamid uuid, grouprunid integer) RETURNS TABLE(run_id integer, score integer, submission_run_id integer, run_time timestamp without time zone, seed_id integer, launcher_version character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
-- Created by: Sean Hagen
-- Written on: 12/30/2021
-- gets the runs for a given group run and team
RETURN QUERY
SELECT run.run_id, run.score, submission.submission_id, run.run_time, run.seed_id, group_run.launcher_version
FROM submission JOIN run ON submission.submission_id = run.submission_id JOIN group_run ON group_run.group_run_id = run.group_run_id
WHERE submission.team_id = teamid AND run.group_run_id = grouprunid
ORDER BY run.run_time DESC;
end;
$$;
 S   DROP FUNCTION public.get_team_runs_for_group_run(teamid uuid, grouprunid integer);
       public          postgres    false            �            1255    16811    get_team_score_over_time(uuid)    FUNCTION     f  CREATE FUNCTION public.get_team_score_over_time(teamid uuid) RETURNS TABLE(group_run_id integer, run_time timestamp without time zone, average_score numeric, standard_deviation numeric, launcher_version character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
-- Created by: Sean Hagen
-- Written on: 11/1/2021
-- gets a teams average score for each group run they were in
RETURN QUERY
SELECT
	run.group_run_id,
	group_run.start_run as run_time,
    ROUND(AVG(run.score),3) as Average_Score,
	ROUND(stddev_pop(run.score),3) as Standard_Deviation,
	group_run.launcher_version
FROM
    run
    JOIN submission ON run.submission_id = submission.submission_id
	JOIN group_run ON run.group_run_id = group_run.group_run_id
WHERE
	submission.team_id = teamId
GROUP BY run.group_run_id, group_run.start_run, group_run.launcher_version
ORDER BY group_run.start_run DESC;
end;
$$;
 <   DROP FUNCTION public.get_team_score_over_time(teamid uuid);
       public          postgres    false            �            1255    16670    get_team_types()    FUNCTION     C  CREATE FUNCTION public.get_team_types() RETURNS TABLE(team_type_id integer, team_type_name character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
-- Created by: Sean Hagen
-- Written on: 11/1/2021
-- returns the team type table
RETURN QUERY
SELECT team_type.team_type_id, team_type.team_type_name FROM team_type;
end;
$$;
 '   DROP FUNCTION public.get_team_types();
       public          postgres    false            �            1255    16671    get_teams()    FUNCTION     �  CREATE FUNCTION public.get_teams() RETURNS TABLE(team_name character varying, uni_name character varying, team_type_name character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
-- Created by: Sean Hagen
-- Written on: 12/15/2021
-- returns all of the teams that registered
RETURN QUERY
SELECT team.team_name, university.uni_name, team_type.team_type_name FROM team 
JOIN university ON team.uni_id = university.uni_id 
JOIN team_type ON team.team_type_id = team_type.team_type_id;
end;
$$;
 "   DROP FUNCTION public.get_teams();
       public          postgres    false            �            1255    16672    get_universities()    FUNCTION     �   CREATE FUNCTION public.get_universities() RETURNS TABLE(uni_id integer, uni_name character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
-- Selects all universities
RETURN QUERY
SELECT university.uni_id, university.uni_name FROM university;
end;
$$;
 )   DROP FUNCTION public.get_universities();
       public          postgres    false                       1255    16816 ,   insert_group_run(character varying, integer)    FUNCTION        CREATE FUNCTION public.insert_group_run(launcherversion character varying, runsperclient integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE rtnid integer;
BEGIN
-- Created by: Sean Hagen
-- Written on: 12/15/2021
-- Insert into group run. both id and timestamp are default, so only LauncherVersion and number of runs per client are needed
    INSERT INTO group_run(launcher_version, runs_per_client) VALUES (LauncherVersion, runsperclient) RETURNING group_run_id INTO rtnid;
	return rtnid;
end;
$$;
 a   DROP FUNCTION public.insert_group_run(launcherversion character varying, runsperclient integer);
       public          byte_api    false                       1255    17098 /   insert_log(character varying, integer, integer)    FUNCTION     �  CREATE FUNCTION public.insert_log(logfl character varying, runid integer, grouprunid integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
-- Created by: Sean Hagen
-- Written on: 12/15/2021
-- Inserts a log into the log table. Note the cascading delete effect that group run and run have on this table!
    INSERT INTO logs (log_text, run_id, group_run_id) VALUES (logfl, runid, groupRunId);
end;
$$;
 ]   DROP FUNCTION public.insert_log(logfl character varying, runid integer, grouprunid integer);
       public          postgres    false            
           1255    17055 A   insert_run(integer, integer, integer, character varying, integer)    FUNCTION     �  CREATE FUNCTION public.insert_run(sub_id integer, score integer, group_run_id integer, err character varying, seedid integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE runid int;
begin
    -- insert run into run table
	INSERT INTO run(submission_id, score, group_run_id, seed_id) 
	VALUES (sub_id, score, group_run_id, seedid) RETURNING run_id INTO runid;
	
	if err <> '' then
		INSERT INTO errors VALUES (runid, err);
	end if;
	return runid;
end;
$$;
 }   DROP FUNCTION public.insert_run(sub_id integer, score integer, group_run_id integer, err character varying, seedid integer);
       public          byte_api    false                       1255    16914 '   insert_seed(character varying, integer)    FUNCTION     �  CREATE FUNCTION public.insert_seed(seedfl character varying, grouprunid integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE rtnid integer;
BEGIN
-- Created by: Sean Hagen
-- Written on: 12/15/2021
-- Inserts a seed into the seed table. Note that seeds are re-used by each team and delete when there group run is deleted
    INSERT INTO seed (seed, group_run_id) VALUES (seedfl, groupRunId) RETURNING seed_id INTO rtnid;
	return rtnid;
end;
$$;
 P   DROP FUNCTION public.insert_seed(seedfl character varying, grouprunid integer);
       public          postgres    false            �            1255    16677 0   insert_team(integer, character varying, integer)    FUNCTION     �  CREATE FUNCTION public.insert_team(team_type integer, team character varying, uni integer) RETURNS uuid
    LANGUAGE plpgsql
    AS $$
DECLARE tmid uuid;
BEGIN
-- Created by: Sean Hagen
-- Inserts a new team into the team table
-- Returns team id
    INSERT INTO team (team_type_id, team_name, uni_id) VALUES (team_type, team, uni)  RETURNING team_id INTO tmid;
	return tmid;
end;
$$;
 Z   DROP FUNCTION public.insert_team(team_type integer, team character varying, uni integer);
       public          postgres    false            �            1255    16678 )   submit_code_file(character varying, uuid) 	   PROCEDURE     �  CREATE PROCEDURE public.submit_code_file(IN file character varying, IN vid uuid)
    LANGUAGE plpgsql
    AS $$
DECLARE sub_ID int = 0;
begin
    -- insert submission into submission table
	INSERT INTO SUBMISSION (team_id) VALUES (vid) RETURNING submission_id INTO sub_ID;
	
    -- insert file into file table
	INSERT INTO code_file(submission_id, file_text) VALUES (sub_id, file);
end;
$$;
 P   DROP PROCEDURE public.submit_code_file(IN file character varying, IN vid uuid);
       public          postgres    false            �            1259    16679 	   code_file    TABLE     ^   CREATE TABLE public.code_file (
    submission_id integer,
    file_text character varying
);
    DROP TABLE public.code_file;
       public         heap    postgres    false            �            1259    16684    errors    TABLE     U   CREATE TABLE public.errors (
    run_id integer,
    error_text character varying
);
    DROP TABLE public.errors;
       public         heap    postgres    false            �            1259    16689 	   group_run    TABLE     �   CREATE TABLE public.group_run (
    group_run_id integer NOT NULL,
    start_run timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    launcher_version character varying(10) NOT NULL,
    runs_per_client integer
);
    DROP TABLE public.group_run;
       public         heap    postgres    false            �            1259    16693    group_run_group_run_id_seq    SEQUENCE     �   CREATE SEQUENCE public.group_run_group_run_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE public.group_run_group_run_id_seq;
       public          postgres    false    212            i           0    0    group_run_group_run_id_seq    SEQUENCE OWNED BY     Y   ALTER SEQUENCE public.group_run_group_run_id_seq OWNED BY public.group_run.group_run_id;
          public          postgres    false    213            �            1259    16694    logs    TABLE     k   CREATE TABLE public.logs (
    run_id integer,
    log_text character varying,
    group_run_id integer
);
    DROP TABLE public.logs;
       public         heap    postgres    false            �            1259    16699    run    TABLE     �   CREATE TABLE public.run (
    submission_id integer,
    run_id integer NOT NULL,
    score integer,
    group_run_id integer,
    run_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    seed_id integer
);
    DROP TABLE public.run;
       public         heap    postgres    false            �            1259    16703    run_runid_seq    SEQUENCE     �   CREATE SEQUENCE public.run_runid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 $   DROP SEQUENCE public.run_runid_seq;
       public          postgres    false    215            j           0    0    run_runid_seq    SEQUENCE OWNED BY     @   ALTER SEQUENCE public.run_runid_seq OWNED BY public.run.run_id;
          public          postgres    false    216            �            1259    16704    seed    TABLE     q   CREATE TABLE public.seed (
    seed_id integer NOT NULL,
    seed character varying,
    group_run_id integer
);
    DROP TABLE public.seed;
       public         heap    postgres    false            �            1259    16709    seed_seed_id_seq    SEQUENCE     �   CREATE SEQUENCE public.seed_seed_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.seed_seed_id_seq;
       public          postgres    false    217            k           0    0    seed_seed_id_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE public.seed_seed_id_seq OWNED BY public.seed.seed_id;
          public          postgres    false    218            �            1259    16710 
   submission    TABLE     �   CREATE TABLE public.submission (
    team_id uuid,
    submission_id integer NOT NULL,
    valid boolean DEFAULT false NOT NULL,
    submit_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);
    DROP TABLE public.submission;
       public         heap    postgres    false            �            1259    16715    submission_submissionid_seq    SEQUENCE     �   CREATE SEQUENCE public.submission_submissionid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 2   DROP SEQUENCE public.submission_submissionid_seq;
       public          postgres    false    219            l           0    0    submission_submissionid_seq    SEQUENCE OWNED BY     \   ALTER SEQUENCE public.submission_submissionid_seq OWNED BY public.submission.submission_id;
          public          postgres    false    220            �            1259    16716    team    TABLE       CREATE TABLE public.team (
    team_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    uni_id integer,
    team_type_id integer,
    team_name character varying(100) NOT NULL,
    CONSTRAINT team_teamname_check CHECK (((team_name)::text <> ''::text))
);
    DROP TABLE public.team;
       public         heap    postgres    false    2            �            1259    16721 	   team_type    TABLE     �   CREATE TABLE public.team_type (
    team_type_id integer NOT NULL,
    team_type_name character varying(100) NOT NULL,
    eligible boolean,
    CONSTRAINT teamtype_teamname_check CHECK (((team_type_name)::text <> ''::text))
);
    DROP TABLE public.team_type;
       public         heap    postgres    false            �            1259    16725    teamtype_teamtypeid_seq    SEQUENCE     �   CREATE SEQUENCE public.teamtype_teamtypeid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 .   DROP SEQUENCE public.teamtype_teamtypeid_seq;
       public          postgres    false    222            m           0    0    teamtype_teamtypeid_seq    SEQUENCE OWNED BY     V   ALTER SEQUENCE public.teamtype_teamtypeid_seq OWNED BY public.team_type.team_type_id;
          public          postgres    false    223            �            1259    16726 
   university    TABLE     �   CREATE TABLE public.university (
    uni_id integer NOT NULL,
    uni_name character varying(100) NOT NULL,
    CONSTRAINT university_uniname_check CHECK (((uni_name)::text <> ''::text))
);
    DROP TABLE public.university;
       public         heap    postgres    false            �            1259    16730    university_uniid_seq    SEQUENCE     �   CREATE SEQUENCE public.university_uniid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.university_uniid_seq;
       public          postgres    false    224            n           0    0    university_uniid_seq    SEQUENCE OWNED BY     N   ALTER SEQUENCE public.university_uniid_seq OWNED BY public.university.uni_id;
          public          postgres    false    225            �           2604    16731    group_run group_run_id    DEFAULT     �   ALTER TABLE ONLY public.group_run ALTER COLUMN group_run_id SET DEFAULT nextval('public.group_run_group_run_id_seq'::regclass);
 E   ALTER TABLE public.group_run ALTER COLUMN group_run_id DROP DEFAULT;
       public          postgres    false    213    212            �           2604    16732 
   run run_id    DEFAULT     g   ALTER TABLE ONLY public.run ALTER COLUMN run_id SET DEFAULT nextval('public.run_runid_seq'::regclass);
 9   ALTER TABLE public.run ALTER COLUMN run_id DROP DEFAULT;
       public          postgres    false    216    215            �           2604    16733    seed seed_id    DEFAULT     l   ALTER TABLE ONLY public.seed ALTER COLUMN seed_id SET DEFAULT nextval('public.seed_seed_id_seq'::regclass);
 ;   ALTER TABLE public.seed ALTER COLUMN seed_id DROP DEFAULT;
       public          postgres    false    218    217            �           2604    16734    submission submission_id    DEFAULT     �   ALTER TABLE ONLY public.submission ALTER COLUMN submission_id SET DEFAULT nextval('public.submission_submissionid_seq'::regclass);
 G   ALTER TABLE public.submission ALTER COLUMN submission_id DROP DEFAULT;
       public          postgres    false    220    219            �           2604    16735    team_type team_type_id    DEFAULT     }   ALTER TABLE ONLY public.team_type ALTER COLUMN team_type_id SET DEFAULT nextval('public.teamtype_teamtypeid_seq'::regclass);
 E   ALTER TABLE public.team_type ALTER COLUMN team_type_id DROP DEFAULT;
       public          postgres    false    223    222            �           2604    16736    university uni_id    DEFAULT     u   ALTER TABLE ONLY public.university ALTER COLUMN uni_id SET DEFAULT nextval('public.university_uniid_seq'::regclass);
 @   ALTER TABLE public.university ALTER COLUMN uni_id DROP DEFAULT;
       public          postgres    false    225    224            �           2606    16738    group_run group_run_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.group_run
    ADD CONSTRAINT group_run_pkey PRIMARY KEY (group_run_id);
 B   ALTER TABLE ONLY public.group_run DROP CONSTRAINT group_run_pkey;
       public            postgres    false    212            �           2606    16740    run run_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public.run
    ADD CONSTRAINT run_pkey PRIMARY KEY (run_id);
 6   ALTER TABLE ONLY public.run DROP CONSTRAINT run_pkey;
       public            postgres    false    215            �           2606    16742    seed seed_pkey 
   CONSTRAINT     Q   ALTER TABLE ONLY public.seed
    ADD CONSTRAINT seed_pkey PRIMARY KEY (seed_id);
 8   ALTER TABLE ONLY public.seed DROP CONSTRAINT seed_pkey;
       public            postgres    false    217            �           2606    16744    submission submission_pkey 
   CONSTRAINT     c   ALTER TABLE ONLY public.submission
    ADD CONSTRAINT submission_pkey PRIMARY KEY (submission_id);
 D   ALTER TABLE ONLY public.submission DROP CONSTRAINT submission_pkey;
       public            postgres    false    219            �           2606    16746    team team_pkey 
   CONSTRAINT     Q   ALTER TABLE ONLY public.team
    ADD CONSTRAINT team_pkey PRIMARY KEY (team_id);
 8   ALTER TABLE ONLY public.team DROP CONSTRAINT team_pkey;
       public            postgres    false    221            �           2606    16748    team team_teamname_key 
   CONSTRAINT     V   ALTER TABLE ONLY public.team
    ADD CONSTRAINT team_teamname_key UNIQUE (team_name);
 @   ALTER TABLE ONLY public.team DROP CONSTRAINT team_teamname_key;
       public            postgres    false    221            �           2606    16750    team_type teamtype_pkey 
   CONSTRAINT     _   ALTER TABLE ONLY public.team_type
    ADD CONSTRAINT teamtype_pkey PRIMARY KEY (team_type_id);
 A   ALTER TABLE ONLY public.team_type DROP CONSTRAINT teamtype_pkey;
       public            postgres    false    222            �           2606    16752    university university_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.university
    ADD CONSTRAINT university_pkey PRIMARY KEY (uni_id);
 D   ALTER TABLE ONLY public.university DROP CONSTRAINT university_pkey;
       public            postgres    false    224            �           1259    17095    fki_fk_run_id    INDEX     @   CREATE INDEX fki_fk_run_id ON public.logs USING btree (run_id);
 !   DROP INDEX public.fki_fk_run_id;
       public            postgres    false    214            �           1259    16913    fki_group_run_id_fk    INDEX     L   CREATE INDEX fki_group_run_id_fk ON public.seed USING btree (group_run_id);
 '   DROP INDEX public.fki_group_run_id_fk;
       public            postgres    false    217            �           2606    16863 $   code_file codefile_submissionid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.code_file
    ADD CONSTRAINT codefile_submissionid_fkey FOREIGN KEY (submission_id) REFERENCES public.submission(submission_id) ON DELETE CASCADE;
 N   ALTER TABLE ONLY public.code_file DROP CONSTRAINT codefile_submissionid_fkey;
       public          postgres    false    210    3267    219            �           2606    16868    errors errors_run_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.errors
    ADD CONSTRAINT errors_run_id_fkey FOREIGN KEY (run_id) REFERENCES public.run(run_id) ON DELETE CASCADE;
 C   ALTER TABLE ONLY public.errors DROP CONSTRAINT errors_run_id_fkey;
       public          postgres    false    211    215    3262            �           2606    17056    logs fk_group_run_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.logs
    ADD CONSTRAINT fk_group_run_id FOREIGN KEY (group_run_id) REFERENCES public.group_run(group_run_id) ON DELETE CASCADE;
 >   ALTER TABLE ONLY public.logs DROP CONSTRAINT fk_group_run_id;
       public          postgres    false    214    3259    212            �           2606    17090    logs fk_run_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.logs
    ADD CONSTRAINT fk_run_id FOREIGN KEY (run_id) REFERENCES public.run(run_id) ON DELETE CASCADE;
 8   ALTER TABLE ONLY public.logs DROP CONSTRAINT fk_run_id;
       public          postgres    false    214    3262    215            �           2606    16908    seed group_run_id_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.seed
    ADD CONSTRAINT group_run_id_fk FOREIGN KEY (group_run_id) REFERENCES public.group_run(group_run_id) ON DELETE CASCADE;
 >   ALTER TABLE ONLY public.seed DROP CONSTRAINT group_run_id_fk;
       public          postgres    false    212    217    3259            �           2606    16878    run run_group_run_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.run
    ADD CONSTRAINT run_group_run_id_fkey FOREIGN KEY (group_run_id) REFERENCES public.group_run(group_run_id) ON DELETE CASCADE;
 C   ALTER TABLE ONLY public.run DROP CONSTRAINT run_group_run_id_fkey;
       public          postgres    false    212    215    3259            �           2606    16883    run run_submissionid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.run
    ADD CONSTRAINT run_submissionid_fkey FOREIGN KEY (submission_id) REFERENCES public.submission(submission_id) ON DELETE CASCADE;
 C   ALTER TABLE ONLY public.run DROP CONSTRAINT run_submissionid_fkey;
       public          postgres    false    3267    215    219            �           2606    16888    run seed_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.run
    ADD CONSTRAINT seed_fk FOREIGN KEY (seed_id) REFERENCES public.seed(seed_id) ON DELETE CASCADE;
 5   ALTER TABLE ONLY public.run DROP CONSTRAINT seed_fk;
       public          postgres    false    3265    215    217            �           2606    16893 !   submission submission_teamid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.submission
    ADD CONSTRAINT submission_teamid_fkey FOREIGN KEY (team_id) REFERENCES public.team(team_id) ON DELETE CASCADE;
 K   ALTER TABLE ONLY public.submission DROP CONSTRAINT submission_teamid_fkey;
       public          postgres    false    221    3269    219            �           2606    16898    team team_teamtypeid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.team
    ADD CONSTRAINT team_teamtypeid_fkey FOREIGN KEY (team_type_id) REFERENCES public.team_type(team_type_id) ON DELETE CASCADE;
 C   ALTER TABLE ONLY public.team DROP CONSTRAINT team_teamtypeid_fkey;
       public          postgres    false    3273    221    222            �           2606    16903    team team_uniid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.team
    ADD CONSTRAINT team_uniid_fkey FOREIGN KEY (uni_id) REFERENCES public.university(uni_id) ON DELETE CASCADE;
 >   ALTER TABLE ONLY public.team DROP CONSTRAINT team_uniid_fkey;
       public          postgres    false    224    221    3275           